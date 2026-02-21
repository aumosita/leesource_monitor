import SwiftUI
import Charts

struct MemoryChartView: View {
    let metrics: MemoryMetrics
    let pressureHistory: [MetricSample]
    let readHistory: [MetricSample]
    let writeHistory: [MetricSample]
    var expanded: Bool = false

    private var totalGB: Double { Double(metrics.totalBytes) / 1_073_741_824 }
    private var usedGB: Double { Double(metrics.usedBytes) / 1_073_741_824 }
    private var activeGB: Double { Double(metrics.activeBytes) / 1_073_741_824 }
    private var wiredGB: Double { Double(metrics.wiredBytes) / 1_073_741_824 }
    private var compressedGB: Double { Double(metrics.compressedBytes) / 1_073_741_824 }
    private var freeGB: Double { Double(metrics.freeBytes) / 1_073_741_824 }
    private var chartHeight: CGFloat { expanded ? 100 : AppTheme.Dimensions.chartHeight }

    var body: some View {
        MetricCardView(
            title: "Memory",
            icon: "memorychip",
            accentColor: .cyan,
            valueText: "\(String(format: "%.1f", usedGB))/\(String(format: "%.0f", totalGB))GB"
        ) {
            VStack(spacing: expanded ? 8 : 4) {
                // Breakdown bar
                GeometryReader { geometry in
                    let w = geometry.size.width
                    let total = max(Double(metrics.totalBytes), 1)
                    HStack(spacing: 1) {
                        Rectangle().fill(Color.cyan)
                            .frame(width: max(w * Double(metrics.activeBytes) / total, 0))
                        Rectangle().fill(Color.orange)
                            .frame(width: max(w * Double(metrics.wiredBytes) / total, 0))
                        Rectangle().fill(Color.purple)
                            .frame(width: max(w * Double(metrics.compressedBytes) / total, 0))
                        Rectangle().fill(Color.gray.opacity(0.3))
                            .frame(width: max(w * Double(metrics.inactiveBytes) / total, 0))
                        Spacer(minLength: 0)
                    }
                }
                .frame(height: 5)

                // Legend when expanded
                if expanded {
                    HStack(spacing: 10) {
                        MemLegendItem(color: .cyan, label: "Active", value: String(format: "%.1fGB", activeGB))
                        MemLegendItem(color: .orange, label: "Wired", value: String(format: "%.1fGB", wiredGB))
                        MemLegendItem(color: .purple, label: "Compressed", value: String(format: "%.1fGB", compressedGB))
                        MemLegendItem(color: .gray.opacity(0.5), label: "Free", value: String(format: "%.1fGB", freeGB))
                    }
                }

                // Pressure chart
                Chart(pressureHistory) { sample in
                    LineMark(
                        x: .value("Time", sample.timestamp),
                        y: .value("Pressure", sample.value)
                    )
                    .foregroundStyle(.cyan)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
                .chartYScale(domain: 0...100)
                .chartYAxis(expanded ? .automatic : .hidden)
                .chartXAxis(.hidden)
                .frame(height: chartHeight)

                // R/W
                HStack(spacing: expanded ? 16 : 6) {
                    HStack(spacing: 2) {
                        Text("R:")
                            .font(.system(size: 8))
                            .foregroundStyle(.green.opacity(0.7))
                        Text(Formatters.speed(metrics.readBytesPerSec))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.green)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    HStack(spacing: 2) {
                        Text("W:")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange.opacity(0.7))
                        Text(Formatters.speed(metrics.writeBytesPerSec))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                    Text(Formatters.percentage(metrics.pressure))
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.usageColor(metrics.pressure))
                        .lineLimit(1)
                }
                .frame(height: 14)
            }
        }
    }
}

private struct MemLegendItem: View {
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text("\(label) \(value)")
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}
