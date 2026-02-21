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

                // Download bars
                if !inHistory.isEmpty {
                    Chart(inHistory) { sample in
                        BarMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Speed", sample.value)
                        )
                        .foregroundStyle(AppTheme.Colors.networkIn)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight / 2)
                }

                // Upload bars
                if !outHistory.isEmpty {
                    Chart(outHistory) { sample in
                        BarMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Speed", sample.value)
                        )
                        .foregroundStyle(AppTheme.Colors.networkOut)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: AppTheme.Dimensions.chartHeight / 2)
                }

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
