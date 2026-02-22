import SwiftUI
import Charts

struct GPUChartView: View {
    let metrics: GPUMetrics
    let history: [MetricSample]
    var expanded: Bool = false

    private var chartHeight: CGFloat { expanded ? 120 : AppTheme.Dimensions.chartHeight }

    var body: some View {
        MetricCardView(
            title: "GPU",
            icon: "gpu",
            accentColor: AppTheme.Colors.gpuGradientStart,
            valueText: Formatters.percentage(metrics.deviceUtilization)
        ) {
            VStack(spacing: expanded ? 8 : 4) {
                HStack(spacing: 4) {
                    Text("Renderer:")
                        .font(.system(size: expanded ? 10 : 9))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Text(Formatters.percentage(metrics.rendererUtilization))
                        .font(.system(size: expanded ? 10 : 9, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .frame(width: 38, alignment: .leading)
                    Text("Tiler:")
                        .font(.system(size: expanded ? 10 : 9))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Text(Formatters.percentage(metrics.tilerUtilization))
                        .font(.system(size: expanded ? 10 : 9, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Spacer()
                }

                Chart(history) { sample in
                    LineMark(
                        x: .value("Time", sample.timestamp),
                        y: .value("Usage", sample.value)
                    )
                    .foregroundStyle(AppTheme.Colors.gpuGradientStart)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                }
                .chartYScale(domain: 0...100)
                .chartYAxis(expanded ? .automatic : .hidden)
                .chartXAxis(.hidden)
                .frame(height: chartHeight)

                HStack {
                    Text("VRAM:")
                        .font(.system(size: expanded ? 10 : 9))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Text(Formatters.bytes(metrics.inUseSystemMemory))
                        .font(.system(size: expanded ? 10 : 9, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Spacer()
                }
            }
        }
    }
}
