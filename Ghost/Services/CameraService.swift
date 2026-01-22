//
//  CameraService.swift
//  Ghost
//
//  Created by Артем Гаврилов on 20.01.26.
//

import Foundation
import AVFoundation
import SwiftUI

final class CameraService: NSObject, ObservableObject {
    static let shared = CameraService()
    
    @Published var session = AVCaptureSession()
    @Published var preview: AVCaptureVideoPreviewLayer?
    @Published var isAuthorized = false
    
    private override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                if status {
                    DispatchQueue.main.async {
                        self?.isAuthorized = true
                        self?.setup()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    func setup() {
        do {
            session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                session.commitConfiguration()
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            session.commitConfiguration()
            session.startRunning()
        } catch {
            session.commitConfiguration()
            print("Camera setup error: \(error)")
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.frame
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let previewLayer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiViewController.view.frame
        }
    }
}
