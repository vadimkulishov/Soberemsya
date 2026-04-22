import SwiftUI

struct ServerSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var customURL: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignConstants.sectionSpacing) {
                        // Current configuration
                        currentConfigSection
                        
                        // Manual URL input
                        customURLSection
                        
                        // Default URLs reference
                        defaultURLsSection
                        
                        // Reset button
                        resetButtonSection
                    }
                    .padding(DesignConstants.padding)
                }
            }
            .navigationTitle("Подключение к серверу")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .alert("Результат", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                customURL = AppConfig.shared.baseURL
            }
        }
    }
    
    // MARK: - Sections
    
    private var currentConfigSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            Label("Текущая конфигурация", systemImage: "server.rack")
                .font(.subheadline)
                .foregroundColor(DesignConstants.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: 12) {
                infoRow(label: "Используемый URL", value: AppConfig.shared.baseURL)
                
                Divider()
                
                infoRow(label: "Тип устройства", value: AppConfig.shared.isSimulator ? "Симулятор" : "Физическое")
                
                Divider()
                
                infoRow(label: "Статус", value: "Настроено")
            }
            .padding(DesignConstants.padding)
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .cornerRadius(DesignConstants.cornerRadius)
        }
    }
    
    private var customURLSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            Label("Пользовательский URL (опционально)", systemImage: "link")
                .font(.subheadline)
                .foregroundColor(DesignConstants.Colors.textSecondary)
            
            VStack(spacing: 12) {
                TextField("например: http://192.168.1.100:8002", text: $customURL)
                    .textFieldStyle(.roundedBorder)
                    .padding(DesignConstants.padding)
                
                HStack(spacing: DesignConstants.spacing) {
                    Button(action: saveCustomURL) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Применить")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(DesignConstants.smallPadding)
                        .background(DesignConstants.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(DesignConstants.cornerRadius)
                    }
                    .disabled(customURL.isEmpty || customURL == AppConfig.shared.baseURL)
                }
                .padding(DesignConstants.padding)
            }
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .cornerRadius(DesignConstants.cornerRadius)
        }
    }
    
    private var defaultURLsSection: some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            Label("URL по умолчанию", systemImage: "info.circle")
                .font(.subheadline)
                .foregroundColor(DesignConstants.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Для симулятора iOS")
                        .font(.caption)
                        .foregroundColor(DesignConstants.Colors.textTertiary)
                    Text(AppConfig.shared.simulatorURL)
                        .font(.caption2)
                        .foregroundColor(DesignConstants.Colors.primary)
                        .lineLimit(1)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Для физического устройства")
                        .font(.caption)
                        .foregroundColor(DesignConstants.Colors.textTertiary)
                    Text(AppConfig.shared.deviceURL)
                        .font(.caption2)
                        .foregroundColor(DesignConstants.Colors.primary)
                        .lineLimit(1)
                }
            }
            .padding(DesignConstants.padding)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(DesignConstants.cornerRadius)
        }
    }
    
    private var resetButtonSection: some View {
        VStack(spacing: DesignConstants.spacing) {
            Button(action: resetToDefault) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Сбросить на значения по умолчанию")
                }
                .frame(maxWidth: .infinity)
                .padding(DesignConstants.padding)
                .background(DesignConstants.Colors.error.opacity(0.1))
                .foregroundColor(DesignConstants.Colors.error)
                .cornerRadius(DesignConstants.cornerRadius)
            }
            
            Text("Это вернет автоматический выбор URL в зависимости от типа устройства (симулятор / физическое)")
                .font(.caption)
                .foregroundColor(DesignConstants.Colors.textSecondary)
        }
    }
    
    // MARK: - Helpers
    
    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(DesignConstants.Colors.textTertiary)
            Text(value)
                .font(.caption)
                .foregroundColor(DesignConstants.Colors.textPrimary)
                .lineLimit(1)
        }
    }
    
    private func saveCustomURL() {
        guard !customURL.isEmpty else { return }
        
        AppConfig.shared.setBaseURL(customURL)
        alertMessage = "✅ URL сохранен! Перезагрузите приложение для применения."
        showAlert = true
    }
    
    private func resetToDefault() {
        AppConfig.shared.resetBaseURL()
        customURL = AppConfig.shared.baseURL
        alertMessage = "✅ Сброшено на значения по умолчанию!"
        showAlert = true
    }
}

#Preview {
    ServerSettingsView()
        .environmentObject(ThemeManager.shared)
}
