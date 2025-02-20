import UIKit
import UnityFramework

// Abstract class UnityNativeAd
public class UnityNativeAd {
    private var nativeAd: NativeAdEcpm?
    private var mKeyNativeAd: String = ""
    private var uiViewController: UIViewController?
    public init() { }
    public func setupNativeKey(viewController: UIViewController, nativeKey: String) {
        self.uiViewController = viewController
        nativeAd = NativeAdEcpm(adUnit: nativeKey)
    }
    
    
    public func loadNativeAd(listener : NativeAdListenerWrapper) {
        print("haudau UnityNativeAd loadNativeAd listner = nil \(listener == nil)")
        nativeAd?.listener = listener
        nativeAd?.loadAd()
    }
    
    func sendUnityEvent(gameObject: String, methodName: String, message: String) {
        guard let unityFramework = UnityFramework.getInstance() else {
            print("UnityFramework instance is nil")
            return
        }
        
        unityFramework.sendMessageToGO(
            withName: gameObject,
            functionName: methodName,
            message: message
        )
        
        print("Sent Unity Event -> GameObject: \(gameObject), Method: \(methodName), Message: \(message)")
    }
    
    func destroyNativeAd() {
        nativeAd?.destroy()
    }
    
    func randomKey() -> String {
        return "\(Int(Date().timeIntervalSince1970 * 1000))\(Int.random(in: Int.min...Int.max))"
    }
}
