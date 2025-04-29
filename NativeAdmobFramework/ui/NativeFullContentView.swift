import UIKit
import GoogleMobileAds

class NativeFullContentView: UIView {
    private var isAdLoaded: Bool = false
    private var admodNativeFullScreenListener: AdmobNativeFullScreenListener?
    private var nativeAdView: NativeAdView!
    
    private var closeButton: UIButton!
    private var whiteCircle: UIView!
    private var countdownTimer: Timer?
    private var countdownValue: Int = 3
    private var closeCTRSize: String = "normal"
    

    var viewContent: UIView {
        return nativeAdView.viewWithTag(999) ?? UIView()
    }
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    func setCloseCTRSize(_ size: String) {
        closeCTRSize = size
        print("haudau setCloseCTRSize2222  \(closeCTRSize)")
        updateCloseButtonSize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCloseButtonSize() {
        let buttonSize = sizeForCloseButton()
        print("haudau updateCloseButtonSize \(buttonSize)")

        // Update lại constraints (xóa image cũ trước nếu cần)
        NSLayoutConstraint.deactivate(closeButton.constraints)
        NSLayoutConstraint.deactivate(whiteCircle.constraints)
        
        NSLayoutConstraint.activate([
            whiteCircle.widthAnchor.constraint(equalToConstant: buttonSize),
            whiteCircle.heightAnchor.constraint(equalToConstant: buttonSize),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        // Update corner radius
        whiteCircle.layer.cornerRadius = buttonSize / 2
        closeButton.layer.cornerRadius = buttonSize / 2

        // Nếu đang là icon thì resize lại
        if closeButton.title(for: .normal) == "" {
            if let originalImage = UIImage(systemName: "xmark") {
                let resizedImage = resizeImage(
                    image: originalImage,
                    targetSize: CGSize(width: buttonSize / 2, height: buttonSize / 2)
                )
                closeButton.setImage(resizedImage, for: .normal)
            }
        }
        
        layoutIfNeeded()
    }

    private func setupView() {
        // Load the ad view from the nib
        nativeAdView = Bundle.main.loadNibNamed("NativeFullAdView", owner: nil, options: nil)?.first as? NativeAdView
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nativeAdView)
        
        NSLayoutConstraint.activate([
            nativeAdView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nativeAdView.topAnchor.constraint(equalTo: topAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let buttonSize = sizeForCloseButton()
        // Tạo circle trắng
        whiteCircle = UIView()
        whiteCircle.backgroundColor = .white
        whiteCircle.layer.cornerRadius = buttonSize / 2 // Bán kính = 26 / 2
        whiteCircle.clipsToBounds = true
        whiteCircle.translatesAutoresizingMaskIntoConstraints = false

        // Add vào nativeAdView (phải add trước closeButton để whiteCircle nằm dưới)
        nativeAdView.addSubview(whiteCircle)
    
        // Layout cho whiteCircle giống hệt closeButton
        NSLayoutConstraint.activate([
            whiteCircle.widthAnchor.constraint(equalToConstant: buttonSize),
            whiteCircle.heightAnchor.constraint(equalToConstant: buttonSize),
            whiteCircle.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 50),
            whiteCircle.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -36)
        ])

        // Create and configure the close button
        closeButton = UIButton(type: .custom)
        closeButton.setTitle("\(countdownValue)", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.layer.cornerRadius = buttonSize / 2
        closeButton.clipsToBounds = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.isUserInteractionEnabled = false
        

        nativeAdView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize),
            closeButton.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 50), // 10px from top
            closeButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -36) // 30px from right
        ])
    }

    
    @objc private func closeButtonTapped() {
        print("Close button tapped")
        // Hủy timer nếu đang chạy
        countdownTimer?.invalidate()
        countdownTimer = nil
        nativeAdView.nativeAd = nil
        admodNativeFullScreenListener?.onAdClosed()
        self.removeFromSuperview()
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    @objc private func updateCountdown() {
        let buttonSize = sizeForCloseButton()
        if countdownValue > 1 {
            countdownValue -= 1
            closeButton.setTitle("\(countdownValue)", for: .normal)
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil

            whiteCircle.isHidden = true
            // Ẩn button
            closeButton.isHidden = true

            // Delay 500ms rồi mới hiện lại + đổi sang icon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.whiteCircle.isHidden = false
                self.closeButton.isHidden = false
                
                self.closeButton.setTitle("", for: .normal)
                self.closeButton.backgroundColor = .clear
                if let originalImage = UIImage(systemName: "xmark") {
                    let resizedImage = self.resizeImage(image: originalImage, targetSize: CGSize(width: buttonSize / 2, height: buttonSize / 2))
                    self.closeButton.setImage(resizedImage, for: .normal)
                    self.closeButton.tintColor = .white
                }

                self.closeButton.isUserInteractionEnabled = true
            }
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func sizeForCloseButton() -> CGFloat {
        switch closeCTRSize {
        case "tiny":
            return 20
        case "small":
            return 26
        case "normal":
            return 32
        case "large":
            return 38
        default:
            return 32
        }
    }

    func setAdLoaded(isAdLoaded: Bool) {
        self.isAdLoaded = isAdLoaded
    }
    
    func setListener(admodNativeFullScreenListener: AdmobNativeFullScreenListener){
        self.admodNativeFullScreenListener = admodNativeFullScreenListener
    }
    
    func isLoaded() -> Bool {
        return isAdLoaded
    }

    func fillData(nativeAd: NativeAd) {
        startCountdown()
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store

        let callToActionView = nativeAdView.callToActionView as? UIButton
        callToActionView?.layer.cornerRadius = 10
        callToActionView?.clipsToBounds = true
        callToActionView?.setTitle(nativeAd.callToAction, for: .normal)
        callToActionView?.isUserInteractionEnabled = false

        nativeAdView.layer.cornerRadius = 0
        nativeAdView.clipsToBounds = true

        (nativeAdView.iconView as? UIImageView)?.layer.cornerRadius = 8

        if let mediaContent = nativeAd.mediaContent.mainImage {
            let blurredImageView = UIImageView(frame: nativeAdView.bounds)
            blurredImageView.image = applyBlurEffect(to: mediaContent)
            blurredImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurredImageView.contentMode = .scaleAspectFill

            nativeAdView.mediaView?.insertSubview(blurredImageView, at: 0)
        }

        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            let heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            heightConstraint.isActive = true
        }

    
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        nativeAdView.nativeAd = nativeAd
    }

    private func applyBlurEffect(to image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)

        guard let ciImage = CIImage(image: image),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            return nil
        }

        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(10.0, forKey: kCIInputRadiusKey)

        guard let outputImage = blurFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }

        let blurredImage = UIImage(cgImage: cgImage)

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        blurredImage.draw(in: CGRect(origin: .zero, size: image.size))
        UIColor.black.withAlphaComponent(0.5).setFill()
        UIRectFillUsingBlendMode(CGRect(origin: .zero, size: image.size), .sourceAtop)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }
    
    func setContentCTR(isAdsContentV1: Bool, isAdsContentV2: Bool, isAdsContentV3: Bool) {
        // First, remove any existing CTR views if they exist
        print("haudau123 setContentCTR2222 \(isAdsContentV1) \(isAdsContentV2) \(isAdsContentV3)")
        
        // Remove existing CTR views from the nativeAdView (not from viewContent)
        nativeAdView.subviews.forEach { view in
            if view.tag >= 1001 && view.tag <= 1003 {
                view.removeFromSuperview()
            }
        }
        
        // Get the safe area top using the recommended approach for iOS 15+
        let safeAreaTop: CGFloat
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            safeAreaTop = windowScene?.windows.first?.safeAreaInsets.top ?? 0
        } else {
            // Fallback for older iOS versions
            safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
        
        // Debug prints
        print("viewContent frame: \(viewContent.frame)")
        print("safeAreaTop: \(safeAreaTop)")
        
        // Calculate the available height between safe area top and viewContent
        let availableHeight = viewContent.frame.minY - safeAreaTop
        let sectionHeight = availableHeight / 3.0
        
        print("Available height: \(availableHeight)")
        print("Section height: \(sectionHeight)")
        
        // Create the three transparent views
        let redView = UIView()
        redView.tag = 1001
        redView.backgroundColor = .clear
        redView.isHidden = isAdsContentV1
        redView.translatesAutoresizingMaskIntoConstraints = false
        
        let yellowView = UIView()
        yellowView.tag = 1002
        yellowView.backgroundColor = .clear
        yellowView.isHidden = isAdsContentV2
        yellowView.translatesAutoresizingMaskIntoConstraints = false
        
        let greenView = UIView()
        greenView.tag = 1003
        greenView.backgroundColor = .clear
        greenView.isHidden = isAdsContentV3
        greenView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the views to the main view
        nativeAdView.addSubview(redView)
        nativeAdView.addSubview(yellowView)
        nativeAdView.addSubview(greenView)
        
        // Debug after adding views
        print("Red view hidden: \(redView.isHidden)")
        print("Yellow view hidden: \(yellowView.isHidden)")
        print("Green view hidden: \(greenView.isHidden)")
        
        // Create equal height constraints for all three views
        let equalHeightConstraint1 = redView.heightAnchor.constraint(equalTo: yellowView.heightAnchor)
        let equalHeightConstraint2 = yellowView.heightAnchor.constraint(equalTo: greenView.heightAnchor)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Red view (Top section)
            redView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            redView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            redView.topAnchor.constraint(equalTo: nativeAdView.safeAreaLayoutGuide.topAnchor),
            
            // Yellow view (Middle section)
            yellowView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            yellowView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            yellowView.topAnchor.constraint(equalTo: redView.bottomAnchor),
            
            // Green view (Bottom section)
            greenView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            greenView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            greenView.topAnchor.constraint(equalTo: yellowView.bottomAnchor),
            greenView.bottomAnchor.constraint(equalTo: viewContent.topAnchor),
            
            // Equal height constraints
            equalHeightConstraint1,
            equalHeightConstraint2
        ])
        
        // Make these views user interaction enabled so they can receive touches
        redView.isUserInteractionEnabled = true
        yellowView.isUserInteractionEnabled = true
        greenView.isUserInteractionEnabled = true
        
        // Add tap gesture recognizers to each view
        let redTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentAreaTapped(_:)))
        let yellowTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentAreaTapped(_:)))
        let greenTapGesture = UITapGestureRecognizer(target: self, action: #selector(contentAreaTapped(_:)))
        
        redView.addGestureRecognizer(redTapGesture)
        yellowView.addGestureRecognizer(yellowTapGesture)
        greenView.addGestureRecognizer(greenTapGesture)
    }

    // Handle tap events on the content areas
    @objc private func contentAreaTapped(_ sender: UITapGestureRecognizer) {
        if let tappedView = sender.view, !tappedView.isHidden {
            print("Content area tapped: \(tappedView.tag)")
            // Prevent the tap from propagating to views underneath
            sender.cancelsTouchesInView = true
            
            // Only handle the click if the view is visible
//            admodNativeFullScreenListener?.onAdClicked()
        }
    }
}
