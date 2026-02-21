import SwiftUI
import Charts

struct NetworkChartView: View {
    let metrics: NetworkMetrics
    let inHistory: [MetricSample]
    let outHistory: [MetricSample]
    var compact: Bool = false

    var body: some View {
        MetricCardView(title: "Network", icon: "network", accentColor: AppTheme.Colors.networkIn) {
            VStack(spacing: 4) {
                // Speed inline
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Text("↓")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                        Text(Formatters.speed(metrics.speedIn))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.networkIn)
                    }
                    HStack(spacing: 3) {
                        Text("↑")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.networkOut)
                        Text(Formatters.speed(metrics.speedOut))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.networkOut)
                    }
                    Spacer()
                }

                // Chart
                if !inHistory.isEmpty || !outHistory.isEmpty {
                    Chart {
                        ForEach(inHistory) { sample in
                            AreaMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.networkIn.opacity(0.2), .clear],
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
                    .chartYAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // Totals
                HStack {
                    Text("↓\(Formatters.bytes(metrics.bytesIn))")
                        .font(.system(size: 8, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                    Spacer()
                    Text("↑\(Formatters.bytes(metrics.bytesOut))")
                        .font(.system(size: 8, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
        }
    }
}
