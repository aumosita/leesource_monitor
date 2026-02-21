import Foundation
import IOKit

final class NPUMonitor: Sendable {

    func getNPUMetrics() -> NPUMetrics {
        var metrics = NPUMetrics()

        // Try to read ANE power from IOReport or IORegistry
        let matchingDict = IOServiceMatching("AppleARMIODevice")
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

            // Check if this is the ANE device
            var nameBuffer = [CChar](repeating: 0, count: 128)
            let nameResult = IORegistryEntryGetName(entry, &nameBuffer)
            guard nameResult == KERN_SUCCESS else { continue }

            let name: String
            if let nullIdx = nameBuffer.firstIndex(of: 0) {
                name = String(decoding: nameBuffer[..<nullIdx].map { UInt8(bitPattern: $0) }, as: UTF8.self)
            } else {
                name = String(decoding: nameBuffer.map { UInt8(bitPattern: $0) }, as: UTF8.self)
            }
            guard name.lowercased().contains("ane") else { continue }

            // Try to get performance/power data
            var properties: Unmanaged<CFMutableDictionary>?
            let kr = IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0)
            guard kr == KERN_SUCCESS, let props = properties?.takeRetainedValue() as? [String: Any] else {
                continue
            }

            // Check for power-related properties
            if let perfCtrl = props["ane-perf-ctr"] as? Int {
                metrics.powerMilliwatts = Double(perfCtrl)
            }
            if let power = props["power-consumption"] as? Int {
                metrics.powerMilliwatts = Double(power)
            }

            break
        }

        return metrics
    }
}
