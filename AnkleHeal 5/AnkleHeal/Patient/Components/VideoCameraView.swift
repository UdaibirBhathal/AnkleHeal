//
//  VideoCameraView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 14/03/25.
//

import SwiftUI
import UIKit
import AVFoundation


//struct VideoCameraView: UIViewControllerRepresentable {
//    @Binding var isPresented: Bool
//    @Binding var videoURL: URL?
//    
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: VideoCameraView
//
//        init(parent: VideoCameraView) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//            if let url = info[.mediaURL] as? URL {
//                parent.videoURL = url
//            }
//            parent.isPresented = false
//        }
//
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.isPresented = false
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//
//        // ✅ Check if the camera is available
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            DispatchQueue.main.async {
//                self.isPresented = false
//            }
//            return picker
//        }
//
//        picker.delegate = context.coordinator
//        picker.sourceType = .camera
//        picker.mediaTypes = ["public.movie"]  // 🎥 Ensures it's for video
//        picker.videoQuality = .typeMedium
//        picker.cameraCaptureMode = .video
//        
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//}
