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
                // Breakdown bar
                GeometryReader { geometry in
                    let w = geometry.size.width
                    let total = max(Double(metrics.totalBytes), 1)

                    HStack(spacing: 1) {
                        Rectangle()
                            .fill(Color.cyan)
                            .frame(width: max(w * Double(metrics.activeBytes) / total, 0))
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: max(w * Double(metrics.wiredBytes) / total, 0))
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: max(w * Double(metrics.compressedBytes) / total, 0))
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: max(w * Double(metrics.inactiveBytes) / total, 0))
                        Spacer(minLength: 0)
                    }
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
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // R/W
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
