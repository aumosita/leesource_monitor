import SwiftUI
import Charts

struct GPUChartView: View {
    let metrics: GPUMetrics
    let history: [MetricSample]

    var body: some View {
        MetricCardView(title: "GPU", icon: "gpu", accentColor: AppTheme.Colors.gpuGradientStart) {
            VStack(spacing: 12) {
                // Usage header
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Formatters.percentage(metrics.deviceUtilization))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.gpuGradientStart, AppTheme.Colors.gpuGradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Device")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(Formatters.percentage(metrics.rendererUtilization))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.gpuGradientStart.opacity(0.8))
                        Text("Renderer")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(Formatters.percentage(metrics.tilerUtilization))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.gpuGradientEnd.opacity(0.8))
                        Text("Tiler")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
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
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Usage", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.gpuGradientStart.opacity(0.25),
                                    AppTheme.Colors.gpuGradientEnd.opacity(0.05),
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
                                    .font(.system(size: 9))
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
                    HStack(spacing: 4) {
                        Text("VRAM In Use")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Text(Formatters.bytes(metrics.inUseSystemMemory))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Allocated")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Text(Formatters.bytes(metrics.allocatedSystemMemory))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                }
            }
        }
    }
}
