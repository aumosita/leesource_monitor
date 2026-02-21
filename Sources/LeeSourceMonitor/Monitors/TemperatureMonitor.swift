import Foundation
import IOKit

// IOHIDEventSystemClient private API declarations for temperature sensors
@_silgen_name("IOHIDEventSystemClientCreate")
func IOHIDEventSystemClientCreate(_ allocator: CFAllocator?) -> IOHIDEventSystemClient

@_silgen_name("IOHIDEventSystemClientSetMatching")
func IOHIDEventSystemClientSetMatching(_ client: IOHIDEventSystemClient, _ matching: CFDictionary)

@_silgen_name("IOHIDEventSystemClientCopyServices")
func IOHIDEventSystemClientCopyServices(_ client: IOHIDEventSystemClient) -> CFArray?

@_silgen_name("IOHIDServiceClientCopyProperty")
func IOHIDServiceClientCopyProperty(_ service: IOHIDServiceClient, _ key: CFString) -> CFTypeRef?

@_silgen_name("IOHIDServiceClientCopyEvent")
func IOHIDServiceClientCopyEvent(_ service: IOHIDServiceClient, _ type: Int64, _ matching: Int32, _ options: Int32) -> IOHIDEvent?

@_silgen_name("IOHIDEventGetFloatValue")
func IOHIDEventGetFloatValue(_ event: IOHIDEvent, _ field: Int32) -> Double

// Opaque types
typealias IOHIDEventSystemClient = AnyObject
typealias IOHIDServiceClient = AnyObject
typealias IOHIDEvent = AnyObject

private let kIOHIDEventTypeTemperature: Int64 = 15
private let kIOHIDEventFieldTemperatureLevel: Int32 = 0xF0000  // field for temperature value

final class TemperatureMonitor: Sendable {

    // Friendly name mapping for Apple Silicon sensor keys
    private static let sensorNameMap: [String: String] = [
        "SOC MTR Temp Sensor0": "CPU E-Core 1",
        "SOC MTR Temp Sensor1": "CPU E-Core 2",
        "SOC MTR Temp Sensor2": "CPU E-Core 3",
        "eACC MTR Temp Sensor0": "CPU E-Cluster",
        "eACC MTR Temp Sensor3": "CPU E-Cluster 2",
        "pACC MTR Temp Sensor2": "CPU P-Core 1",
        "pACC MTR Temp Sensor3": "CPU P-Core 2",
        "pACC MTR Temp Sensor4": "CPU P-Core 3",
        "pACC MTR Temp Sensor5": "CPU P-Core 4",
        "pACC MTR Temp Sensor7": "CPU P-Cluster",
        "pACC MTR Temp Sensor8": "CPU P-Cluster 2",
        "pACC MTR Temp Sensor9": "CPU P-Cluster 3",
        "GPU MTR Temp Sensor1": "GPU 1",
        "GPU MTR Temp Sensor4": "GPU 2",
        "ANE MTR Temp Sensor1": "Neural Engine",
        "ISP MTR Temp Sensor5": "ISP",
        "PMGR SOC Die Temp Sensor0": "SoC Die 1",
        "PMGR SOC Die Temp Sensor1": "SoC Die 2",
        "PMGR SOC Die Temp Sensor2": "SoC Die 3",
        "gas gauge battery": "Battery",
        "NAND CH0 temp": "SSD",
    ]

    // Sensors to skip (too many PMU internal sensors)
    private static let skipPrefixes = ["PMU tdie", "PMU tdev", "PMU2 tdie", "PMU2 tdev", "PMU tcal", "PMU2 tcal", "PMU TP3w"]

    func getTemperatures() -> TemperatureMetrics {
        var sensors: [TemperatureSensor] = []
        var seenNames = Set<String>()

        let client = IOHIDEventSystemClientCreate(kCFAllocatorDefault)

        // Match temperature sensors
        let matching: [String: Any] = [
            "PrimaryUsagePage": 0xFF00,  // kHIDPage_AppleVendor
            "PrimaryUsage": 0x0005,      // kHIDUsage_AppleVendor_TemperatureSensor
        ]
        IOHIDEventSystemClientSetMatching(client, matching as CFDictionary)

        guard let services = IOHIDEventSystemClientCopyServices(client) as? [AnyObject] else {
            return TemperatureMetrics()
        }

        for service in services {
            guard let event = IOHIDServiceClientCopyEvent(service, kIOHIDEventTypeTemperature, 0, 0) else {
                continue
            }

            let temperature = IOHIDEventGetFloatValue(event, kIOHIDEventFieldTemperatureLevel)

            // Get sensor name
            var rawName = "Unknown"
            if let product = IOHIDServiceClientCopyProperty(service, "Product" as CFString) {
                rawName = "\(product)"
            }

            // Skip invalid readings
            guard temperature > -100 && temperature < 150 else { continue }

            // Skip noisy PMU internal sensors
            let shouldSkip = Self.skipPrefixes.contains { rawName.hasPrefix($0) }
            guard !shouldSkip else { continue }

            let friendlyName = Self.sensorNameMap[rawName] ?? rawName

            // Deduplicate (keep first occurrence)
            guard !seenNames.contains(friendlyName) else { continue }
            seenNames.insert(friendlyName)

            let sensor = TemperatureSensor(id: rawName, name: friendlyName, temperature: temperature)
            sensors.append(sensor)
        }

        // Sort by name for consistent display
        sensors.sort { $0.name < $1.name }

        return TemperatureMetrics(sensors: sensors)
    }
}
