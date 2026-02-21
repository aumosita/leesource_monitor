import Foundation
import IOKit

final class GPUMonitor: Sendable {

    func getGPUMetrics() -> GPUMetrics {
        var metrics = GPUMetrics()

        let matchingDict = IOServiceMatching("IOAccelerator")
        var iterator: io_iterator_t = 0

        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)
        guard result == KERN_SUCCESS else { return metrics }
        defer { IOObjectRelease(iterator) }

        var entry: io_registry_entry_t = IOIteratorNext(iterator)
        while entry != 0 {
            defer {
                IOObjectRelease(entry)
                entry = IOIteratorNext(iterator)
            }

            var properties: Unmanaged<CFMutableDictionary>?
            let kr = IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0)
            guard kr == KERN_SUCCESS, let props = properties?.takeRetainedValue() as? [String: Any] else {
                continue
            }

            guard let perfStats = props["PerformanceStatistics"] as? [String: Any] else {
                continue
            }

            if let deviceUtil = perfStats["Device Utilization %"] as? Int {
                metrics.deviceUtilization = Double(deviceUtil)
            }
            if let rendererUtil = perfStats["Renderer Utilization %"] as? Int {
                metrics.rendererUtilization = Double(rendererUtil)
            }
            if let tilerUtil = perfStats["Tiler Utilization %"] as? Int {
                metrics.tilerUtilization = Double(tilerUtil)
            }
            if let allocMem = perfStats["Alloc system memory"] as? UInt64 {
                metrics.allocatedSystemMemory = allocMem
            } else if let allocMem = perfStats["Alloc system memory"] as? Int {
                metrics.allocatedSystemMemory = UInt64(allocMem)
            }
            if let inUseMem = perfStats["In use system memory"] as? UInt64 {
                metrics.inUseSystemMemory = inUseMem
            } else if let inUseMem = perfStats["In use system memory"] as? Int {
                metrics.inUseSystemMemory = UInt64(inUseMem)
            }

            break  // Only need the first GPU
        }

        return metrics
    }
}
