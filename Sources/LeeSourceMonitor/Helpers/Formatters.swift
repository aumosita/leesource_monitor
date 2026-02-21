import Foundation

struct Formatters {
    static func bytes(_ value: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(value))
    }

    static func bytesDecimal(_ value: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: Int64(value))
    }

    static func speed(_ bytesPerSec: Double) -> String {
        if bytesPerSec < 1024 {
            return String(format: "%.0f B/s", bytesPerSec)
        } else if bytesPerSec < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSec / 1024)
        } else if bytesPerSec < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSec / (1024 * 1024))
        } else {
            return String(format: "%.2f GB/s", bytesPerSec / (1024 * 1024 * 1024))
        }
    }

    static func temperature(_ celsius: Double) -> String {
        String(format: "%.1f°C", celsius)
    }

    static func percentage(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }

    static func gigabytes(_ gb: Double) -> String {
        String(format: "%.1f GB", gb)
    }

    static func milliwatts(_ mw: Double) -> String {
        if mw < 1000 {
            return String(format: "%.0f mW", mw)
        } else {
            return String(format: "%.1f W", mw / 1000)
        }
    }
}
