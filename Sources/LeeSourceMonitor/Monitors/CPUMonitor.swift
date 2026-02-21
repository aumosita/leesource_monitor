import Foundation
import Darwin

final class CPUMonitor: Sendable {

    struct CoreTicks: Sendable {
        var user: UInt64 = 0
        var system: UInt64 = 0
        var idle: UInt64 = 0
        var nice: UInt64 = 0
        var total: UInt64 { user + system + idle + nice }
    }

    func getCPUUsage(previousTicks: [CoreTicks]?) -> (metrics: CPUMetrics, ticks: [CoreTicks]) {
        var processorCount: natural_t = 0
        var processorInfo: processor_info_array_t?
        var processorInfoCount: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &processorInfo,
            &processorInfoCount
        )

        guard result == KERN_SUCCESS, let info = processorInfo else {
            return (CPUMetrics(), previousTicks ?? [])
        }

        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: info),
                vm_size_t(Int(processorInfoCount) * MemoryLayout<integer_t>.stride)
            )
        }

        let cpuCount = Int(processorCount)
        var currentTicks: [CoreTicks] = []
        var coreUsages: [Double] = []
        var totalUser: UInt64 = 0
        var totalSystem: UInt64 = 0
        var totalIdle: UInt64 = 0

        for i in 0..<cpuCount {
            let offset = Int(CPU_STATE_MAX) * i
            let user = UInt64(info[offset + Int(CPU_STATE_USER)])
            let system = UInt64(info[offset + Int(CPU_STATE_SYSTEM)])
            let idle = UInt64(info[offset + Int(CPU_STATE_IDLE)])
            let nice = UInt64(info[offset + Int(CPU_STATE_NICE)])

            let tick = CoreTicks(user: user, system: system, idle: idle, nice: nice)
            currentTicks.append(tick)

            totalUser += user
            totalSystem += system
            totalIdle += idle

            if let prev = previousTicks, i < prev.count {
                let deltaUser = user - prev[i].user
                let deltaSystem = system - prev[i].system
                let deltaIdle = idle - prev[i].idle
                let deltaNice = nice - prev[i].nice
                let deltaTotal = deltaUser + deltaSystem + deltaIdle + deltaNice
                if deltaTotal > 0 {
                    let usage = Double(deltaUser + deltaSystem + deltaNice) / Double(deltaTotal) * 100.0
                    coreUsages.append(usage)
                } else {
                    coreUsages.append(0)
                }
            } else {
                coreUsages.append(0)
            }
        }

        // Calculate total usage
        var totalUsage: Double = 0
        if let prev = previousTicks {
            let prevTotalUser = prev.reduce(0) { $0 + $1.user }
            let prevTotalSystem = prev.reduce(0) { $0 + $1.system }
            let prevTotalIdle = prev.reduce(0) { $0 + $1.idle }
            let prevTotalNice = prev.reduce(0) { $0 + $1.nice }

            let currTotalNice = currentTicks.reduce(0) { $0 + $1.nice }

            let dUser = totalUser - prevTotalUser
            let dSystem = totalSystem - prevTotalSystem
            let dIdle = totalIdle - prevTotalIdle
            let dNice = currTotalNice - prevTotalNice
            let dTotal = dUser + dSystem + dIdle + dNice
            if dTotal > 0 {
                totalUsage = Double(dUser + dSystem + dNice) / Double(dTotal) * 100.0
            }
        }

        let metrics = CPUMetrics(
            totalUsage: totalUsage,
            coreUsages: coreUsages,
            coreCount: cpuCount
        )
        return (metrics, currentTicks)
    }
}
