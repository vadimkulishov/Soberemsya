import SwiftUI

struct PromoCardComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let promo: PromoItem
    var onTap: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
                onTap?()
            }
        }) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: promo.gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(colorScheme == .dark ? 0.8 : 1.0)

                LinearGradient(
                    colors: [.white.opacity(0.18), .clear, .black.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: promo.icon)
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundColor(.white.opacity(0.95))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(promo.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Text(promo.subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }
                .padding(20)
            }
            .frame(height: 188)
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.largeCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignConstants.largeCornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.08 : 0.22), lineWidth: 1)
            )
            .shadow(
                color: promo.accentColor.opacity(colorScheme == .dark ? 0.3 : 0.25),
                radius: isPressed ? 8 : 12,
                x: 0,
                y: isPressed ? 3 : 7
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CompactPromoCardComponent: View {
    @Environment(\.colorScheme) var colorScheme
    let promo: PromoItem
    var onTap: (() -> Void)? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
                onTap?()
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: promo.gradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: promo.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(promo.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                        .lineLimit(1)
                    
                    Text(promo.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textTertiary)
            }
            .padding(16)
            .background(
                DesignConstants.Colors.cardBackground(colorScheme: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(promo.accentColor.opacity(0.15), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Large Promo Card") {
    VStack(spacing: 20) {
        PromoCardComponent(promo: PromoItem.samplePromos[0])
            .frame(width: 300)
        
        PromoCardComponent(promo: PromoItem.samplePromos[1])
            .frame(width: 300)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact Promo Card") {
    VStack(spacing: 12) {
        ForEach(PromoItem.samplePromos) { promo in
            CompactPromoCardComponent(promo: promo)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
