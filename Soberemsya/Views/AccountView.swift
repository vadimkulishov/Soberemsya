import SwiftUI

struct AccountView: View {
    // MARK: - Состояния
    @State private var isLoggedIn = false
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var userName = ""
    @State private var showPassword = false
    @State private var rememberMe = false
    
    // MARK: - Хранение данных
    @AppStorage("savedEmail") private var savedEmail = ""
    @AppStorage("savedPassword") private var savedPassword = ""
    @AppStorage("savedUserName") private var savedUserName = ""
    @AppStorage("isLoggedIn") private var storedLoggedIn = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                if storedLoggedIn || isLoggedIn {
                    profileView
                } else {
                    loginView
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Аккаунт")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Login/Register View
    private var loginView: some View {
        VStack(spacing: 25) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text(isRegistering ? "Создание аккаунта" : "Вход")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                if isRegistering {
                    TextField("Имя", text: $userName)
                        .textFieldStyle(.roundedBorder)
                }
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    if showPassword {
                        TextField("Пароль", text: $password)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("Пароль", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                if isRegistering {
                    SecureField("Подтвердите пароль", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            if !isRegistering {
                Toggle("Запомнить меня", isOn: $rememberMe)
                    .toggleStyle(.switch)
            }
            
            Button(action: handleAuthentication) {
                Text(isRegistering ? "Зарегистрироваться" : "Войти")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.6)
            
            Button {
                withAnimation(.spring()) {
                    isRegistering.toggle()
                    clearForm()
                }
            } label: {
                Text(isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Создать")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Profile View
    private var profileView: some View {
        VStack(spacing: 25) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text(userName.isEmpty ? "Пользователь" : userName)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(email.isEmpty ? "email@example.com" : email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: signOut) {
                Text("Выйти")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Helpers
    private var isFormValid: Bool {
        if isRegistering {
            return !email.isEmpty &&
                   !password.isEmpty &&
                   !confirmPassword.isEmpty &&
                   !userName.isEmpty &&
                   password == confirmPassword &&
                   password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleAuthentication() {
        if isRegistering {
            savedEmail = email
            savedPassword = password
            savedUserName = userName
            storedLoggedIn = true
        } else {
            if email == savedEmail && password == savedPassword {
                userName = savedUserName
                storedLoggedIn = true
            } else if savedEmail.isEmpty {
                savedEmail = email
                savedPassword = password
                savedUserName = email.components(separatedBy: "@").first ?? "Пользователь"
                userName = savedUserName
                storedLoggedIn = true
            }
        }
        isLoggedIn = storedLoggedIn
    }
    
    private func signOut() {
        storedLoggedIn = false
        isLoggedIn = false
        clearForm()
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        userName = ""
        rememberMe = false
    }
}
