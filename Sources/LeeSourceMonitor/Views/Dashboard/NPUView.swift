import SwiftUI
import Charts

struct NPUView: View {
    let metrics: NPUMetrics
    let history: [MetricSample]

    var body: some View {
        MetricCardView(title: "Neural Engine", icon: "brain", accentColor: AppTheme.Colors.npuActive) {
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(Formatters.milliwatts(metrics.powerMilliwatts))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.npuActive)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(metrics.isActive ? Color.green : Color.gray.opacity(0.4))
                            .frame(width: 6, height: 6)
                        Text(metrics.isActive ? "Active" : "Idle")
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }

                    Spacer()
                }

                // Power history chart
                if !history.isEmpty {
                    Chart(history) { sample in
                        AreaMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Power", sample.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.npuActive.opacity(0.3),
                                    AppTheme.Colors.npuActive.opacity(0.05),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Power", sample.value)
                        )
                        .foregroundStyle(AppTheme.Colors.npuActive)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisValueLabel()
                                .font(.system(size: 8))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }
                    }
                    .frame(height: 80)
                }
            }
        }
    }
}
