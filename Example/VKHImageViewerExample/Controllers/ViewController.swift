//
//  ViewController.swift
//  VKHImageViewerExample
//
//  Created by Vlad Khodiachiy on 1/7/19.
//  Copyright © 2019 Vlad Khodiachiy. All rights reserved.
//

import UIKit
import VKHImageViewer

class ViewController: UIViewController {
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        let imagesArray = [UIImage(named: "image2.jpg"),
                           "https://img.buzzfeed.com/buzzfeed-static/static/enhanced/webdr03/2013/7/25/5/enhanced-buzz-18231-1374744160-12.jpg?downsize=700:*&output-format=auto&output-quality=auto",
                           URL(string: "https://i.pinimg.com/originals/f5/67/90/f567908f371063534eb9e60ce43d7028.jpg"),
                           UIImage(named: "image1.jpg"),
                           "https://i.pinimg.com/236x/ca/d8/f1/cad8f15f9ca918f2925afcfd006f4a66--lumberjacks-wardrobes.jpg"] as [AnyObject]
        
        let arrayNames = ["one","two","three","four","five"]
        let pageVC = VKHImageViewer(names: arrayNames, images: imagesArray)
        let page = VKHImageViewer(name: "name", images: imagesArray, currentIndex: 2)
        pageVC.modalPresentationStyle = .overCurrentContext
        pageVC.placeHolderImage = UIImage(named: "error-icon.png")
        
        present(pageVC, animated: true, completion: nil)
    }
}
