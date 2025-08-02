//
//  CustomTabBar.swift
//  PictureAndVideo
//
//  Created by iKame Elite Fresher 2025 on 8/1/25.
//

import Foundation
import UIKit

class CustomTabBar : UITabBarController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    let btnMiddle : UIButton = {
       let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        btn.setTitle("", for: .normal)
        btn.backgroundColor = UIColor(.neutral1)
        btn.layer.cornerRadius = 40
        btn.layer.shadowColor = UIColor.neutral5.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 4, height: 4)
        btn.setImage(UIImage(named: "ic_camera"), for: .normal)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        addSomeTabItems()
        btnMiddle.frame = CGRect(x: Int(self.tabBar.bounds.width)/2 - 70/2, y: -30, width: 70, height: 70)
        btnMiddle.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
    }
    override func loadView() {
        super.loadView()
        self.tabBar.addSubview(btnMiddle)
        setupCustomTabBar()
    }
    func setupCustomTabBar() {
        let path : UIBezierPath = getPathForTabBar()
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.lineWidth = 3
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.white.cgColor
        self.tabBar.layer.insertSublayer(shape, at: 0)
        self.tabBar.itemWidth = 40
        self.tabBar.itemPositioning = .centered
        self.tabBar.itemSpacing = 180
        self.tabBar.tintColor = UIColor(.neutral5)
    }
    
    func addSomeTabItems() {
        let vc1 = UINavigationController(rootViewController: Home())
        let vc2 = UINavigationController(rootViewController: ImportPhoto())
        vc1.title = "Home"
        vc2.title = "Photo"
        setViewControllers([vc1, vc2], animated: false)
        guard let items = tabBar.items else { return}
        items[0].image = UIImage(named: "ic_home")
        items[1].image = UIImage(named: "ic_photo")
    }
    
    func getPathForTabBar() -> UIBezierPath {
        let frameWidth = self.tabBar.bounds.width
        let frameHeight = self.tabBar.bounds.height + 20
        let holeWidth = 150
        let holeHeight = 50
        let leftXUntilHole = Int(frameWidth/2) - Int(holeWidth/2)
        
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: leftXUntilHole , y: 0)) // 1.Line
        path.addCurve(to: CGPoint(x: leftXUntilHole + (holeWidth/3), y: holeHeight/2), controlPoint1: CGPoint(x: leftXUntilHole + ((holeWidth/3)/8)*6,y: 0), controlPoint2: CGPoint(x: leftXUntilHole + ((holeWidth/3)/8)*8, y: holeHeight/2)) // part I
        
        path.addCurve(to: CGPoint(x: leftXUntilHole + (2*holeWidth)/3, y: holeHeight/2), controlPoint1: CGPoint(x: leftXUntilHole + (holeWidth/3) + (holeWidth/3)/3*2/5, y: (holeHeight/2)*6/4), controlPoint2: CGPoint(x: leftXUntilHole + (holeWidth/3) + (holeWidth/3)/3*2 + (holeWidth/3)/3*3/5, y: (holeHeight/2)*6/4)) // part II
        
        path.addCurve(to: CGPoint(x: leftXUntilHole + holeWidth, y: 0), controlPoint1: CGPoint(x: leftXUntilHole + (2*holeWidth)/3,y: holeHeight/2), controlPoint2: CGPoint(x: leftXUntilHole + (2*holeWidth)/3 + (holeWidth/3)*2/8, y: 0)) // part III
        path.addLine(to: CGPoint(x: frameWidth, y: 0)) // 2. Line
        path.addLine(to: CGPoint(x: frameWidth, y: frameHeight)) // 3. Line
        path.addLine(to: CGPoint(x: 0, y: frameHeight)) // 4. Line
        path.addLine(to: CGPoint(x: 0, y: 0)) // 5. Line
        path.close()
        return path
    }
    
    @objc func didTapCameraButton() {
        let cameraVC = Camera()
        let nav = UINavigationController(rootViewController: cameraVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
//            print("Camera không khả dụng")
//            return
//        }
//
//        let picker = UIImagePickerController()
//        picker.sourceType = .camera
//        picker.delegate = self
//        picker.allowsEditing = false
//        present(picker, animated: true)
    }
}
