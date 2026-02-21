import SwiftUI
import Charts

struct DiskView: View {
    let metrics: DiskMetrics

    var body: some View {
        MetricCardView(title: "Disk", icon: "internaldrive", accentColor: AppTheme.Colors.diskUsed) {
            VStack(spacing: 12) {
                ForEach(metrics.volumes) { volume in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(volume.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.Colors.textPrimary)

                            Spacer()

                            Text(Formatters.percentage(volume.usagePercent))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.usageColor(volume.usagePercent))
                        }

                        // Donut chart
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(AppTheme.Colors.diskFree, lineWidth: 8)

                                Circle()
                                    .trim(from: 0, to: volume.usagePercent / 100)
                                    .stroke(
                                        AppTheme.Colors.usageColor(volume.usagePercent),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))

                                VStack(spacing: 1) {
                                    Text(Formatters.gigabytes(volume.usedGB))
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                    Text("used")
                                        .font(.system(size: 8))
                                        .foregroundStyle(AppTheme.Colors.textTertiary)
                                }
                            }
                            .frame(width: 70, height: 70)

                            VStack(alignment: .leading, spacing: 6) {
                                DiskInfoRow(label: "Total", value: Formatters.gigabytes(volume.totalGB))
                                DiskInfoRow(label: "Used", value: Formatters.gigabytes(volume.usedGB))
                                DiskInfoRow(label: "Free", value: Formatters.gigabytes(volume.freeGB))
                            }

                            Spacer()
                        }
                    }
                }

                if metrics.volumes.isEmpty {
                    Text("No volumes found")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
        }
    }
}

private struct DiskInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.Colors.textTertiary)
                .frame(width: 32, alignment: .leading)
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }
}
