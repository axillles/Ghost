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
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var isSetup = false
    
    private override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        // Не проверяем повторно, если уже авторизованы
        guard !isAuthorized else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async { [weak self] in
                self?.isAuthorized = true
            }
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                if status {
                    DispatchQueue.main.async {
                        self?.isAuthorized = true
                    }
                    self?.setup()
                }
            }
        default:
            DispatchQueue.main.async { [weak self] in
                self?.isAuthorized = false
            }
        }
    }
    
    func setup() {
        // Не настраиваем повторно, если уже настроено
        guard !isSetup else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Проверяем, не запущена ли уже сессия
            if self.session.isRunning {
                self.isSetup = true
                return
            }
            
            do {
                self.session.beginConfiguration()
                
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    self.session.commitConfiguration()
                    return
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                
                self.session.commitConfiguration()
                self.session.startRunning()
                self.isSetup = true
            } catch {
                self.session.commitConfiguration()
                print("Camera setup error: \(error)")
            }
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
