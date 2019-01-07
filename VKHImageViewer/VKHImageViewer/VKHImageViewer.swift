//
//  VKHImageViewer.swift
//  PhotoBrowserSwift
//
//  Created by Vlad Khodiachiy on 12/12/18.
//  Copyright © 2018 Vlad Khodiachiy. All rights reserved.
//

import UIKit

public class VKHImageViewer: UIPageViewController {
    
    //Set text color for Labels. Default is white.
    public var textColor: UIColor = .white
    
    //Set background color for viewController. Default is black.
    public var backgroundColor: UIColor = .black
    
    //If for some reason it is not possible to display a picture, it will be replaced by this.
    public var placeHolderImage: UIImage?
    
    //Set status bar visibility. Default is false.
    public var displayStatusBar: Bool = false
    
    //Set name label visibility. Default is true.
    public var displayNameLabel: Bool = true
    
    //Set count label visibility. Default is true.
    public var displayCountLabel: Bool = true
    
    //Array of images object.
    private var images:[AnyObject]!
    
    //Array of names. If set single name for all controller, array will be fillings with one string.
    private var names: [String]!
    
    //Array of page controllers
    private var imageViewControllers = [UIViewController]()
    
    //UILabels
    private var nameLabel: UILabel!
    private var countLabel: UILabel!
    
    //Index of start image.
    private var currentIndex: Int!
    
    
    //MARK: - Init
    
    //Init with different names for different controllers
    public init(names: [String], images: [AnyObject], currentIndex: Int = 0) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options:nil)
        self.names = names
        setValues(images: images, currentIndex: currentIndex)
    }
    
    //Init with one name for all PageControllers
    public init(name: String, images: [AnyObject], currentIndex: Int = 0) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options:nil)
        self.names = Array(repeating: name, count: images.count)
        setValues(images: images, currentIndex: currentIndex)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setValues(images: [AnyObject],currentIndex: Int) {
        self.images = images
        
        if currentIndex > (images.count - 1) || currentIndex < 0 {
            print("ERROR: currentIndex invalid")
            self.currentIndex = 0
        } else {
            self.currentIndex = currentIndex
        }
        
        self.delegate = self
        self.dataSource = self
        
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    //MARK: - ViewDidLoad
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        createPhotoViewControllers()
        createNameLabel()
        createCountlabel()
        
        view.backgroundColor = backgroundColor
    }
    
    public override var prefersStatusBarHidden: Bool {
        return !displayStatusBar
    }
    
    private func createPhotoViewControllers() {
        for i in 0..<images.count {
            let controller = VKHImageViewController(image: images[i], index: i)
            controller.delegate = self
            controller.placeHolderImage = placeHolderImage
            imageViewControllers.append(controller)
        }
        setViewControllers([imageViewControllers[currentIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    //MARK: - Create Labels
    
    private func createNameLabel() {
        let heightNameLabel: CGFloat = 40
        nameLabel = UILabel(frame: CGRect(x: 0, y: view.bounds.height - heightNameLabel - 10, width: view.bounds.width, height: heightNameLabel))
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.autoresizingMask = [.flexibleTopMargin,.flexibleWidth]
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textColor = textColor
        nameLabel.isHidden = !displayNameLabel
        
        view.addSubview(nameLabel)
    }
    
    private func createCountlabel() {
        let heightCountLabel: CGFloat = 20
        let yNameLabel = nameLabel.frame.origin.y
        
        countLabel = UILabel(frame: CGRect(x: 0, y: yNameLabel - heightCountLabel, width: view.bounds.width, height: heightCountLabel))
        
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 12)
        countLabel.autoresizingMask = [.flexibleTopMargin,.flexibleWidth]
        countLabel.textColor = textColor
        countLabel.isHidden = !displayCountLabel
        
        updateLabels(index: currentIndex)
        
        view.addSubview(countLabel)
    }
    
    private func updateLabels(index: Int) {
        countLabel.text = "\(index + 1)/\(imageViewControllers.count)"
        if index >= names.count {
            nameLabel.text = ""
        } else {
            nameLabel.text = names[index]
        }
    }
}


//MARK: - UIPageViewControllerDataSource

extension VKHImageViewer: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? VKHImageViewController {
            var index = vc.indexPage
            if index == 0 {
                return nil
            } else {
                index -= 1
                let vc = imageViewControllers[index]
                return vc
            }
        } else {
            return nil
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? VKHImageViewController {
            var index = vc.indexPage
            if index == (imageViewControllers.count - 1) {
                return nil
            } else {
                index += 1
                let vc = imageViewControllers[index]
                return vc
            }
        } else {
            return nil
        }
    }
}


//MARK: - UIPageViewControllerDelegate

extension VKHImageViewer: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first as? VKHImageViewController {
            updateLabels(index: vc.indexPage)
        }
    }
}

//MARK: - VKHImageViewControllerDelegate

extension VKHImageViewer: VKHImageViewControllerDelegate {
    public func tapForCloseController() {
        dismiss(animated: false, completion: nil)
    }
}
