import SwiftUI

struct MetricCardView<Content: View>: View {
    let title: String
    let icon: String
    let accentColor: Color
    var valueText: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accentColor)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .fixedSize()

                Spacer(minLength: 2)

                if let valueText {
                    Text(valueText)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(accentColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
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
        .transaction { $0.animation = nil }
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
