import SwiftUI

struct AuthenticationView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var authManager = AuthManager.shared

    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var city = "Москва"
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    private let cities = ["Москва", "СПб", "Казань", "Новосибирск"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    topIntro
                    authSwitcher
                    formShell
                    submitBlock
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .background(backgroundLayer)
            .navigationBarHidden(true)
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.56, blue: 0.42).opacity(colorScheme == .dark ? 0.16 : 0.10),
                    Color.clear,
                    Color(red: 0.94, green: 0.78, blue: 0.52).opacity(colorScheme == .dark ? 0.10 : 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    private var topIntro: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Soberemsya")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(accentColor)

                    Text(isLogin ? "Вход в аккаунт" : "Создание аккаунта")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(DesignConstants.Colors.textPrimary)

                    Text(isLogin ? "Вернитесь к билетам, событиям и регистрациям." : "Зарегистрируйтесь и сохраняйте все билеты в одном месте.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(accentGradient)
                        .frame(width: 74, height: 74)

                    Image(systemName: isLogin ? "person.crop.circle.fill.badge.checkmark" : "person.badge.plus.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            HStack(spacing: 10) {
                introChip(icon: "ticket.fill", text: "Билеты")
                introChip(icon: "sparkles", text: "События")
                introChip(icon: "qrcode", text: "QR")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Color.white.opacity(colorScheme == .dark ? 0.07 : 0.75), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.14 : 0.05), radius: 14, x: 0, y: 6)
    }

    private var authSwitcher: some View {
        HStack(spacing: 10) {
            switcherButton(title: "Вход", subtitle: "У меня уже есть аккаунт", isActive: isLogin) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLogin = true
                    clearForm()
                }
            }

            switcherButton(title: "Регистрация", subtitle: "Я новый пользователь", isActive: !isLogin) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLogin = false
                    clearForm()
                    city = "Москва"
                }
            }
        }
    }

    private var formShell: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isLogin ? "Данные для входа" : "Заполните форму")
                .font(DesignConstants.Typography.headline)
                .foregroundColor(DesignConstants.Colors.textPrimary)

            AuthInputCard(icon: "envelope.fill", title: "Email", colorScheme: colorScheme) {
                TextField("example@mail.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if !isLogin {
                AuthInputCard(icon: "person.fill", title: "Имя пользователя", colorScheme: colorScheme) {
                    TextField("Ваше имя", text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Город")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textSecondary)

                    Picker("Город", selection: $city) {
                        ForEach(cities, id: \.self) { currentCity in
                            Text(currentCity).tag(currentCity)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(inputBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }

            AuthInputCard(icon: "lock.fill", title: "Пароль", colorScheme: colorScheme) {
                HStack(spacing: 10) {
                    Group {
                        if showPassword {
                            TextField("Минимум 6 символов", text: $password)
                        } else {
                            SecureField("Минимум 6 символов", text: $password)
                        }
                    }
                    .textContentType(isLogin ? .password : .newPassword)

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                    }
                }
            }

            if !isLogin {
                AuthInputCard(icon: "checkmark.shield.fill", title: "Подтверждение пароля", colorScheme: colorScheme) {
                    HStack(spacing: 10) {
                        Group {
                            if showConfirmPassword {
                                TextField("Повторите пароль", text: $confirmPassword)
                            } else {
                                SecureField("Повторите пароль", text: $confirmPassword)
                            }
                        }
                        .textContentType(.newPassword)

                        Button {
                            showConfirmPassword.toggle()
                        } label: {
                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(DesignConstants.Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.12 : 0.04), radius: 12, x: 0, y: 5)
    }

    private var submitBlock: some View {
        VStack(spacing: 12) {
            Button {
                performAction()
            } label: {
                HStack(spacing: 10) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Image(systemName: isLogin ? "arrow.right.circle.fill" : "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                    }

                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(accentGradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .foregroundColor(.white)
                .shadow(color: accentColor.opacity(0.22), radius: 12, x: 0, y: 5)
            }
            .disabled(!isFormValid || authManager.isLoading)
            .opacity((!isFormValid || authManager.isLoading) ? 0.6 : 1)

            if let error = authManager.error {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error.localizedDescription)
                        .font(.system(size: 13, weight: .medium))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .foregroundColor(.red)
            }
        }
    }

    private func introChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(DesignConstants.Colors.textPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(inputBackground, in: Capsule())
    }

    private func switcherButton(title: String, subtitle: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isActive ? accentGradient : LinearGradient(colors: [inputBackgroundColor, inputBackgroundColor], startPoint: .top, endPoint: .bottom))
            )
            .foregroundColor(isActive ? .white : DesignConstants.Colors.textPrimary)
        }
    }

    private var accentColor: Color {
        Color(red: 0.96, green: 0.47, blue: 0.32)
    }

    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                accentColor,
                Color(red: 0.98, green: 0.66, blue: 0.38)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var inputBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.03)
    }

    private var inputBackground: some ShapeStyle {
        inputBackgroundColor
    }

    private var buttonTitle: String {
        if authManager.isLoading {
            return isLogin ? "Входим..." : "Создаём аккаунт..."
        }
        return isLogin ? "Войти в аккаунт" : "Создать аккаунт"
    }

    private var isFormValid: Bool {
        if isLogin {
            return !email.isEmpty && !password.isEmpty
        }

        return !email.isEmpty &&
            !username.isEmpty &&
            !password.isEmpty &&
            !confirmPassword.isEmpty &&
            !city.isEmpty &&
            password == confirmPassword
    }

    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        username = ""
        showPassword = false
        showConfirmPassword = false
        authManager.error = nil
    }

    private func performAction() {
        if isLogin {
            authManager.login(email: email, password: password)
        } else {
            authManager.register(
                username: username,
                email: email,
                password: password,
                fullName: username,
                city: city
            )
        }
    }
}

private struct AuthInputCard<Content: View>: View {
    let icon: String
    let title: String
    let colorScheme: ColorScheme
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(DesignConstants.Colors.textSecondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.96, green: 0.47, blue: 0.32))
                    .frame(width: 18)

                content
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                (colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.03)),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
    }
}

#Preview {
    AuthenticationView()
}
