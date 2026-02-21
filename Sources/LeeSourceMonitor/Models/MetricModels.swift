import Foundation

// MARK: - CPU Metrics
struct CPUMetrics: Sendable {
    var totalUsage: Double = 0
    var coreUsages: [Double] = []
    var coreCount: Int = 0
}

// MARK: - Disk Metrics
struct DiskVolume: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let mountPoint: String
    let totalGB: Double
    let usedGB: Double
    var freeGB: Double { totalGB - usedGB }
    var usagePercent: Double { totalGB > 0 ? (usedGB / totalGB) * 100 : 0 }
}

struct DiskMetrics: Sendable {
    var volumes: [DiskVolume] = []
}

// MARK: - Memory Metrics
struct MemoryMetrics: Sendable {
    var totalBytes: UInt64 = 0
    var usedBytes: UInt64 = 0
    var activeBytes: UInt64 = 0
    var inactiveBytes: UInt64 = 0
    var wiredBytes: UInt64 = 0
    var compressedBytes: UInt64 = 0
    var freeBytes: UInt64 = 0
    var purgeableBytes: UInt64 = 0
    var speculativeBytes: UInt64 = 0
    var appMemoryBytes: UInt64 = 0
    var pressure: Double = 0  // percentage
    var readBytesPerSec: Double = 0   // page-ins
    var writeBytesPerSec: Double = 0  // page-outs
}

// MARK: - Network Metrics
struct NetworkMetrics: Sendable {
    var bytesIn: UInt64 = 0
    var bytesOut: UInt64 = 0
    var speedIn: Double = 0   // bytes/sec
    var speedOut: Double = 0  // bytes/sec
}

// MARK: - GPU Metrics
struct GPUMetrics: Sendable {
    var deviceUtilization: Double = 0
    var rendererUtilization: Double = 0
    var tilerUtilization: Double = 0
    var allocatedSystemMemory: UInt64 = 0
    var inUseSystemMemory: UInt64 = 0
}

// MARK: - Temperature Metrics
struct TemperatureSensor: Identifiable, Sendable {
    let id: String
    let name: String
    var temperature: Double  // Celsius
}

struct TemperatureMetrics: Sendable {
    var sensors: [TemperatureSensor] = []
}

// MARK: - NPU Metrics
struct NPUMetrics: Sendable {
    var powerMilliwatts: Double = 0
    var isActive: Bool { powerMilliwatts > 0 }
}

// MARK: - Metric Sample (for charts)
struct MetricSample: Identifiable, Sendable {
    let id = UUID()
    let timestamp: Date
    let value: Double
    let label: String

    init(timestamp: Date = Date(), value: Double, label: String = "") {
        self.timestamp = timestamp
        self.value = value
        self.label = label
    }
}
