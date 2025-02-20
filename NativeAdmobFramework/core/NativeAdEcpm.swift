import GoogleMobileAds
import Foundation

class NativeAdEcpm: NSObject, ObservableObject, NativeAdLoaderDelegate {
    private var tag: String = "haudau NativeAdEcpm"
    @Published var nativeAd: NativeAd?
    private var adLoader: AdLoader!
    private var adUnit: String! = ""
    private var videoOptions: VideoOptions!
    private var nativeAdViewOptions: NativeAdViewAdOptions!
    private var multipleImageOptions: NativeAdImageAdLoaderOptions!
    private var mediaOptions: NativeAdMediaAdLoaderOptions!
    
    var listener: NativeAdListenerWrapper? // Weak reference to prevent retain cycle
    
    init(adUnit: String) {
        super.init()
        self.adUnit = adUnit
        setupNativeOptions()
    }
    
    func setupNativeOptions() {
        
        videoOptions = VideoOptions()
        videoOptions.shouldStartMuted = true
        
        nativeAdViewOptions = NativeAdViewAdOptions()
        nativeAdViewOptions.preferredAdChoicesPosition = .bottomLeftCorner
        
        multipleImageOptions = NativeAdImageAdLoaderOptions()
        multipleImageOptions.shouldRequestMultipleImages = true
        
        mediaOptions = NativeAdMediaAdLoaderOptions()
        mediaOptions.mediaAspectRatio = MediaAspectRatio.any
    }
    
    func loadAd() {
        print("haudau NativeAdEcpm LoadAd \(adUnit) | \(listener == nil)")
        listener?.onAdLoading() // Notify listener that ad is loading
        adLoader = AdLoader(
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
        adLoader.load(Request())
    }
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        print("haudau NativeAdEcpm success nativeAd = \(nativeAd)")
        nativeAd.delegate = self
        listener?.onLoadSuccess(nativeAd) // Notify listener of success
        
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("haudau NativeAdEcpm failed with error: \(error.localizedDescription)")
        listener?.onLoadFail(error) // Notify listener of failure
    }
    
    func destroy() {
        nativeAd?.delegate = nil
        nativeAd = nil
    }
  
}

extension NativeAdEcpm: NativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        print("\(tag) \(#function) called")
        listener?.onAdClicked() // Notify listener of ad click
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
        print("\(tag) \(#function) called")
    }
    
    func nativeAdDidRecord(_ nativeAd: NativeAd, didRecord adValue: AdValue) {
        listener?.onAdPaidEvent(adValue.value,adValue.currencyCode) // Notify listener of paid event
    }
}
