import Foundation
import WatchConnectivity

/// Менеджер для приёма данных от iPhone через WatchConnectivity
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var qrToken: String?
    @Published var expiresAt: String?
    @Published var userName: String?
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false

    private let tokenKey = "watch.qrToken"
    private let userNameKey = "watch.userName"
    private let expiresAtKey = "watch.expiresAt"

    override init() {
        super.init()

        // Загружаем сохранённые данные
        loadSavedData()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    /// Запросить QR код у iPhone
    func requestQRFromPhone() {
        guard WCSession.default.isReachable else { return }

        isLoading = true
        WCSession.default.sendMessage(["requestQR": true], replyHandler: { [weak self] reply in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let token = reply["qrToken"] as? String {
                    self?.qrToken = token
                    self?.userName = reply["userName"] as? String
                    self?.expiresAt = reply["expiresAt"] as? String
                    self?.saveData()
                }
            }
        }, errorHandler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        })
    }

    // MARK: - Persistence

    private func saveData() {
        UserDefaults.standard.set(qrToken, forKey: tokenKey)
        UserDefaults.standard.set(userName, forKey: userNameKey)
        UserDefaults.standard.set(expiresAt, forKey: expiresAtKey)
    }

    private func loadSavedData() {
        qrToken = UserDefaults.standard.string(forKey: tokenKey)
        userName = UserDefaults.standard.string(forKey: userNameKey)
        expiresAt = UserDefaults.standard.string(forKey: expiresAtKey)
    }

    private func clearData() {
        qrToken = nil
        userName = nil
        expiresAt = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: expiresAtKey)
    }

    private func handleReceivedData(_ data: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            if data["logout"] as? Bool == true {
                self?.clearData()
                return
            }

            if let token = data["qrToken"] as? String {
                self?.qrToken = token
                self?.userName = data["userName"] as? String
                self?.expiresAt = data["expiresAt"] as? String
                self?.saveData()
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = activationState == .activated
        }

        // Проверяем applicationContext на наличие данных
        if !session.receivedApplicationContext.isEmpty {
            handleReceivedData(session.receivedApplicationContext)
        }
    }

    // Получаем данные через applicationContext
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        handleReceivedData(applicationContext)
    }

    // Получаем данные через sendMessage (моментальная доставка)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleReceivedData(message)
    }
}
