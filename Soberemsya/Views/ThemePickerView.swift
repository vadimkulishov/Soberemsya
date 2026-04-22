import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ForEach(AppTheme.allCases) { theme in
                        ThemeOptionCard(
                            theme: theme,
                            isSelected: themeManager.selectedTheme == theme,
                            colorScheme: colorScheme
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                themeManager.setTheme(theme)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .navigationTitle("Тема оформления")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(DesignConstants.Colors.primary)
                }
            }
        }
    }
}

struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let colorScheme: ColorScheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: theme.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(themeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                    
                    Text(themeDescription)
                        .font(.system(size: 13))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(themeColor)
                }
            }
            .padding(16)
            .background(
                DesignConstants.Colors.cardBackground(colorScheme: colorScheme)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? themeColor : Color.clear,
                        lineWidth: 2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: isSelected
                    ? themeColor.opacity(0.2)
                    : Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var themeColor: Color {
        switch theme {
        case .system:
            return DesignConstants.Colors.primary
        case .light:
            return DesignConstants.Colors.categorySports
        case .dark:
            return DesignConstants.Colors.categoryArt
        }
    }
    
    private var themeDescription: String {
        switch theme {
        case .system:
            return "Следовать настройкам устройства"
        case .light:
            return "Всегда светлая тема"
        case .dark:
            return "Всегда тёмная тема"
        }
    }
}

#Preview {
    ThemePickerView()
        .environmentObject(ThemeManager.shared)
}
