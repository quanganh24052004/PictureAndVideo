//
//  Camera.swift
//  PictureAndVideo
//
//  Created by iKame Elite Fresher 2025 on 7/31/25.
//

import UIKit

class Camera: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageViewOutput: UIView!
    @IBOutlet var imageView: [UIImageView]!
    @IBOutlet weak var button: UIButton!
    
    var picker: UIImagePickerController?
    var hasPresentedCamera = false
    var currentIndex = 0
    var selectedImageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background0
        title = "Camera"
        button.setTitle("Chụp tiếp nè", for: .normal)
        button.layer.cornerRadius = 16

        for (index, imgView) in imageView.enumerated() {
            imgView.isUserInteractionEnabled = true
            imgView.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            imgView.addGestureRecognizer(tapGesture)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasPresentedCamera {
            openCamera()
            hasPresentedCamera = true
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if currentIndex >= imageView.count {
            saveImagesToLibrary()
        } else {
            selectedImageIndex = currentIndex
            openCamera()
        }
    }
    func openCamera() {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            print("Camera không khả dụng")
//            return
//        }
//
//        let picker = UIImagePickerController()
//        picker.sourceType = .camera
//        picker.delegate = self
//        picker.allowsEditing = false
//        self.picker = picker
//        present(picker, animated: true)
        let cameraVC = CustomCamera()
        cameraVC.modalPresentationStyle = .fullScreen
        cameraVC.onImageCaptured = { [weak self] image in
            guard let self else { return }
            if selectedImageIndex < imageView.count {
                self.imageView[selectedImageIndex].image = image
                if selectedImageIndex == currentIndex {
                    currentIndex += 1
                }
                self.updateButtonTitle()
            }
        }
        present(cameraVC, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            if selectedImageIndex < imageView.count {
                imageView[selectedImageIndex].image = image
                if selectedImageIndex == currentIndex {
                    currentIndex += 1
                }
            }
        }
        picker.dismiss(animated: true) {
            self.updateButtonTitle()
        }
    }
    
    func updateButtonTitle() {
        if currentIndex >= imageView.count {
            button.setTitle("Lưu ảnh thôi", for: .normal)
        } else {
            button.setTitle("Chụp tiếp nè", for: .normal)
        }
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        if let tappedImageView = sender.view as? UIImageView {
            selectedImageIndex = tappedImageView.tag
            openCamera()
        }
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
    func saveImagesToLibrary() {
        let image = imageViewOutput.asImage()
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(images(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("❌ Lỗi khi lưu ảnh: \(error.localizedDescription)")
        } else {
            print("✅ Đã lưu ảnh thành công vào thư viện.")
        }
    }
    
    @objc func images(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(
            title: error == nil ? "✅ Lưu thành công" : "❌ Lỗi khi lưu ảnh",
            message: error?.localizedDescription ?? "Ảnh đã được lưu vào thư viện của bạn.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.view.window?.rootViewController?.dismiss(animated: true)        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
