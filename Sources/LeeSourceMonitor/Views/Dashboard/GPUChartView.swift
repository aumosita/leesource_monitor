import SwiftUI
import Charts

struct GPUChartView: View {
    let metrics: GPUMetrics
    let history: [MetricSample]
    var compact: Bool = false

    var body: some View {
        MetricCardView(
            title: "GPU",
            icon: "gpu",
            accentColor: AppTheme.Colors.gpuGradientStart,
            valueText: Formatters.percentage(metrics.deviceUtilization)
        ) {
            VStack(spacing: 4) {
                // Sub-stats inline
                HStack(spacing: 8) {
                    Text("R:\(Formatters.percentage(metrics.rendererUtilization))")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Text("T:\(Formatters.percentage(metrics.tilerUtilization))")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Text("VRAM:\(Formatters.bytes(metrics.inUseSystemMemory))")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Spacer()
                }

                // History chart
                if !history.isEmpty {
                    Chart(history) { sample in
                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(AppTheme.Colors.gpuGradientStart)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))

                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.gpuGradientStart.opacity(0.2), .clear],
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
            }
        }
    }
}
