//
//  ImagePicker.swift
//  WildMushroomHandbook
//
//  SwiftUI相机封装 - 用于拍摄野生菌照片
//

import SwiftUI
import UIKit
import PhotosUI

// MARK: - 相机选择器

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 相机服务

class CameraService: ObservableObject {
    static let shared = CameraService()

    @Published var isCameraAvailable: Bool = false

    private init() {
        checkCameraAvailability()
    }

    func checkCameraAvailability() {
        isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}

// MARK: - 现代照片选择器 (iOS 16+)

@available(iOS 16, *)
struct PhotoPicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool

    var body: some View {
        PhotosPicker(selection: Binding(
            get: { selectedImage != nil ? PhotosPickerItem(itemIdentifier: "") : nil },
            set: { _ in }
        ), matching: .images) {
            EmptyView()
        }
        .photosPickerStyle(.compact)
        .onChange(of: selectedImage) { _ in }
    }
}
