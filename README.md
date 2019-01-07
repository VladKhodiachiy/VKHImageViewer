<h1 align="center">VKHImageViewer</h1>
<H4 align="center"> Simple Image/Photo browser in Swift.</H4>


# VKHImageViewer

![sample](Screenshots/first_example.gif)

## Installing

### CocoaPods
Available on CocoaPods. Just add the following to your project Podfile:

```
pod 'VKHImageViewer'
```

### Manually

Add `VKHImageViewer.swift` anad `VKHImageViewController.swift` files to you project.

## Usege

Add `import VKHImageViewer` at the top of the Swift file.

In the viewController:
```
let imagesArray = [UIImage(named:"*.*"), "https://*.jpg", URL(string: "https://*.png")] as [AnyObject]

let arrayNames = ["one","two","three"]
let pageVC = VKHImageViewer(names: arrayNames, images: imagesArray)
pageVC.modalPresentationStyle = .overCurrentContext
pageVC.placeHolderImage = UIImage(named: "error-icon.png")

present(pageVC, animated: true, completion: nil)
```

If you want use one name for all images then:
```
let pageV = VKHImageViewer(name: "name", images: imagesArray)

```

If you want set start index (default is 0) use: 
```
let page = VKHImageViewer(name: "name", images: imagesArray, currentIndex: 2)

```
or 

```
let page = VKHImageViewer(names: arrayNames, images: imagesArray, currentIndex: 2)

```

## Custom

```
pageVC.textColor: UIColor = .white      // Set text color for Labels. Default is white.
pageVC.backgroundColor: UIColor = .black        //Set background color for viewController. Default is black.
pageVC.placeHolderImage: UIImage?       //If for some reason it is not possible to display a picture, it will be replaced by this.
pageVC.displayStatusBar: Bool = false       //Set status bar visibility. Default is false.
pageVC.displayNameLabel: Bool = true        //Set name label visibility. Default is true.
pageVC.displayCountLabel: Bool = true       //Set count label visibility. Default is true.

```
## Author

* **Vlad Khodiachiy** - *Initial work* - [VladKhodiachiy](https://github.com/VladKhodiachiy)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


## Example rotation

![sample](Screenshots/second_example.gif)
