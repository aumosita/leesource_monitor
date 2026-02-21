import SwiftUI
import Charts

struct GPUChartView: View {
    let metrics: GPUMetrics
    let history: [MetricSample]
    var compact: Bool = false

    var body: some View {
        MetricCardView(title: "GPU", icon: "gpu", accentColor: AppTheme.Colors.gpuGradientStart) {
            VStack(spacing: compact ? 6 : 12) {
                // Usage header
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(Formatters.percentage(metrics.deviceUtilization))
                            .font(.system(size: compact ? 20 : 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.gpuGradientStart, AppTheme.Colors.gpuGradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("R: \(Formatters.percentage(metrics.rendererUtilization))")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.gpuGradientStart.opacity(0.7))
                        Text("T: \(Formatters.percentage(metrics.tilerUtilization))")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.gpuGradientEnd.opacity(0.7))
                    }

                    Spacer()
                }

                // History chart
                if !history.isEmpty {
                    Chart(history) { sample in
                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.Colors.gpuGradientStart, AppTheme.Colors.gpuGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))

                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.gpuGradientStart.opacity(0.2),
                                    AppTheme.Colors.gpuGradientEnd.opacity(0.02),
                                ],
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
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // Memory info
                HStack {
                    HStack(spacing: 3) {
                        Text("VRAM")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Text(Formatters.bytes(metrics.inUseSystemMemory))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                    }
                    Spacer()
                }
            }
        }
    }
}
