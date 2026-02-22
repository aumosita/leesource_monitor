import Foundation
import Darwin

final class MemoryMonitor: Sendable {

    struct MemorySnapshot: Sendable {
        var pageIns: UInt64 = 0
        var pageOuts: UInt64 = 0
        var timestamp: Date = Date()
    }

    func getMemoryUsage(previous: MemorySnapshot?) -> (metrics: MemoryMetrics, snapshot: MemorySnapshot) {
        var metrics = MemoryMetrics()

        // Get physical memory size
        var memSize: UInt64 = 0
        var sizeOfMemSize = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &memSize, &sizeOfMemSize, nil, 0)
        metrics.totalBytes = memSize

        // Get VM statistics
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
            }
        }

        let now = Date()
        var snapshot = MemorySnapshot(timestamp: now)

        if result == KERN_SUCCESS {
            let pageSize: UInt64 = 16384  // Apple Silicon page size

            let active = UInt64(vmStats.active_count) * pageSize
            let inactive = UInt64(vmStats.inactive_count) * pageSize
            let wired = UInt64(vmStats.wire_count) * pageSize
            let compressed = UInt64(vmStats.compressor_page_count) * pageSize
            let free = UInt64(vmStats.free_count) * pageSize

            metrics.activeBytes = active
            metrics.inactiveBytes = inactive
            metrics.wiredBytes = wired
            metrics.compressedBytes = compressed
            metrics.freeBytes = free

            // macOS "Memory Used" = Active + Wired + Compressed + Inactive
            metrics.usedBytes = active + wired + compressed + inactive

            // Memory pressure
            let usedPercent = Double(metrics.usedBytes) / Double(memSize) * 100
            metrics.pressure = usedPercent

            // Page ins/outs (disk read/write for swap)
            let currentPageIns = UInt64(vmStats.pageins)
            let currentPageOuts = UInt64(vmStats.pageouts)

            snapshot.pageIns = currentPageIns
            snapshot.pageOuts = currentPageOuts

            if let prev = previous {
                let elapsed = now.timeIntervalSince(prev.timestamp)
                if elapsed > 0 {
                    let deltaIns = currentPageIns >= prev.pageIns ? currentPageIns - prev.pageIns : 0
                    let deltaOuts = currentPageOuts >= prev.pageOuts ? currentPageOuts - prev.pageOuts : 0
                    let pageSize64: UInt64 = 16384
                    metrics.readBytesPerSec = Double(deltaIns * pageSize64) / elapsed
                    metrics.writeBytesPerSec = Double(deltaOuts * pageSize64) / elapsed
                }
            }
        }

        return (metrics, snapshot)
    }
}
