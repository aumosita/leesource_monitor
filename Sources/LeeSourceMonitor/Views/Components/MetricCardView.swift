import SwiftUI

struct MetricCardView<Content: View>: View {
    let title: String
    let icon: String
    let accentColor: Color
    var valueText: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accentColor)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                if let valueText {
                    Spacer()
                    Text(valueText)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor)
                }

                if valueText == nil {
                    Spacer()
                }
            }

            content()
        }
        .padding(AppTheme.Dimensions.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: AppTheme.Dimensions.cardCornerRadius)
                .fill(AppTheme.Colors.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Dimensions.cardCornerRadius)
                        .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                }
        }
    }
}

struct MiniGauge: View {
    let value: Double
    let maxValue: Double
    let color: Color
    var lineWidth: CGFloat = 4
    var size: CGFloat = 32

    private var progress: Double {
        min(value / maxValue, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text(Formatters.percentage(value))
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(width: size, height: size)
    }
}

struct UsageBar: View {
    let value: Double
    let maxValue: Double
    let color: Color
    var height: CGFloat = 6

    private var progress: Double {
        min(value / maxValue, 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.15))

                Capsule()
                    .fill(color)
                    .frame(width: max(geometry.size.width * progress, 0))
            }
        }
        .frame(height: height)
    }
}
