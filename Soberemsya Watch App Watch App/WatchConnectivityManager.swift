import Foundation
import Combine
import WatchConnectivity

class WatchConnectivityManager: ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var qrToken: String?
    @Published var qrImageData: Data?
    @Published var expiresAt: String?
    @Published var userName: String?
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false

    private let tokenKey = "watch.qrToken"
    private let imageDataKey = "watch.qrImageData"
    private let userNameKey = "watch.userName"
    private let expiresAtKey = "watch.expiresAt"
    
    private var sessionDelegate: SessionDelegate?

    init() {
        loadSavedData()
        
        if WCSession.isSupported() {
            let delegate = SessionDelegate(manager: self)
            self.sessionDelegate = delegate
            let session = WCSession.default
            session.delegate = delegate
            session.activate()
        }
    }

    func requestQRFromPhone() {
        guard WCSession.isSupported(), WCSession.default.isReachable else { return }

        isLoading = true
        WCSession.default.sendMessage(["requestQR": true], replyHandler: { [weak self] reply in
            self?.handleReceivedData(reply)
            DispatchQueue.main.async {
                self?.isLoading = false
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
        UserDefaults.standard.set(qrImageData, forKey: imageDataKey)
        UserDefaults.standard.set(userName, forKey: userNameKey)
        UserDefaults.standard.set(expiresAt, forKey: expiresAtKey)
    }

    private func loadSavedData() {
        qrToken = UserDefaults.standard.string(forKey: tokenKey)
        qrImageData = UserDefaults.standard.data(forKey: imageDataKey)
        userName = UserDefaults.standard.string(forKey: userNameKey)
        expiresAt = UserDefaults.standard.string(forKey: expiresAtKey)
    }

    private func clearData() {
        qrToken = nil
        qrImageData = nil
        userName = nil
        expiresAt = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: imageDataKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: expiresAtKey)
    }

    func handleReceivedData(_ data: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            if data["logout"] as? Bool == true {
                self?.clearData()
                return
            }

            if let token = data["qrToken"] as? String {
                self?.qrToken = token
                self?.qrImageData = data["qrImageData"] as? Data
                self?.userName = data["userName"] as? String
                self?.expiresAt = data["expiresAt"] as? String
                self?.saveData()
            }
        }
    }
}

// MARK: - WCSession Delegate (separate NSObject)

private class SessionDelegate: NSObject, WCSessionDelegate {
    weak var manager: WatchConnectivityManager?
    
    init(manager: WatchConnectivityManager) {
        self.manager = manager
        super.init()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        DispatchQueue.main.async { [weak self] in
            self?.manager?.isConnected = activationState == .activated
        }

        if !session.receivedApplicationContext.isEmpty {
            manager?.handleReceivedData(session.receivedApplicationContext)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        manager?.handleReceivedData(applicationContext)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        manager?.handleReceivedData(message)
    }
}
