import Foundation

final class DiskMonitor: Sendable {

    func getDiskUsage() -> DiskMetrics {
        var volumes: [DiskVolume] = []

        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeIsLocalKey,
            .volumeIsInternalKey,
        ]

        guard let mountedVolumeURLs = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: keys,
            options: [.skipHiddenVolumes]
        ) else {
            return DiskMetrics()
        }

        for url in mountedVolumeURLs {
            guard let resources = try? url.resourceValues(forKeys: Set(keys)) else {
                continue
            }

            let isLocal = resources.volumeIsLocal ?? false
            guard isLocal else { continue }

            let name = resources.volumeName ?? url.lastPathComponent
            let total = resources.volumeTotalCapacity ?? 0
            let available = resources.volumeAvailableCapacityForImportantUsage ?? 0

            let totalGB = Double(total) / 1_073_741_824
            let usedGB = Double(total - Int(available)) / 1_073_741_824

            guard totalGB > 0 else { continue }

            let volume = DiskVolume(
                name: name,
                mountPoint: url.path,
                totalGB: totalGB,
                usedGB: usedGB
            )
            volumes.append(volume)
        }

        return DiskMetrics(volumes: volumes)
    }
}
