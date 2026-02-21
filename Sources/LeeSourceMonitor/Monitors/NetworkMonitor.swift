import Foundation
import Darwin

final class NetworkMonitor: Sendable {

    struct NetworkSnapshot: Sendable {
        var bytesIn: UInt64 = 0
        var bytesOut: UInt64 = 0
        var timestamp: Date = Date()
    }

    func getNetworkUsage(previous: NetworkSnapshot?) -> (metrics: NetworkMetrics, snapshot: NetworkSnapshot) {
        var totalIn: UInt64 = 0
        var totalOut: UInt64 = 0

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            let snap = NetworkSnapshot()
            return (NetworkMetrics(), snap)
        }
        defer { freeifaddrs(ifaddr) }

        var ptr = firstAddr
        while true {
            let flags = Int32(ptr.pointee.ifa_flags)
            let isUp = (flags & IFF_UP) != 0
            let isLoopback = (flags & IFF_LOOPBACK) != 0

            if isUp && !isLoopback {
                if ptr.pointee.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                    ptr.pointee.ifa_data.withMemoryRebound(to: if_data.self, capacity: 1) { data in
                        totalIn += UInt64(data.pointee.ifi_ibytes)
                        totalOut += UInt64(data.pointee.ifi_obytes)
                    }
                }
            }

            guard let next = ptr.pointee.ifa_next else { break }
            ptr = next
        }

        let now = Date()
        let snapshot = NetworkSnapshot(bytesIn: totalIn, bytesOut: totalOut, timestamp: now)

        var speedIn: Double = 0
        var speedOut: Double = 0

        if let prev = previous {
            let elapsed = now.timeIntervalSince(prev.timestamp)
            if elapsed > 0 {
                let deltaIn = totalIn >= prev.bytesIn ? totalIn - prev.bytesIn : 0
                let deltaOut = totalOut >= prev.bytesOut ? totalOut - prev.bytesOut : 0
                speedIn = Double(deltaIn) / elapsed
                speedOut = Double(deltaOut) / elapsed
            }
        }

        let metrics = NetworkMetrics(
            bytesIn: totalIn,
            bytesOut: totalOut,
            speedIn: speedIn,
            speedOut: speedOut
        )

        return (metrics, snapshot)
    }
}
