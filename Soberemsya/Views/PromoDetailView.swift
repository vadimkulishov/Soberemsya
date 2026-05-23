import SwiftUI

struct PromoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let promo: PromoItem

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                heroCard
                infoCard
                actionCard
            }
            .padding(16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea())
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .top) {
            topBar
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: promo.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            LinearGradient(
                colors: [.white.opacity(0.22), .clear, .black.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: promo.icon)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Spacer()

                    Text(promoTypeTitle)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.92))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.14), in: Capsule())
                }

                Spacer()

                Text(promo.title)
                    .font(.system(size: 31, weight: .bold))
                    .foregroundColor(.white)

                Text(promo.subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
        }
        .frame(height: 320)
        .shadow(color: promo.accentColor.opacity(colorScheme == .dark ? 0.28 : 0.18), radius: 18, x: 0, y: 10)
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Что внутри")
                .font(DesignConstants.Typography.headline)
                .foregroundColor(DesignConstants.Colors.textPrimary)

            PromoInfoRow(icon: "sparkles", title: "Спецпредложение", value: promo.title, color: promo.accentColor)
            PromoInfoRow(icon: "text.alignleft", title: "Описание", value: promo.subtitle, color: promo.accentColor)
            PromoInfoRow(icon: "square.grid.2x2.fill", title: "Категория", value: promoTypeTitle, color: promo.accentColor)
        }
        .padding(18)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дальше")
                .font(DesignConstants.Typography.headline)
                .foregroundColor(DesignConstants.Colors.textPrimary)

            Text("Это промо можно использовать как вход в будущие акции, подборки событий или партнёрские предложения.")
                .font(DesignConstants.Typography.subheadline)
                .foregroundColor(DesignConstants.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                dismiss()
            } label: {
                Text("Закрыть")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(promo.accentColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .foregroundColor(.white)
            }
        }
        .padding(18)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var promoTypeTitle: String {
        switch promo.type {
        case .discount:
            return "СКИДКА"
        case .newFeature:
            return "НОВОЕ"
        case .partnership:
            return "ПАРТНЕРЫ"
        case .seasonal:
            return "СЕЗОН"
        case .advertisement:
            return "ПРОМО"
        }
    }
}

private struct PromoInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(DesignConstants.Typography.caption)
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                Text(value)
                    .font(DesignConstants.Typography.subheadline)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    PromoDetailView(promo: PromoItem.samplePromos[0])
}
