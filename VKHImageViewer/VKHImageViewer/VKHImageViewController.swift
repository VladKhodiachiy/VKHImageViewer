//
//  VKHImageViewController.swift
//  PhotoBrowserSwift
//
//  Created by Vlad Khodiachiy on 12/12/18.
//  Copyright © 2018 Vlad Khodiachiy. All rights reserved.
//

import UIKit

//Delegate is used to close the VKHImageViewer
public protocol VKHImageViewControllerDelegate: class {
    func tapForCloseController()
}

public class VKHImageViewController: UIViewController {
    
    private var scrollView:UIScrollView!
    private var imageView:UIImageView!
    private var contentImage: UIImage!
    private var dynamicAnimator: UIDynamicAnimator!
    private var attachementBehavior: UIAttachmentBehavior!
    private var firstTouch: CGPoint!
    
    public var imageURL: URL!
    public var placeHolderImage: UIImage?
    public var image: AnyObject
    public var indexPage: Int
    
    public weak var delegate: VKHImageViewControllerDelegate?
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    public init(image: AnyObject, index: Int) {
        self.indexPage = index
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        view.backgroundColor = .clear
        
        configureGestureRecognizer()
        createScrollView()
        showImage()
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        dynamicAnimator.removeAllBehaviors()
        scrollView.setZoomScale(1, animated: true)
        scrollView.frame = view.frame
        if let imageView = imageView {
            imageView.frame = view.bounds
        }
        
    }
    
    private func configureGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        panGestureRecognizer.delegate = self
        
    }
    
    private func showImage() {
        if let string = image as? String, let url = URL(string: string) {
            downloadImage(imageURL: url)
        } else if let image = image as? UIImage {
            contentImage = image
            createImageView()
        } else if let url = image as? URL {
            downloadImage(imageURL: url)
        } else {
            if let placeHolderImage = placeHolderImage {
                self.contentImage = placeHolderImage
                createImageView()
            }
        }
    }
    
    private func createScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        view.addSubview(scrollView)
    }
    
    private func createImageView() {
        imageView = UIImageView(frame: view.bounds)
        imageView.image = contentImage
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.addGestureRecognizer(panGestureRecognizer)
        
        scrollView.addSubview(imageView)
    }
    
    private func downloadImage(imageURL: URL) {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        asyncLoadImage(imageURL: imageURL) { (image, error) in
            activityIndicator.stopAnimating()
            if let image = image {
                self.contentImage = image
            } else if (error != nil) {
                if let placeHolderImage = self.placeHolderImage {
                    self.contentImage = placeHolderImage
                }
            }
            self.createImageView()
        }
    }
    
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        delegate?.tapForCloseController()
    }
    
    @objc func handlePanGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        
        let locationInView = sender.location(in: view)
        
        var alpha: CGFloat = 1
        
        let centerOffset = UIOffset(horizontal: locationInView.x - self.imageView.bounds.midX, vertical: locationInView.y - self.imageView.bounds.midY)
        
        if sender.state == .began {
            
            firstTouch = locationInView
            
            /**
             Add UIDynamicItemBehavior for a small imageView rotation when changed UIPanGestureRecognizer location in view.
             */
            
            let dynamicItemBehavior = UIDynamicItemBehavior(items: [imageView])
            dynamicItemBehavior.allowsRotation = true
            dynamicItemBehavior.friction = 0.5
            dynamicItemBehavior.angularResistance = 0.2
            
            attachementBehavior = UIAttachmentBehavior(item: imageView, offsetFromCenter: centerOffset, attachedToAnchor: locationInView)
            
            dynamicAnimator.removeAllBehaviors()
            dynamicAnimator.addBehavior(attachementBehavior)
            dynamicAnimator.addBehavior(dynamicItemBehavior)
            
        } else if sender.state == .changed {
            
            attachementBehavior.anchorPoint = locationInView
            
            /**
             Сalculate the distance between the center of the view and the center of the imageView.
             Then set alpha for parent.view.backgroundColor between 1.2 and 0.2.
             */
            
            let deltaCenterX = abs(view.center.x - imageView.center.x)
            let deltaCenterY = abs(view.center.y - imageView.center.y)
            
            let width = view.bounds.width / 2
            let height = view.bounds.height / 2
            
            alpha = 1.2 - max(min(deltaCenterX / width ,1), min(deltaCenterY / height,1))
            
        } else if sender.state == .ended {
            
            let velocity = sender.velocity(in: view)
            
            alpha = 1
            
            /**
             When one of the velocity is more than 2000, then we create UIPushBehavior and close Controller.
             */
            
            if abs(velocity.x) > 2000 || abs(velocity.y) > 2000 {
                
                /**
                 Calculate the vector direction of the movement of imageView.
                 Then set UIPushBehavior with motion vector.
                 */
                
                let vector = CGVector(dx: locationInView.x - firstTouch.x, dy: locationInView.y - firstTouch.y)
                let pushBehavior = UIPushBehavior(items: [imageView], mode: .instantaneous)
                pushBehavior.pushDirection = vector
                pushBehavior.magnitude = 600
                pushBehavior.active = true
                dynamicAnimator.removeBehavior(attachementBehavior)
                dynamicAnimator.addBehavior(pushBehavior)
                
                /**
                 Calculate the distance between the center of the imageView and its exit point bounds of the screen.
                 Then calculate the delay after which you need to close the controller.
                 */
                
                let centerX = imageView.center.x
                let centerY = imageView.center.y
                let borderIntersectionPoint = calculateExitPoint(from: firstTouch, to: locationInView)
                let distance = sqrt(pow((borderIntersectionPoint.x - centerX), 2.0) + pow(borderIntersectionPoint.y - centerY, 2.0))
                let delay = 0.4 - distance / max(abs(velocity.x), abs(velocity.y))
                
                alpha = 0.2
                
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(delay)) { [weak self] in
                    self?.delegate?.tapForCloseController()
                }
                
            } else {
                alpha = 1
                resetView()
            }
        } else {
            alpha = 1
            resetView()
        }
        
        if let bgColor = parent?.view.backgroundColor {
            parent?.view.backgroundColor = bgColor.withAlphaComponent(alpha)
        }
    }
    
    private func resetView() {
        scrollView.setZoomScale(1, animated: true)
        dynamicAnimator.removeAllBehaviors()
        UIView.animate(withDuration: 0.3) {
            self.imageView.center = self.view.center
        }
    }
    
    private func calculateExitPoint(from anchor : CGPoint, to point: CGPoint) -> CGPoint {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        var exitPoint : CGPoint = CGPoint()
        let directionV: CGFloat = anchor.y < point.y ? 1 : -1
        let directionH: CGFloat = anchor.x < point.x ? 1 : -1
        let a   = directionV > 0 ? screenHeight - anchor.y : anchor.y
        let a1  = directionV > 0 ? point.y - anchor.y : anchor.y - point.y
        let b1  = directionH > 0 ? point.x - anchor.x : anchor.x - point.x
        let b   = a / (a1 / b1)
        let tgAlpha = b / a
        let b2 = directionH > 0 ? screenWidth - point.x : point.x
        let a2 = b2 / tgAlpha
        exitPoint.x = anchor.x + b * directionH
        exitPoint.y = point.y + a2 * directionV
        if (exitPoint.x > screenWidth) {
            exitPoint.x = screenWidth
        } else if (exitPoint.x < 0) {
            exitPoint.x = 0
        } else {
            exitPoint.y = directionV > 0 ? screenHeight : 0
        }
        return exitPoint
    }
}

//MARK: - UIScrollViewDelegate

extension VKHImageViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}


//MARK: - LoadImage by URL

extension VKHImageViewController {
    internal func asyncLoadImage(imageURL: URL,
                                 runQueue: DispatchQueue = .global(),
                                 completionQueue: DispatchQueue = .main,
                                 completion: @escaping (UIImage?,Error?) -> ()) {
        
        runQueue.async {
            do {
                let data = try Data(contentsOf: imageURL)
                completionQueue.async {
                    completion(UIImage(data: data),nil)
                }
            } catch let error {
                completionQueue.async {
                    completion(nil,error)
                }
            }
        }
    }
}


//MARK: - UIGestureRecognizerDelegate

extension VKHImageViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: view)
            let x = abs(velocity.x)
            let y = abs(velocity.y)
            return y > x
        }
        return true
    }
}
