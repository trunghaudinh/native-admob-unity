import UIKit
import GoogleMobileAds

class NativeFullContentView: UIView {
    private var isAdLoaded: Bool = false
    private var admodNativeFullScreenListener: AdmobNativeFullScreenListener?
    private var nativeAdView: GADNativeAdView!
    
    private var closeButton: UIButton!
    private var countdownTimer: Timer?
    private var countdownValue: Int = 3

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // Load the ad view from the nib
        nativeAdView = Bundle.main.loadNibNamed("NativeFullAdView", owner: nil, options: nil)?.first as? GADNativeAdView
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nativeAdView)
        
        NSLayoutConstraint.activate([
            nativeAdView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nativeAdView.topAnchor.constraint(equalTo: topAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Create and configure the close button
        closeButton = UIButton(type: .custom)
        closeButton.setTitle("\(countdownValue)", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .gray
        closeButton.layer.cornerRadius = 18
        closeButton.clipsToBounds = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.isUserInteractionEnabled = false


        nativeAdView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
            closeButton.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 36), // 10px from top
            closeButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -36) // 30px from right
        ])
    }

    
    @objc private func closeButtonTapped() {
        print("Close button tapped")
        admodNativeFullScreenListener?.onAdClosed()
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    @objc private func updateCountdown() {
        if countdownValue > 1 {
            countdownValue -= 1
            closeButton.setTitle("\(countdownValue)", for: .normal)
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
            closeButton.setTitle("", for: .normal)
            if let image = UIImage(named: "ic_arrow_down") {
                let tintedImage = image.withRenderingMode(.alwaysTemplate)
                closeButton.setImage(tintedImage, for: .normal)
            }
            closeButton.isUserInteractionEnabled = true
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

    func fillData(nativeAd: GADNativeAd) {
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
}
