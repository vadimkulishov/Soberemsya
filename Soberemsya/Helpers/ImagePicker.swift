import SwiftUI
import PhotosUI

/// Современный ImagePicker для iOS 26+ с использованием PhotosUI
struct ImagePicker: View {
    @Binding var image: UIImage?
    @State private var selectedItems: [PhotosPickerItem] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Выбрать фото")
                        .font(.headline.weight(.semibold))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                
                Divider()
                
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 1,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("Нажмите для выбора фото")
                            .font(.headline)
                        
                        Text("Выберите одно фото из библиотеки")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
                }
                .onChange(of: selectedItems) { _, newItems in
                    Task {
                        if let item = newItems.first {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                image = uiImage
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ImagePicker(image: .constant(nil))
}
