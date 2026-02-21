import SwiftUI
import Charts

struct MemoryChartView: View {
    let metrics: MemoryMetrics
    let pressureHistory: [MetricSample]
    let readHistory: [MetricSample]
    let writeHistory: [MetricSample]

    private var totalGB: Double { Double(metrics.totalBytes) / 1_073_741_824 }
    private var usedGB: Double { Double(metrics.usedBytes) / 1_073_741_824 }
    private var activeGB: Double { Double(metrics.activeBytes) / 1_073_741_824 }
    private var wiredGB: Double { Double(metrics.wiredBytes) / 1_073_741_824 }
    private var compressedGB: Double { Double(metrics.compressedBytes) / 1_073_741_824 }
    private var freeGB: Double { Double(metrics.freeBytes) / 1_073_741_824 }

    var body: some View {
        MetricCardView(title: "Memory", icon: "memorychip", accentColor: .cyan) {
            VStack(spacing: 14) {
                // Usage summary
                HStack(alignment: .firstTextBaseline) {
                    Text(Formatters.percentage(metrics.pressure))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.usageColor(metrics.pressure))

                    Text("\(String(format: "%.1f", usedGB)) / \(String(format: "%.1f", totalGB)) GB")
                        .font(.system(size: 11))
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
                            .fill(Color(hue: 0.55, saturation: 0.7, brightness: 0.85))  // Active - cyan
                            .frame(width: max(activeW, 0))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hue: 0.08, saturation: 0.7, brightness: 0.85))  // Wired - orange
                            .frame(width: max(wiredW, 0))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hue: 0.75, saturation: 0.5, brightness: 0.85))  // Compressed - purple
                            .frame(width: max(compressedW, 0))
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))  // Inactive
                            .frame(width: max(inactiveW, 0))
                        Spacer(minLength: 0)
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 8)

                // Legend
                HStack(spacing: 12) {
                    MemoryLegend(color: Color(hue: 0.55, saturation: 0.7, brightness: 0.85),
                                 label: "Active", value: String(format: "%.1f GB", activeGB))
                    MemoryLegend(color: Color(hue: 0.08, saturation: 0.7, brightness: 0.85),
                                 label: "Wired", value: String(format: "%.1f GB", wiredGB))
                    MemoryLegend(color: Color(hue: 0.75, saturation: 0.5, brightness: 0.85),
                                 label: "Compressed", value: String(format: "%.1f GB", compressedGB))
                    MemoryLegend(color: Color.gray.opacity(0.4),
                                 label: "Free", value: String(format: "%.1f GB", freeGB))
                }

                // Memory pressure history chart
                if !pressureHistory.isEmpty {
                    Text("Memory Pressure")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Chart(pressureHistory) { sample in
                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Pressure", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Pressure", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.25), Color.blue.opacity(0.05)],
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
                                    .font(.system(size: 9))
                                    .foregroundStyle(AppTheme.Colors.textTertiary)
                            }
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                .foregroundStyle(AppTheme.Colors.textTertiary.opacity(0.3))
                        }
                    }
                    .chartXAxis(.hidden)
                    .frame(height: 80)
                }

                // Read/Write activity
                if !readHistory.isEmpty || !writeHistory.isEmpty {
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.green)
                            Text("Read")
                                .font(.system(size: 9))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                            Text(Formatters.speed(metrics.readBytesPerSec))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.green)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.orange)
                            Text("Write")
                                .font(.system(size: 9))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                            Text(Formatters.speed(metrics.writeBytesPerSec))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.orange)
                        }

                        Spacer()
                    }

                    Chart {
                        ForEach(readHistory) { sample in
                            LineMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value),
                                series: .value("Type", "Read")
                            )
                            .foregroundStyle(.green)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                        }

                        ForEach(writeHistory) { sample in
                            LineMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value),
                                series: .value("Type", "Write")
                            )
                            .foregroundStyle(.orange)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel()
                                .font(.system(size: 8))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                    .frame(height: 60)
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
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.system(size: 8))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                Text(value)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
            }
        }
    }
}
