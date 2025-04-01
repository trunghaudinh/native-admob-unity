import GoogleMobileAds

public class NativeAdListenerWrapper: NSObject, GADNativeAdLoaderDelegate {
    let onLoadSuccess: (GADNativeAd) -> Void
    let onLoadFail: (Error) -> Void
    let onAdLoading: () -> Void
    let onAdShow: () -> Void
    let onAdClicked: () -> Void
    let onAdPaidEvent: (NSDecimalNumber, String) -> Void
    
    public init(onLoadSuccess: @escaping (GADNativeAd) -> Void,
                onLoadFail: @escaping (Error) -> Void,
                onAdLoading: @escaping () -> Void,
                onAdShow: @escaping () -> Void,
                onAdClicked: @escaping () -> Void,
                onAdPaidEvent: @escaping (NSDecimalNumber, String) -> Void) {
        self.onLoadSuccess = onLoadSuccess
        self.onLoadFail = onLoadFail
        self.onAdLoading = onAdLoading
        self.onAdShow = onAdShow
        self.onAdClicked = onAdClicked
        self.onAdPaidEvent = onAdPaidEvent
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        onLoadSuccess(nativeAd)
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        onLoadFail(error)
    }
}
