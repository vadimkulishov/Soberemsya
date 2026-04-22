import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var accountVM = AccountViewModel()
    @State private var showThemePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Тема оформления
                    SettingsSectionView(title: "Внешний вид") {
                        Button {
                            showThemePicker = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: themeManager.selectedTheme.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(DesignConstants.Colors.categoryMusic)
                                    .frame(width: 24, alignment: .center)
                                
                                Text("Тема оформления")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(DesignConstants.Colors.textPrimary)
                                
                                Spacer()
                                
                                Text(themeManager.selectedTheme.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DesignConstants.Colors.textSecondary)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(DesignConstants.Colors.textTertiary)
                            }
                            .padding(12)
                            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Размер текста
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "textformat.size")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(DesignConstants.Colors.categoryTech)
                                    .frame(width: 24, alignment: .center)
                                
                                Text("Размер текста")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(DesignConstants.Colors.textPrimary)
                            }
                            
                            HStack(spacing: 10) {
                                Image(systemName: "a.square.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Slider(value: $accountVM.textSize, in: 14...24, step: 1)
                                    .onChange(of: accountVM.textSize) { _, _ in
                                        accountVM.saveSettings()
                                    }
                                
                                Image(systemName: "a.square.fill")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                        .cornerRadius(12)
                    }
                    
                    // О приложении
                    SettingsSectionView(title: "О приложении") {
                        InfoRowView(
                            icon: "info.circle",
                            label: "Версия",
                            value: "1.0.0"
                        )
                        
                        InfoRowView(
                            icon: "server.rack",
                            label: "Сервер",
                            value: "localhost:8000"
                        )
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView()
            }
        }
    }
}

// MARK: - Settings Section Component
struct SettingsSectionView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignConstants.Colors.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                content
            }
            .padding(16)
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .cornerRadius(16)
        }
    }
}

// MARK: - Info Row Component
struct InfoRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignConstants.Colors.primary)
                .frame(width: 24, alignment: .center)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignConstants.Colors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignConstants.Colors.textSecondary)
        }
        .padding(12)
        .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager.shared)
}
