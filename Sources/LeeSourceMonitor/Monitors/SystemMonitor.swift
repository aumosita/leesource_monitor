import Foundation
import SwiftUI

@Observable
@MainActor
final class SystemMonitor {
    // Current metrics
    var cpu = CPUMetrics()
    var memory = MemoryMetrics()
    var disk = DiskMetrics()
    var network = NetworkMetrics()
    var gpu = GPUMetrics()
    var temperature = TemperatureMetrics()
    var npu = NPUMetrics()

    // History for charts (last 60 seconds)
    var cpuHistory: [MetricSample] = []
    var cpuCoreHistory: [[MetricSample]] = []
    var memoryPressureHistory: [MetricSample] = []
    var memoryReadHistory: [MetricSample] = []
    var memoryWriteHistory: [MetricSample] = []
    var networkInHistory: [MetricSample] = []
    var networkOutHistory: [MetricSample] = []
    var gpuHistory: [MetricSample] = []
    var temperatureHistory: [String: [MetricSample]] = [:]
    var npuHistory: [MetricSample] = []

    private let maxHistoryCount = 60

    // Monitors
    private let cpuMonitor = CPUMonitor()
    private let memoryMonitor = MemoryMonitor()
    private let diskMonitor = DiskMonitor()
    private let networkMonitor = NetworkMonitor()
    private let gpuMonitor = GPUMonitor()
    private let temperatureMonitor = TemperatureMonitor()
    private let npuMonitor = NPUMonitor()

    // State
    private var cpuTicks: [CPUMonitor.CoreTicks]?
    private var memorySnapshot: MemoryMonitor.MemorySnapshot?
    private var networkSnapshot: NetworkMonitor.NetworkSnapshot?
    private var timer: Timer?
    private var isRunning = false

    func startMonitoring() {
        guard !isRunning else { return }
        isRunning = true

        // Initial fetch
        update()

        // Periodic updates
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.update()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func update() {
        let now = Date()

        // CPU
        let cpuResult = cpuMonitor.getCPUUsage(previousTicks: cpuTicks)
        cpu = cpuResult.metrics
        cpuTicks = cpuResult.ticks
        appendSample(&cpuHistory, MetricSample(timestamp: now, value: cpu.totalUsage, label: "CPU"))

        // Update per-core history
        if cpuCoreHistory.isEmpty && !cpu.coreUsages.isEmpty {
            cpuCoreHistory = Array(repeating: [], count: cpu.coreCount)
        }
        for (i, usage) in cpu.coreUsages.enumerated() where i < cpuCoreHistory.count {
            appendSample(&cpuCoreHistory[i], MetricSample(timestamp: now, value: usage, label: "Core \(i)"))
        }

        // Memory
        let memResult = memoryMonitor.getMemoryUsage(previous: memorySnapshot)
        memory = memResult.metrics
        memorySnapshot = memResult.snapshot
        appendSample(&memoryPressureHistory, MetricSample(timestamp: now, value: memory.pressure, label: "Pressure"))
        appendSample(&memoryReadHistory, MetricSample(timestamp: now, value: memory.readBytesPerSec, label: "Read"))
        appendSample(&memoryWriteHistory, MetricSample(timestamp: now, value: memory.writeBytesPerSec, label: "Write"))

        // Disk (update less frequently - every 10 seconds)
        if Int(now.timeIntervalSince1970) % 10 == 0 || disk.volumes.isEmpty {
            disk = diskMonitor.getDiskUsage()
        }

        // Network
        let netResult = networkMonitor.getNetworkUsage(previous: networkSnapshot)
        network = netResult.metrics
        networkSnapshot = netResult.snapshot
        appendSample(&networkInHistory, MetricSample(timestamp: now, value: network.speedIn, label: "Download"))
        appendSample(&networkOutHistory, MetricSample(timestamp: now, value: network.speedOut, label: "Upload"))

        // GPU
        gpu = gpuMonitor.getGPUMetrics()
        appendSample(&gpuHistory, MetricSample(timestamp: now, value: gpu.deviceUtilization, label: "GPU"))

        // Temperature
        temperature = temperatureMonitor.getTemperatures()
        for sensor in temperature.sensors {
            var history = temperatureHistory[sensor.name] ?? []
            appendSample(&history, MetricSample(timestamp: now, value: sensor.temperature, label: sensor.name))
            temperatureHistory[sensor.name] = history
        }

        // NPU
        npu = npuMonitor.getNPUMetrics()
        appendSample(&npuHistory, MetricSample(timestamp: now, value: npu.powerMilliwatts, label: "NPU"))
    }

    private func appendSample(_ history: inout [MetricSample], _ sample: MetricSample) {
        history.append(sample)
        if history.count > maxHistoryCount {
            history.removeFirst(history.count - maxHistoryCount)
        }
    }
}
