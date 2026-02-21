import SwiftUI

enum AppTheme {

    // MARK: - Colors
    enum Colors {
        static let background = Color(nsColor: .windowBackgroundColor)
        static let cardBackground = Color(nsColor: .controlBackgroundColor)
        static let cardBorder = Color.white.opacity(0.06)

        static let cpuGradientStart = Color(hue: 0.55, saturation: 0.7, brightness: 0.9)  // Cyan
        static let cpuGradientEnd = Color(hue: 0.65, saturation: 0.8, brightness: 0.85)    // Blue

        static let gpuGradientStart = Color(hue: 0.8, saturation: 0.6, brightness: 0.9)    // Purple
        static let gpuGradientEnd = Color(hue: 0.9, saturation: 0.7, brightness: 0.85)     // Magenta

        static let networkIn = Color(hue: 0.35, saturation: 0.7, brightness: 0.8)           // Green
        static let networkOut = Color(hue: 0.08, saturation: 0.8, brightness: 0.9)          // Orange

        static let diskUsed = Color(hue: 0.6, saturation: 0.5, brightness: 0.8)             // Soft blue
        static let diskFree = Color(hue: 0.55, saturation: 0.15, brightness: 0.3)           // Dark grey-blue

        static let npuActive = Color(hue: 0.45, saturation: 0.7, brightness: 0.85)          // Teal

        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color.secondary.opacity(0.6)

        // Temperature sensor colors - vibrant palette
        static let sensorColors: [Color] = [
            Color(hue: 0.0, saturation: 0.7, brightness: 0.9),   // Red
            Color(hue: 0.08, saturation: 0.8, brightness: 0.9),  // Orange
            Color(hue: 0.15, saturation: 0.7, brightness: 0.9),  // Gold
            Color(hue: 0.25, saturation: 0.6, brightness: 0.85), // Yellow-green
            Color(hue: 0.35, saturation: 0.7, brightness: 0.8),  // Green
            Color(hue: 0.45, saturation: 0.7, brightness: 0.85), // Teal
            Color(hue: 0.55, saturation: 0.7, brightness: 0.9),  // Cyan
            Color(hue: 0.6, saturation: 0.6, brightness: 0.85),  // Sky blue
            Color(hue: 0.65, saturation: 0.7, brightness: 0.85), // Blue
            Color(hue: 0.75, saturation: 0.6, brightness: 0.85), // Indigo
            Color(hue: 0.8, saturation: 0.5, brightness: 0.9),   // Purple
            Color(hue: 0.9, saturation: 0.5, brightness: 0.9),   // Pink
            Color(hue: 0.95, saturation: 0.4, brightness: 0.85), // Rose
            Color(hue: 0.1, saturation: 0.5, brightness: 0.95),  // Peach
            Color(hue: 0.3, saturation: 0.5, brightness: 0.7),   // Olive
            Color(hue: 0.5, saturation: 0.4, brightness: 0.7),   // Slate
        ]

        static func sensorColor(at index: Int) -> Color {
            sensorColors[index % sensorColors.count]
        }

        static func usageColor(_ percent: Double) -> Color {
            if percent < 50 {
                return Color(hue: 0.35, saturation: 0.6 + percent * 0.004, brightness: 0.8)
            } else if percent < 80 {
                return Color(hue: 0.15 - (percent - 50) * 0.004, saturation: 0.7, brightness: 0.85)
            } else {
                return Color(hue: 0.0, saturation: 0.6 + (percent - 80) * 0.01, brightness: 0.85)
            }
        }
    }

    // MARK: - Dimensions
    enum Dimensions {
        static let cardCornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 16
        static let gridSpacing: CGFloat = 12
        static let chartHeight: CGFloat = 120
        static let menuBarWidth: CGFloat = 320
    }
}
