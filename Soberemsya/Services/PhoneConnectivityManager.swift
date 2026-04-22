import Foundation
import UIKit
import CoreImage
import WatchConnectivity
import Combine

/// Менеджер для отправки данных на Apple Watch через WatchConnectivity
class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    /// Отправить QR токен на Watch (с изображением QR-кода)
    func sendQRToken(_ token: String, expiresAt: String, userName: String) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        
        var context: [String: Any] = [
            "qrToken": token,
            "expiresAt": expiresAt,
            "userName": userName,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        // Генерируем QR-картинку на iPhone и отправляем как Data
        if let imageData = generateQRImageData(from: token) {
            context["qrImageData"] = imageData
        }
        
        do {
            try session.updateApplicationContext(context)
        } catch {
            print("PhoneConnectivity: Failed to send context - \(error)")
        }
        
        if session.isReachable {
            session.sendMessage(context, replyHandler: nil) { error in
                print("PhoneConnectivity: Message send error - \(error)")
            }
        }
    }
    
    /// Очистить данные на Watch (при logout)
    func clearWatchData() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        
        let context: [String: Any] = [
            "logout": true,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        do {
            try session.updateApplicationContext(context)
        } catch {
            print("PhoneConnectivity: Failed to clear watch data - \(error)")
        }
        
        if session.isReachable {
            session.sendMessage(context, replyHandler: nil, errorHandler: nil)
        }
    }
    
    // MARK: - QR Generation
    
    /// Генерирует PNG-данные QR-кода для отправки на Watch
    private func generateQRImageData(from string: String) -> Data? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 8, y: 8)
        let scaled = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        
        return UIImage(cgImage: cgImage).pngData()
    }
}

// MARK: - WCSessionDelegate

extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("PhoneConnectivity: Activation error - \(error)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    // Watch запрашивает данные
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if message["requestQR"] as? Bool == true {
            DispatchQueue.main.async { [weak self] in
                let authManager = AuthManager.shared
                if let user = authManager.currentUser {
                    authManager.loadUserQRCode { [weak self] token, _ in
                        if let token = token {
                            var reply: [String: Any] = [
                                "qrToken": token,
                                "userName": user.name,
                                "expiresAt": ""
                            ]
                            if let imageData = self?.generateQRImageData(from: token) {
                                reply["qrImageData"] = imageData
                            }
                            replyHandler(reply)
                        } else {
                            replyHandler(["error": "no_token"])
                        }
                    }
                } else {
                    replyHandler(["error": "not_logged_in"])
                }
            }
        }
    }
}
