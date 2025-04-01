import GoogleMobileAds
import Foundation

class NativeAdEcpm: NSObject, ObservableObject, GADNativeAdLoaderDelegate {
    private var tag: String = "haudau NativeAdEcpm"
    @Published var nativeAd: GADNativeAd?
    private var adLoader: GADAdLoader!
    private var adUnit: String! = ""
    private var videoOptions: GADVideoOptions!
    private var nativeAdViewOptions: GADNativeAdViewAdOptions!
    private var multipleImageOptions: GADNativeAdImageAdLoaderOptions!
    private var mediaOptions: GADNativeAdMediaAdLoaderOptions!
    
    var listener: NativeAdListenerWrapper? // Weak reference to prevent retain cycle
    
    init(adUnit: String) {
        super.init()
        self.adUnit = adUnit
        setupNativeOptions()
    }
    
    func setupNativeOptions() {
        
        videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
        
        nativeAdViewOptions = GADNativeAdViewAdOptions()
        nativeAdViewOptions.preferredAdChoicesPosition = .bottomLeftCorner
        
        multipleImageOptions = GADNativeAdImageAdLoaderOptions()
        multipleImageOptions.shouldRequestMultipleImages = true
        
        mediaOptions = GADNativeAdMediaAdLoaderOptions()
        mediaOptions.mediaAspectRatio = GADMediaAspectRatio.any
    }
    
    func loadAd() {
        print("haudau NativeAdEcpm LoadAd \(adUnit) | \(listener == nil)")
        listener?.onAdLoading() // Notify listener that ad is loading
        adLoader = GADAdLoader(
            adUnitID: adUnit,
            rootViewController: nil,
            adTypes: [.native],
            options: [
                videoOptions,
                nativeAdViewOptions,
                multipleImageOptions,
                mediaOptions
            ]
        )
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        print("haudau NativeAdEcpm success nativeAd = \(nativeAd)")
        nativeAd.delegate = self
        listener?.onLoadSuccess(nativeAd) // Notify listener of success
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("haudau NativeAdEcpm failed with error: \(error.localizedDescription)")
        listener?.onLoadFail(error) // Notify listener of failure
    }
    
    func destroy() {
        nativeAd?.delegate = nil
        nativeAd = nil
    }
  
}

extension NativeAdEcpm: GADNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("\(tag) \(#function) called")
        listener?.onAdClicked() // Notify listener of ad click
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdDidRecord(_ nativeAd: GADNativeAd, didRecord adValue: GADAdValue) {
        listener?.onAdPaidEvent(adValue.value,adValue.currencyCode) // Notify listener of paid event
    }
}
