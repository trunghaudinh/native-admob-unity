import UIKit
import GoogleMobileAds

class NativeCollapseContentView: UIView {
    //    private let nativeAd: GADNativeAd
    private var isAdLoaded: Bool = false
    private var admodNativeCollapseListener: AdmobNativeCollapseListener?
    private var nativeAdView: NativeAdView!
    
    private var closeButton: UIButton!
    
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Load the ad view from the nib
        nativeAdView = Bundle.main.loadNibNamed("NativeCollapseAdView", owner: nil, options: nil)?.first as? NativeAdView
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
        if let image = UIImage(named: "ic_arrow_down") {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            closeButton.setImage(tintedImage, for: .normal)
        }
        closeButton.tintColor = .white
        closeButton.isUserInteractionEnabled = true
        closeButton.backgroundColor = .gray.withAlphaComponent(0.7)
        closeButton.layer.cornerRadius = 16
        closeButton.clipsToBounds = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.isUserInteractionEnabled = true
        
        
        nativeAdView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 36), // 10px from top
            closeButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -36) // 30px from right
        ])
    }
    
    
    @objc private func closeButtonTapped() {
        print("Close button tapped")
        admodNativeCollapseListener?.onMinimize()
        nativeAdView.mediaView?.isHidden = true
        closeButton.isHidden = true

        // Cập nhật layout để thu gọn view
        UIView.animate(withDuration: 0) {
            self.frame = CGRect(x: self.frame.origin.x,
                                y: self.superview?.frame.height ?? self.frame.origin.y,
                                width: self.frame.width,
                                height: 0)
            self.layoutIfNeeded()
        }
        
        nativeAdView.setNeedsLayout()
        nativeAdView.layoutIfNeeded()
    }
    
    
    
    
    func setAdLoaded(isAdLoaded: Bool) {
        self.isAdLoaded = isAdLoaded
    }
    
    func setListener(listener: AdmobNativeCollapseListener){
        self.admodNativeCollapseListener = listener
    }
    
    func isLoaded() -> Bool {
        return isAdLoaded
    }
    
    func fillData(nativeAd: NativeAd) {
        
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
        
        //        if let mediaContent = nativeAd.mediaContent.mainImage {
        //            let blurredImageView = UIImageView(frame: nativeAdView.bounds)
        //            blurredImageView.image = applyBlurEffect(to: mediaContent)
        //            blurredImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //            blurredImageView.contentMode = .scaleAspectFill
        //
        //            nativeAdView.mediaView?.insertSubview(blurredImageView, at: 0)
        //        }
        
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
    
}
