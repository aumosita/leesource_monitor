import SwiftUI

struct DiskView: View {
    let metrics: DiskMetrics

    var body: some View {
        MetricCardView(
            title: "Disk",
            icon: "internaldrive",
            accentColor: AppTheme.Colors.diskUsed,
            valueText: metrics.volumes.first.map { Formatters.percentage($0.usagePercent) }
        ) {
            VStack(spacing: 4) {
                ForEach(metrics.volumes) { volume in
                    HStack(spacing: 8) {
                        // Mini donut
                        ZStack {
                            Circle()
                                .stroke(AppTheme.Colors.diskFree, lineWidth: 4)
                            Circle()
                                .trim(from: 0, to: volume.usagePercent / 100)
                                .stroke(
                                    AppTheme.Colors.usageColor(volume.usagePercent),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(width: 30, height: 30)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(volume.name)
                                .font(.system(size: 10, weight: .medium))
                                .lineLimit(1)
                            Text("\(Formatters.gigabytes(volume.usedGB)) / \(Formatters.gigabytes(volume.totalGB))")
                                .font(.system(size: 9, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.textTertiary)
                        }

                        Spacer()

                        Text("\(Formatters.gigabytes(volume.freeGB)) free")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                }

                if metrics.volumes.isEmpty {
                    Text("No volumes")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
        }
    }
}
