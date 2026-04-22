import SwiftUI
import AVFoundation
import Combine

struct QRScannerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var scannedCode: String = ""
    @State private var scanResult: QRScanResultModel? = nil
    @State private var isLoading = false
    @State private var selectedEventId: Int? = nil
    @State private var cameraPermissionGranted = false
    @State private var cancellable: AnyCancellable? = nil
    @State private var showResult = false
    
    private let apiClient = APIClient.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignConstants.Colors.mainBackground(colorScheme: colorScheme).ignoresSafeArea()
                
                if !cameraPermissionGranted {
                    noCameraPermissionView
                } else if let result = scanResult, showResult {
                    scanResultView(result)
                } else {
                    scannerInputView
                }
                
                if isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
            }
            .navigationTitle("Сканировать билет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                requestCameraPermission()
            }
        }
    }
    
    // MARK: - Views
    
    private var noCameraPermissionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 64))
                .foregroundColor(DesignConstants.Colors.error)
            
            VStack(spacing: 12) {
                Text("Доступ к камере запрещён")
                    .font(.headline)
                
                Text("Приложению нужен доступ к камере для сканирования QR кодов")
                    .font(.caption)
                    .foregroundColor(DesignConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: openSettings) {
                Text("Открыть настройки")
                    .frame(maxWidth: .infinity)
                    .padding(DesignConstants.padding)
                    .background(DesignConstants.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(DesignConstants.cornerRadius)
            }
            
            Spacer()
        }
        .padding(DesignConstants.padding)
    }
    
    private var scannerInputView: some View {
        VStack(spacing: 0) {
            // Camera preview
            QRCodeScannerRepresentable(
                scannedCode: $scannedCode,
                onScan: handleQRScan
            )
            .frame(maxHeight: .infinity)
            
            // Input section
            VStack(spacing: DesignConstants.spacing) {
                Divider()
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "qrcode")
                            .foregroundColor(DesignConstants.Colors.primary)
                        TextField("Или введите токен", text: $scannedCode)
                            .textFieldStyle(.plain)
                    }
                    .padding(DesignConstants.padding)
                    .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                    .cornerRadius(DesignConstants.cornerRadius)
                    
                    Button(action: handleManualScan) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Проверить билет")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(DesignConstants.padding)
                        .background(scannedCode.isEmpty ? DesignConstants.Colors.primary.opacity(0.5) : DesignConstants.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(DesignConstants.cornerRadius)
                    }
                    .disabled(scannedCode.isEmpty || isLoading)
                }
                .padding(DesignConstants.padding)
            }
            .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        }
    }
    
    private func scanResultView(_ result: QRScanResultModel) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: DesignConstants.spacing) {
                    // Status banner
                    statusBanner(result)
                    
                    // Visitor info card
                    visitorCard(result)
                    
                    // Tickets list
                    if !result.tickets.isEmpty {
                        ticketsCard(result)
                    }
                    
                    // Action buttons
                    actionButtons
                }
                .padding(DesignConstants.padding)
            }
        }
    }
    
    // MARK: - Components
    
    private func statusBanner(_ result: QRScanResultModel) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(result.is_registered ? DesignConstants.Colors.success.opacity(0.15) : DesignConstants.Colors.error.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: result.is_registered ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(result.is_registered ? DesignConstants.Colors.success : DesignConstants.Colors.error)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(result.is_registered ? "Билет действителен" : "Билет не найден")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                
                Text(result.is_registered ? "Посетитель зарегистрирован" : "Не зарегистрирован на событие")
                    .font(.system(size: 13))
                    .foregroundColor(DesignConstants.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(DesignConstants.padding)
        .background(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .fill(result.is_registered ? DesignConstants.Colors.success.opacity(0.08) : DesignConstants.Colors.error.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignConstants.cornerRadius)
                .stroke(result.is_registered ? DesignConstants.Colors.success.opacity(0.2) : DesignConstants.Colors.error.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func visitorCard(_ result: QRScanResultModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(DesignConstants.Colors.primary.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Text(String(result.full_name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.full_name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignConstants.Colors.textPrimary)
                    
                    Text("@\(result.username)")
                        .font(.system(size: 13))
                        .foregroundColor(DesignConstants.Colors.textSecondary)
                }
                
                Spacer()
                
                if result.is_registered {
                    Text("Активен")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignConstants.Colors.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(DesignConstants.Colors.success.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding(DesignConstants.padding)
            
            Divider()
                .padding(.horizontal, DesignConstants.padding)
            
            // Details
            VStack(spacing: 0) {
                infoRow(icon: "envelope.fill", label: "Email", value: result.email, isLink: true)
                
                Divider()
                    .padding(.leading, 48)
                
                if let registeredAt = result.registered_at {
                    infoRow(icon: "calendar", label: "Дата регистрации", value: DateFormatter.shortDateTimeFormat.string(from: registeredAt))
                }
            }
        }
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private func infoRow(icon: String, label: String, value: String, isLink: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(DesignConstants.Colors.textTertiary)
                .frame(width: 24, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(DesignConstants.Colors.textTertiary)
                
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(isLink ? DesignConstants.Colors.primary : DesignConstants.Colors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, DesignConstants.padding)
        .padding(.vertical, 12)
    }
    
    private func ticketsCard(_ result: QRScanResultModel) -> some View {
        VStack(alignment: .leading, spacing: DesignConstants.spacing) {
            HStack {
                Text("Билеты")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DesignConstants.Colors.textPrimary)
                
                Text("\(result.tickets.count)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DesignConstants.Colors.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                    .cornerRadius(10)
            }
            
            VStack(spacing: 10) {
                ForEach(result.tickets) { ticket in
                    HStack(spacing: 12) {
                        // Category color indicator
                        RoundedRectangle(cornerRadius: 3)
                            .fill(DesignConstants.Colors.categoryColor(for: ticket.category))
                            .frame(width: 4, height: 44)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(ticket.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(DesignConstants.Colors.textPrimary)
                                .lineLimit(1)
                            
                            HStack(spacing: 8) {
                                Label(ticket.date, systemImage: "calendar")
                                
                                Text("·")
                                
                                Label(ticket.location, systemImage: "mappin")
                                    .lineLimit(1)
                            }
                            .font(.system(size: 12))
                            .foregroundColor(DesignConstants.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text(ticket.category)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DesignConstants.Colors.categoryColor(for: ticket.category))
                            .cornerRadius(6)
                    }
                    .padding(12)
                    .background(DesignConstants.Colors.inputBackground(colorScheme: colorScheme))
                    .cornerRadius(DesignConstants.smallCornerRadius)
                }
            }
        }
        .padding(DesignConstants.padding)
        .background(DesignConstants.Colors.cardBackground(colorScheme: colorScheme))
        .cornerRadius(DesignConstants.cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private var actionButtons: some View {
        HStack(spacing: DesignConstants.spacing) {
            Button(action: handleClearResult) {
                HStack(spacing: 6) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 14))
                    Text("Сканировать ещё")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DesignConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(DesignConstants.cornerRadius)
            }
        }
    }
    
    // MARK: - Methods
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermissionGranted = granted
            }
        }
    }
    
    private func handleQRScan(_ code: String) {
        scannedCode = code
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            handleManualScan()
        }
    }
    
    private func handleManualScan() {
        guard !scannedCode.isEmpty else { return }
        
        isLoading = true
        let scannedToken = scannedCode
        let eventId = selectedEventId ?? 1
        
        cancellable = apiClient.scanQRCode(token: scannedToken, eventId: eventId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [self] completion in
                    isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        showResult = false
                    }
                },
                receiveValue: { [self] response in
                    print("DEBUG: API Response - user: \(response.full_name), tickets count: \(response.tickets?.count ?? 0)")
                    let tickets = response.tickets ?? []
                    print("DEBUG: Tickets: \(tickets.map { $0.title })")
                    
                    let result = QRScanResultModel(
                        user_id: response.user_id,
                        email: response.email,
                        username: response.username,
                        full_name: response.full_name,
                        is_registered: response.is_registered,
                        registered_at: response.registered_at.flatMap { dateStr in
                            let formatter = ISO8601DateFormatter()
                            return formatter.date(from: dateStr)
                        },
                        tickets: tickets
                    )
                    print("DEBUG: Result tickets: \(result.tickets.count)")
                    scanResult = result
                    showResult = true
                }
            )
    }
    
    private func handleClearResult() {
        showResult = false
        scanResult = nil
        scannedCode = ""
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
struct QRScanResultModel {
    let user_id: Int
    let email: String
    let username: String
    let full_name: String
    let is_registered: Bool
    let registered_at: Date?
    let tickets: [Event]
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let shortDateTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}

struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    var onScan: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let scanner = QRCodeScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode, onScan: onScan)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scannedCode: String
        var onScan: (String) -> Void
        var scanned = false
        
        init(scannedCode: Binding<String>, onScan: @escaping (String) -> Void) {
            self._scannedCode = scannedCode
            self.onScan = onScan
        }
        
        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            if let metadataObject = metadataObjects.first,
               let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
               let stringValue = readableObject.stringValue,
               !scanned {
                scanned = true
                onScan(stringValue)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.scanned = false
                }
            }
        }
    }
}

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    private func setupScanner() {
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        self.captureSession = captureSession
    }
}
