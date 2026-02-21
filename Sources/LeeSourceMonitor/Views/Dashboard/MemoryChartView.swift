import SwiftUI
import Charts

struct MemoryChartView: View {
    let metrics: MemoryMetrics
    let pressureHistory: [MetricSample]
    let readHistory: [MetricSample]
    let writeHistory: [MetricSample]
    var compact: Bool = false

    private var totalGB: Double { Double(metrics.totalBytes) / 1_073_741_824 }
    private var usedGB: Double { Double(metrics.usedBytes) / 1_073_741_824 }

    var body: some View {
        MetricCardView(
            title: "Memory",
            icon: "memorychip",
            accentColor: .cyan,
            valueText: "\(String(format: "%.1f", usedGB))/\(String(format: "%.0f", totalGB))GB"
        ) {
            VStack(spacing: 4) {
                // Memory breakdown bar
                GeometryReader { geometry in
                    let w = geometry.size.width
                    let total = max(Double(metrics.totalBytes), 1)
                    let activeW = w * Double(metrics.activeBytes) / total
                    let wiredW = w * Double(metrics.wiredBytes) / total
                    let compressedW = w * Double(metrics.compressedBytes) / total
                    let inactiveW = w * Double(metrics.inactiveBytes) / total

                    HStack(spacing: 1) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hue: 0.55, saturation: 0.7, brightness: 0.85))
                            .frame(width: max(activeW, 0))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hue: 0.08, saturation: 0.7, brightness: 0.85))
                            .frame(width: max(wiredW, 0))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hue: 0.75, saturation: 0.5, brightness: 0.85))
                            .frame(width: max(compressedW, 0))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: max(inactiveW, 0))
                        Spacer(minLength: 0)
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 5)

                // Pressure chart
                if !pressureHistory.isEmpty {
                    Chart(pressureHistory) { sample in
                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Pressure", sample.value)
                        )
                        .foregroundStyle(.cyan)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))

                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Pressure", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // R/W inline
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Text("R:")
                            .font(.system(size: 8))
                            .foregroundStyle(.green.opacity(0.7))
                        Text(Formatters.speed(metrics.readBytesPerSec))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.green)
                    }
                    HStack(spacing: 2) {
                        Text("W:")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange.opacity(0.7))
                        Text(Formatters.speed(metrics.writeBytesPerSec))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    Text(Formatters.percentage(metrics.pressure))
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.usageColor(metrics.pressure))
                }
            }
        }
    }
}
