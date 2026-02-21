import SwiftUI
import Charts

struct NetworkChartView: View {
    let metrics: NetworkMetrics
    let inHistory: [MetricSample]
    let outHistory: [MetricSample]
    var compact: Bool = false

    var body: some View {
        MetricCardView(title: "Network", icon: "network", accentColor: AppTheme.Colors.networkIn) {
            VStack(spacing: compact ? 6 : 12) {
                // Current speed
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                        Text(Formatters.speed(metrics.speedIn))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.Colors.networkOut)
                        Text(Formatters.speed(metrics.speedOut))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.networkOut)
                    }

                    Spacer()
                }

                // History chart
                if !inHistory.isEmpty || !outHistory.isEmpty {
                    Chart {
                        ForEach(inHistory) { sample in
                            AreaMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.networkIn.opacity(0.25), AppTheme.Colors.networkIn.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)

                            LineMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value)
                            )
                            .foregroundStyle(AppTheme.Colors.networkIn)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                        }

                        ForEach(outHistory) { sample in
                            LineMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value)
                            )
                            .foregroundStyle(AppTheme.Colors.networkOut)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel()
                                .font(.system(size: 7))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // Total transferred
                HStack {
                    HStack(spacing: 3) {
                        Text("↓")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                        Text(Formatters.bytes(metrics.bytesIn))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        Text("↑")
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.Colors.networkOut)
                        Text(Formatters.bytes(metrics.bytesOut))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                    }
                }
            }
        }
    }
}
