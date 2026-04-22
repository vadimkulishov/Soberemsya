import SwiftUI

struct AccountView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutAlert = false
    @State private var showThemePicker = false

    var body: some View {
        if authManager.isLoggedIn {
            loggedInView
        } else {
            AuthenticationView()
        }
    }

    // MARK: - Logged In

    private var loggedInView: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignConstants.sectionSpacing) {
                        // Profile header
                        profileHeader

                        // Menu sections
                        settingsSection

                        aboutSection

                        logoutSection
                    }
                    .padding(.horizontal, DesignConstants.padding)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showThemePicker) {
                ThemePickerView()
            }
            .alert("Выйти из аккаунта?", isPresented: $showLogoutAlert) {
                Button("Выйти", role: .destructive) {
                    authManager.logout()
                }
                Button("Отмена", role: .cancel) {}
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(DesignConstants.Colors.primary.opacity(0.12))
                    .frame(width: 64, height: 64)

                Text(initials)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)

                Text(authManager.currentUser?.email ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(DesignConstants.Colors.textSecondary)

                if authManager.userRole != "user" {
                    Text(roleLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(DesignConstants.Colors.primary)
                        .cornerRadius(6)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(DesignConstants.padding)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            menuRow(icon: "paintbrush", iconColor: DesignConstants.Colors.categoryArt, title: "Тема оформления", detail: themeManager.selectedTheme.rawValue) {
                showThemePicker = true
            }

            Divider().padding(.leading, 52)

            NavigationLink(destination: ServerSettingsView()) {
                menuRowContent(icon: "server.rack", iconColor: DesignConstants.Colors.categoryTech, title: "Сервер", detail: serverLabel)
            }

            Divider().padding(.leading, 52)

            NavigationLink(destination: SettingsView()) {
                menuRowContent(icon: "gearshape", iconColor: DesignConstants.Colors.textSecondary, title: "Настройки", detail: nil)
            }
        }
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(spacing: 0) {
            infoRow(icon: "info.circle", iconColor: DesignConstants.Colors.primary, title: "Версия", value: appVersion)

            Divider().padding(.leading, 52)

            infoRow(icon: "person.text.rectangle", iconColor: DesignConstants.Colors.categoryNature, title: "Роль", value: roleLabel)
        }
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
    }

    // MARK: - Logout

    private var logoutSection: some View {
        Button(role: .destructive) {
            showLogoutAlert = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15))
                Text("Выйти из аккаунта")
                    .font(.system(size: 15, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
            .foregroundColor(DesignConstants.Colors.error)
            .cornerRadius(DesignConstants.cornerRadius)
        }
    }

    // MARK: - Row Components

    private func menuRow(icon: String, iconColor: Color, title: String, detail: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            menuRowContent(icon: icon, iconColor: iconColor, title: title, detail: detail)
        }
        .buttonStyle(.plain)
    }

    private func menuRowContent(icon: String, iconColor: Color, title: String, detail: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(6)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(DesignConstants.Colors.textPrimary)

            Spacer()

            if let detail = detail {
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundColor(DesignConstants.Colors.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(DesignConstants.Colors.textTertiary)
        }
        .padding(.horizontal, DesignConstants.padding)
        .padding(.vertical, 12)
    }

    private func infoRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(6)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(DesignConstants.Colors.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(DesignConstants.Colors.textTertiary)
        }
        .padding(.horizontal, DesignConstants.padding)
        .padding(.vertical, 12)
    }

    // MARK: - Computed

    private var displayName: String {
        let name = authManager.currentUser?.name ?? ""
        return name.isEmpty ? "Пользователь" : name
    }

    private var initials: String {
        let name = authManager.currentUser?.name ?? ""
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var roleLabel: String {
        switch authManager.userRole {
        case "admin": return "Администратор"
        case "organizer": return "Организатор"
        default: return "Пользователь"
        }
    }

    private var serverLabel: String {
        let url = AppConfig.shared.baseURL
        return url.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: "")
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Helper View

struct EditProfileField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var onChange: ((String) -> Void)? = nil
    var keyboardType: UIKeyboardType = .default
    let colorScheme: ColorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DesignConstants.Colors.primary)
                .frame(width: 20, alignment: .center)

            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .keyboardType(keyboardType)
                .foregroundColor(DesignConstants.Colors.textPrimary)
                .onChange(of: text) { _, newValue in
                    onChange?(newValue)
                }
        }
        .padding(12)
        .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
        .cornerRadius(12)
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthManager.shared)
        .environmentObject(ThemeManager.shared)
}
