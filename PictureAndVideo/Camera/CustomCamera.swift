//  CustomCamera.swift
//  PictureAndVideo
//
//  Created by iKame Elite Fresher 2025 on 8/4/25.
//

import UIKit
import AVFoundation

class CustomCamera: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // MARK: - Properties
    
    var session: AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    var onImageCaptured: ((UIImage) -> Void)?
    
    // MARK: - UI Elements
    
    private let shutterButon: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 76, height: 76))
        button.layer.cornerRadius = 38
        button.layer.borderWidth = 8
        button.layer.borderColor = UIColor.shutter.cgColor
        button.backgroundColor = .white
        return button
    }()
    
    // MARK: - Camera Switch Variables
    private var isUsingFrontCamera = false
    private var currentInput: AVCaptureDeviceInput?
    
    private var switchCameraButton: UIButton = {
        let switchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        let image = UIImage(named: "ic_switchCamera")
        switchButton.setImage(image, for: .normal)
        switchButton.tintColor = .clear
        switchButton.contentMode = .scaleAspectFit
        switchButton.backgroundColor = .clear
        return switchButton
    }()
    // MARK: - Library Image
    private var imagePicker: UIImagePickerController?
    
    private let libraryButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        let image = UIImage(named: "ic_library")
        button.setImage(image, for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - Close camera
    private let closeCamera: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named: "ic_close")
        button.setImage(image, for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - Flash Optional
    private var currentFlashMode: FlashMode = .off
    
    enum FlashMode {
        case off
        case auto
        case on
    }
    
    private let flashOptional: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named: "ic_flashOff")
        button.setImage(image, for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        
        // Add UI
        view.addSubview(shutterButon)
        view.addSubview(switchCameraButton)
        view.addSubview(libraryButton)
        view.addSubview(closeCamera)
        view.addSubview(flashOptional)
        // Add Actions
        shutterButon.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
        libraryButton.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
        closeCamera.addTarget(self, action: #selector(close), for: .touchUpInside)
        flashOptional.addTarget(self, action: #selector(didTapFlashButton), for: .touchUpInside)
        // Request library permission
        
        // Request camera permission
        checkCameraPermission()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = view.safeAreaInsets.top + 64
        let bottom = view.safeAreaInsets.bottom + 128

        previewLayer.frame = CGRect(
            x: 0,
            y: top,
            width: view.bounds.width,
            height: view.bounds.height - top - bottom
        )
        shutterButon.center = CGPoint(x: view.frame.size.width / 2,
                                      y: view.frame.size.height - 100)
        switchCameraButton.center = CGPoint(x: view.frame.width - 64, y: view.frame.size.height - 100)
        libraryButton.center = CGPoint(x: 64, y: view.frame.size.height - 100)
        closeCamera.center = CGPoint(x: 36, y: 72)
        flashOptional.center = CGPoint(x: view.frame.width - 36, y: 72)
    }
    
    // MARK: - Camera Setup
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCameraUI()
                }
            }
        case .authorized:
            setupCameraUI()
        default:
            break
        }
    }

    private func setupCameraUI() {
        let session = AVCaptureSession()
        self.session = session
        
        configureCameraInput(position: .back) // mặc định camera sau
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func configureCameraInput(position: AVCaptureDevice.Position) {
        guard let session = session else { return }

        if let currentInput = currentInput {
            session.removeInput(currentInput)
        }

        // Thêm input mới
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return
        }

        session.addInput(input)
        currentInput = input
    }

    private func setFlashMode(_ mode: FlashMode) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            switch mode {
            case .on:
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            case .off, .auto:
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("⚠️ Cannot configure torch: \(error)")
        }
    }
    // MARK: - Actions
    
    @objc private func didTapTakePhoto() {
        guard let device = currentInput?.device else { return }

        // Kiểm tra camera có flash hay không
        let hasFlash = device.hasFlash && device.isFlashAvailable

        let settings = AVCapturePhotoSettings()

        if hasFlash {
            switch currentFlashMode {
            case .off:
                settings.flashMode = .off
            case .auto:
                settings.flashMode = .auto
            case .on:
                settings.flashMode = .on
            }
        } else {
            settings.flashMode = .off
        }
        
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
    }

    @objc private func switchCameraTapped() {
        guard let session = session else { return }

        session.beginConfiguration()

        let newPosition: AVCaptureDevice.Position = isUsingFrontCamera ? .back : .front

        configureCameraInput(position: newPosition)
        isUsingFrontCamera.toggle()

        session.commitConfiguration()
    }
    
    @objc private func openLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Thư viện ảnh không khả dụng")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen

        self.imagePicker = picker
        present(picker, animated: true, completion: nil)
    }

    // Không làm gì cả khi người dùng chọn ảnh
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
    }

    // Thoát khi bấm cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
    @objc private func didTapFlashButton() {
        switch currentFlashMode {
        case .off:
            currentFlashMode = .auto
            flashOptional.setImage(UIImage(named: "ic_flashAuto"), for: .normal)
            setFlashMode(.auto)
        case .auto:
            currentFlashMode = .on
            flashOptional.setImage(UIImage(named: "ic_flashOn"), for: .normal)
            setFlashMode(.on)
        case .on:
            currentFlashMode = .off
            flashOptional.setImage(UIImage(named: "ic_flashOff"), for: .normal)
            setFlashMode(.off)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CustomCamera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: (any Error)?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }

        onImageCaptured?(image)

        DispatchQueue.global(qos: .userInitiated).async {
            self.session?.stopRunning()
        }

        // Đóng camera
        dismiss(animated: true)
    }
}
