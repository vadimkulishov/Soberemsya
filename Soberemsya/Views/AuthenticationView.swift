import SwiftUI

struct AuthenticationView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var authManager = AuthManager.shared
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var city = "Москва"
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var selectedCity: String?
    @State private var cities: [String] = ["Москва", "СПб", "Казань", "Новосибирск"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Tab Switcher
                        tabSwitcher
                        
                        // Form Content
                        if isLogin {
                            loginForm
                        } else {
                            registerForm
                        }
                        
                        // Submit Button
                        submitButton
                        
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header Section
    
    var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignConstants.Colors.primary,
                        DesignConstants.Colors.primary.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 12) {
                    Image(systemName: isLogin ? "lock.open" : "pencil.and.ellipsis.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 6) {
                        Text(isLogin ? "Добро пожаловать!" : "Создайте аккаунт")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(isLogin ? 
                            "Введите учетные данные для входа" :
                            "Заполните форму для регистрации")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
            }
            .frame(height: 200)
            .cornerRadius(20)
            .shadow(color: DesignConstants.Colors.primary.opacity(0.3), radius: 12, x: 0, y: 8)
        }
    }
    
    // MARK: - Tab Switcher
    
    var tabSwitcher: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLogin = true
                    clearForm()
                }
            } label: {
                HStack {
                    Image(systemName: "lock.open")
                    Text("Вход")
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(isLogin ? 
                    AnyView(LinearGradient(
                        gradient: Gradient(colors: [
                            DesignConstants.Colors.primary,
                            DesignConstants.Colors.primary.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )) :
                    AnyView(Color(UIColor.systemGray6))
                )
                .foregroundColor(isLogin ? .white : DesignConstants.Colors.textPrimary)
                .cornerRadius(10)
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLogin = false
                    clearForm()
                }
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Регистрация")
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(!isLogin ?
                    AnyView(LinearGradient(
                        gradient: Gradient(colors: [
                            DesignConstants.Colors.primary,
                            DesignConstants.Colors.primary.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )) :
                    AnyView(Color(UIColor.systemGray6))
                )
                .foregroundColor(!isLogin ? .white : DesignConstants.Colors.textPrimary)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Login Form
    
    var loginForm: some View {
        VStack(spacing: 12) {
            // Email
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(width: 20, alignment: .center)
                
                TextField("Email", text: $email)
                    .font(.system(size: 14))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .autocorrectionDisabled()
            }
            .padding(12)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(12)
            
            // Password
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(width: 20, alignment: .center)
                
                if showPassword {
                    TextField("Пароль", text: $password)
                        .font(.system(size: 14))
                        .textContentType(.password)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                } else {
                    SecureField("Пароль", text: $password)
                        .font(.system(size: 14))
                        .textContentType(.password)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                }
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
            }
            .padding(12)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Register Form
    
    var registerForm: some View {
        VStack(spacing: 12) {
            // Email
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(width: 20, alignment: .center)
                
                TextField("Email", text: $email)
                    .font(.system(size: 14))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .autocorrectionDisabled()
            }
            .padding(12)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(12)
            
            // Username
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(width: 20, alignment: .center)
                
                TextField("Имя пользователя", text: $username)
                    .font(.system(size: 14))
                    .textContentType(.username)
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                    .autocorrectionDisabled()
            }
            .padding(12)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(12)
            
            // City Picker
            HStack(spacing: 12) {
                Image(systemName: "mappin")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(width: 20, alignment: .center)
                
                Picker("Город", selection: $city) {
                    ForEach(cities, id: \.self) { c in
                        Text(c).tag(c)
                    }
                }
                .foregroundColor(DesignConstants.Colors.textPrimary)
            }
            .padding(12)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(12)
            
            // Password
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(width: 20, alignment: .center)
                
                if showPassword {
                    TextField("Пароль", text: $password)
                        .font(.system(size: 14))
                        .textContentType(.newPassword)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                } else {
                    SecureField("Пароль", text: $password)
                        .font(.system(size: 14))
                        .textContentType(.newPassword)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                }
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
            }
            .padding(12)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(12)
            
            // Confirm Password
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.primary)
                    .frame(width: 20, alignment: .center)
                
                if showConfirmPassword {
                    TextField("Повторить пароль", text: $confirmPassword)
                        .font(.system(size: 14))
                        .textContentType(.newPassword)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                } else {
                    SecureField("Повторить пароль", text: $confirmPassword)
                        .font(.system(size: 14))
                        .textContentType(.newPassword)
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                }
                
                Button {
                    showConfirmPassword.toggle()
                } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
            }
            .padding(12)
            .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Submit Button
    
    var submitButton: some View {
        Group {
            if authManager.isLoading {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text(isLogin ? "Входим..." : "Регистрируемся...")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(DesignConstants.Colors.primary.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(12)
            } else {
                Button {
                    performAction()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isLogin ? "lock.open" : "checkmark.circle.fill")
                        Text(isLogin ? "Войти" : "Создать аккаунт")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                DesignConstants.Colors.primary,
                                DesignConstants.Colors.primary.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.5)
            }
            
            // Error Message
            if let error = authManager.error {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle")
                    Text(error.localizedDescription)
                        .font(.system(size: 12, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        if isLogin {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !username.isEmpty && !password.isEmpty && 
                   !confirmPassword.isEmpty && password == confirmPassword && !city.isEmpty
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        username = ""
        city = ""
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

#Preview {
    AuthenticationView()
}
