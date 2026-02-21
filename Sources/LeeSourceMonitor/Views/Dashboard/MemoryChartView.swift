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
    private var activeGB: Double { Double(metrics.activeBytes) / 1_073_741_824 }
    private var wiredGB: Double { Double(metrics.wiredBytes) / 1_073_741_824 }
    private var compressedGB: Double { Double(metrics.compressedBytes) / 1_073_741_824 }
    private var freeGB: Double { Double(metrics.freeBytes) / 1_073_741_824 }

    var body: some View {
        MetricCardView(title: "Memory", icon: "memorychip", accentColor: .cyan) {
            VStack(spacing: compact ? 6 : 12) {
                // Usage summary
                HStack(alignment: .firstTextBaseline) {
                    Text(Formatters.percentage(metrics.pressure))
                        .font(.system(size: compact ? 20 : 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.usageColor(metrics.pressure))

                    Text("\(String(format: "%.1f", usedGB)) / \(String(format: "%.0f", totalGB)) GB")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.Colors.textTertiary)

                    Spacer()
                }

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
                .frame(height: 6)

                // Legend (compact)
                HStack(spacing: 8) {
                    MemoryLegend(color: Color(hue: 0.55, saturation: 0.7, brightness: 0.85),
                                 label: "Act", value: String(format: "%.1f", activeGB))
                    MemoryLegend(color: Color(hue: 0.08, saturation: 0.7, brightness: 0.85),
                                 label: "Wir", value: String(format: "%.1f", wiredGB))
                    MemoryLegend(color: Color(hue: 0.75, saturation: 0.5, brightness: 0.85),
                                 label: "Cmp", value: String(format: "%.1f", compressedGB))
                    MemoryLegend(color: Color.gray.opacity(0.4),
                                 label: "Free", value: String(format: "%.1f", freeGB))
                }

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
                                colors: [Color.cyan.opacity(0.2), Color.cyan.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxis {
                        AxisMarks(values: [0, 50, 100]) { value in
                            AxisValueLabel {
                                Text("\(value.as(Int.self) ?? 0)%")
                                    .font(.system(size: 8))
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .foregroundStyle(AppTheme.Colors.textTertiary.opacity(0.3))
                        }
                    }
                    .chartXAxis(.hidden)
                    .frame(height: compact ? 50 : 80)
                }

                // Read/Write
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.green)
                        Text(Formatters.speed(metrics.readBytesPerSec))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.green)
                    }

                    HStack(spacing: 3) {
                        Image(systemName: "arrow.up.doc.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                        Text(Formatters.speed(metrics.writeBytesPerSec))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.orange)
                    }

                    Spacer()
                }
            }
        }
    }
}

private struct MemoryLegend: View {
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            Text("\(label) \(value)")
                .font(.system(size: 8, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }
}
