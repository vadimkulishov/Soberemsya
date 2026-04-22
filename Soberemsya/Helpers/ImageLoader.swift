import SwiftUI
import Foundation
import Combine

@MainActor
final class ImageLoader: NSObject, ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var urlString: String?
    private var cancellable: AnyCancellable?
    private static let cache = NSCache<NSString, UIImage>()
    
    func load(from urlString: String?) {
        guard let urlString = urlString, !urlString.isEmpty else {
            print("❌ ImageLoader: Empty URL")
            self.image = nil
            self.error = nil
            return
        }
        
        print("📥 ImageLoader.load() called with: \(urlString)")
        
        // Check cache first
        let cacheKey = urlString.starts(with: "http") ? urlString : (AppConfig.shared.baseURL + urlString)
        if let cached = Self.cache.object(forKey: cacheKey as NSString) {
            print("💾 Image found in cache: \(cacheKey)")
            self.image = cached
            self.isLoading = false
            return
        }
        
        self.urlString = urlString
        self.isLoading = true
        self.error = nil
        
        // Construct full URL
        let fullURL: URL
        if urlString.starts(with: "http") {
            guard let url = URL(string: urlString) else {
                self.error = NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                self.isLoading = false
                print("❌ Invalid HTTP URL: \(urlString)")
                return
            }
            fullURL = url
        } else {
            let baseURL = AppConfig.shared.baseURL
            let fullURLString = baseURL + urlString
            print("🔧 Relative URL detected. Base: \(baseURL), Path: \(urlString)")
            guard let url = URL(string: fullURLString) else {
                self.error = NSError(domain: "ImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid relative URL"])
                self.isLoading = false
                print("❌ Cannot construct URL from base + path: \(baseURL) + \(urlString)")
                return
            }
            fullURL = url
        }
        
        print("🖼️ Loading image from: \(fullURL.absoluteString)")
        
        var request = URLRequest(url: fullURL)
        request.timeoutInterval = 10
        
        self.cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔗 Response status: \(httpResponse.statusCode) for URL: \(fullURL)")
                    if httpResponse.statusCode != 200 {
                        throw NSError(domain: "ImageLoader", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
                    }
                }
                return data
            }
            .map { $0 }
            .compactMap { data -> UIImage? in
                guard let image = UIImage(data: data) else {
                    print("❌ Failed to create UIImage from data (size: \(data.count) bytes)")
                    return nil
                }
                print("✅ Image loaded successfully from: \(fullURL)")
                return image
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Image loading error for \(fullURL): \(error.localizedDescription)")
                        self?.error = error
                    }
                },
                receiveValue: { [weak self, urlString] uiImage in
                    Self.cache.setObject(uiImage, forKey: urlString as NSString)
                    self?.image = uiImage
                    print("💾 Image cached for key: \(String(describing: urlString))")
                }
            )
    }
}

struct AsyncImageView: View {
    @StateObject private var loader = ImageLoader()
    let urlString: String?
    let placeholder: UIImage?
    
    var body: some View {
        ZStack {
            // Background
            Color.gray.opacity(0.15)
            
            // Image or placeholder
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let placeholder = placeholder {
                Image(uiImage: placeholder)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback gray if no image
                Color.gray.opacity(0.2)
            }
            
            // Loading indicator
            if loader.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .tint(.white)
                }
            }
            
            // Error indicator
            if let _ = loader.error, loader.image == nil {
                VStack(spacing: 8) {
                    Image(systemName: "photo.slash")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("Ошибка загрузки")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.4))
            }
        }
        .onAppear {
            Task { @MainActor in
                if loader.image == nil && loader.error == nil && !loader.isLoading {
                    loader.load(from: urlString)
                }
            }
        }
    }
}
