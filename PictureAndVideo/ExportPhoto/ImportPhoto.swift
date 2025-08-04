//
//  ImportPhoto.swift
//  PictureAndVideo
//
//  Created by iKame Elite Fresher 2025 on 7/31/25.
//

import UIKit
import PhotosUI

class ImportPhoto: UIViewController {
    
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var labelImages: [UITextField]!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var createPhotoButton: UIButton!
    @IBOutlet weak var finalPhotoBooth: UIImageView!
    @IBOutlet weak var savePhotoButton: UIButton!
    
    private var listImage: [UIImage] = [] {
        didSet {
            if !listImage.isEmpty {
                imageViews.forEach({
                    $0.image = listImage[$0.tag]
                })
            }
        }
    }
    
    private var listText: [NSAttributedString] {
        return labelImages.map({
            .init(string: $0.text ?? "Trống", attributes: textAttributes)
        })
    }
    
    private var finalImage: UIImage?
    
    lazy var textAttributes: [NSAttributedString.Key: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            .font: UIFont.systemFont(ofSize: 16, weight: .heavy),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background0
        addPhotoButton.layer.cornerRadius = 16
        createPhotoButton.layer.cornerRadius = 16
        savePhotoButton.layer.cornerRadius = 16
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false // Đảm bảo các sự kiện chạm khác vẫn hoạt động
        view.addGestureRecognizer(tapGesture)

    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func addPhoto(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        let picker = PHPickerViewController.init(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func createPhoto(_ sender: Any) {
        let frame = finalPhotoBooth.bounds
        let textHeight: CGFloat = 24
        let width = frame.width
        let height = frame.height - textHeight
        let imageCount = listImage.count
        guard imageCount == 5 else { return }

        let imageWidth = width / CGFloat(imageCount)

        let renderer = UIGraphicsImageRenderer(bounds: frame)
        let image = renderer.image { context in
            // Vẽ từng ảnh
            for (index, image) in listImage.enumerated() {
                let rect = CGRect(x: CGFloat(index) * imageWidth, y: 0, width: imageWidth, height: height)
                image.draw(in: rect)
            }

            // Vẽ nền text
            UIColor.systemBrown.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: height, width: width, height: textHeight)).fill()

            // Vẽ tên
            for (index, attributedText) in listText.enumerated() {
                let textRect = CGRect(x: CGFloat(index) * imageWidth, y: height, width: imageWidth, height: textHeight)
                attributedText.draw(with: textRect, options: [.usesLineFragmentOrigin], context: nil)
            }
        }

        finalImage = image
        finalPhotoBooth.image = image
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        if let savedImage = finalImage {
            UIImageWriteToSavedPhotosAlbum(savedImage, nil, nil, nil)
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension ImportPhoto: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard results.count == 5 else {
            print("Cần chọn đủ 5 ảnh")
            return
        }
        var listImage: [UIImage] = []
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self else { return }
                listImage.append(image as! UIImage)
                if listImage.count == 5 {
                    DispatchQueue.main.async {
                        self.listImage = listImage
                    }
                }
            }
        }
    }
}
