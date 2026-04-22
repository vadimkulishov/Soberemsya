import SwiftUI

// MARK: - View Extension for Error Alert

extension View {
    /// Показывает alert при ошибке API
    func errorAlert(error: Binding<APIError?>) -> some View {
        alert("Error", isPresented: .constant(error.wrappedValue != nil)) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let error = error.wrappedValue {
                Text(error.errorDescription ?? "Unknown error")
            }
        }
    }
}

// MARK: - Success and Info Extensions

extension View {
    /// Показывает toast-подобное сообщение
    func withToast(_ message: String, isShowing: Binding<Bool>) -> some View {
        ZStack {
            self
            
            VStack {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(message)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(12)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(8)
                .padding(16)
                .opacity(isShowing.wrappedValue ? 1 : 0)
                
                Spacer()
            }
        }
    }
}
