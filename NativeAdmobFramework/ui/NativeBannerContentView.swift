import UIKit
import GoogleMobileAds

class NativeBannerContentView: UIView {
    //    private let nativeAd: GADNativeAd
    private var isAdLoaded: Bool = false
    private var admodNativeBannerListener: AdmobNativeBannerListener?
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
        nativeAdView = Bundle.main.loadNibNamed("NativeBannerAdView", owner: nil, options: nil)?.first as? NativeAdView
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nativeAdView)
        
        NSLayoutConstraint.activate([
            nativeAdView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nativeAdView.topAnchor.constraint(equalTo: topAnchor),
                
            nativeAdView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
     

    }
    

    
    func setAdLoaded(isAdLoaded: Bool) {
        self.isAdLoaded = isAdLoaded
    }
    
    func setListener(listener: AdmobNativeBannerListener){
        self.admodNativeBannerListener = listener
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
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(
          from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
      

        nativeAdView.nativeAd = nativeAd
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return UIImage(named: "star_4")
        }
        if rating >= 5 {
            return UIImage(named: "star_5")
        } else if rating >= 4.5 {
            return UIImage(named: "star_4_5")
        } else if rating >= 4 {
            return UIImage(named: "star_4")
        } else if rating >= 3.5 {
            return UIImage(named: "star_3_5")
        } else {
            return UIImage(named: "star_4")
        }
    }
    
}
