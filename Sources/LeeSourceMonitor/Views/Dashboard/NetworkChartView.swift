import SwiftUI
import Charts

struct NetworkChartView: View {
    let metrics: NetworkMetrics
    let inHistory: [MetricSample]
    let outHistory: [MetricSample]

    var body: some View {
        MetricCardView(title: "Network", icon: "network", accentColor: AppTheme.Colors.networkIn) {
            VStack(spacing: 12) {
                // Current speed
                HStack(spacing: 20) {
                    SpeedIndicator(
                        icon: "arrow.down.circle.fill",
                        label: "Download",
                        speed: Formatters.speed(metrics.speedIn),
                        color: AppTheme.Colors.networkIn
                    )

                    SpeedIndicator(
                        icon: "arrow.up.circle.fill",
                        label: "Upload",
                        speed: Formatters.speed(metrics.speedOut),
                        color: AppTheme.Colors.networkOut
                    )

                    Spacer()
                }

                // History chart
                let combinedHistory = inHistory.map { ($0, "Download") } + outHistory.map { ($0, "Upload") }

                if !combinedHistory.isEmpty {
                    Chart {
                        ForEach(inHistory) { sample in
                            AreaMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.networkIn.opacity(0.3), AppTheme.Colors.networkIn.opacity(0.05)],
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
                            AreaMark(
                                x: .value("Time", sample.timestamp),
                                y: .value("Speed", sample.value)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.Colors.networkOut.opacity(0.3), AppTheme.Colors.networkOut.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)

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
                                .font(.system(size: 8))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                    .frame(height: AppTheme.Dimensions.chartHeight)
                }

                // Total transferred
                HStack {
                    HStack(spacing: 4) {
                        Text("Total ↓")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Text(Formatters.bytes(metrics.bytesIn))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Total ↑")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                        Text(Formatters.bytes(metrics.bytesOut))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                    }
                }
            }
        }
    }
}

private struct SpeedIndicator: View {
    let icon: String
    let label: String
    let speed: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                Text(speed)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(color)
            }
        }
    }
}
