import Foundation
import GoogleMobileAds
import SwiftUI

class AdmobNativeCollapseListener: AnyObject {
    let onMinimize: () -> Void
    let onAdShowFailed:() -> Void
    init( onMinimize: @escaping () -> Void,onAdShowFailed: @escaping () -> Void){
        self.onMinimize = onMinimize
        self.onAdShowFailed = onAdShowFailed
    }
}


class UnityNativeCollapse: UnityNativeAd {
    private var mListenerGameObject: String = ""
    private var isAutoReload: Bool  = false
    private var isAutoShow: Bool  = false
    private var nativeViewModel = NativeAdmobViewModel()
    
    private var nativeCollapseView : NativeCollapseContentView!
    
    var onAdLoaded: ((NativeAd) -> Void)?
    

    
    override func setupNativeKey( nativeKey: String) {
        super.setupNativeKey(nativeKey: nativeKey)
        nativeCollapseView = NativeCollapseContentView()
    }
    
    func setAutoShow(_ autoShow: Bool) {
        isAutoShow = autoShow
    }
    
    func loadAndShowAds(listenerGameObject: String) {
        isAutoShow = true
        loadCollapse(listenerGameObject: listenerGameObject)
    }
    
    
    func loadCollapse(listenerGameObject: String) {
        mListenerGameObject = listenerGameObject
        print("haudau loadCollapse")
        loadNativeCollapse(listenerGameObject: mListenerGameObject)
    }
    
    func loadNativeCollapse(listenerGameObject: String) {
        print("haudau loadNativeCollapse")
        let nativeAdListener = NativeAdListenerWrapper(
            onLoadSuccess: { ad in
                print("haudau loadNativeCollapse success \(ad)")
                self.onAdLoaded?(ad)
                self.nativeViewModel.updateAd(nativeAd: ad) // Cập nhật quảng cáo vào viewModel
            
                if self.isAutoShow {
                    self.showCollapse(listenerGameObject: listenerGameObject)
                }
            },
            onLoadFail: { error in
                print("haudau loadNativeCollapse Ad failed to load: \(error.localizedDescription)")
            },
            onAdLoading: {
                print("haudau loadNativeCollapse Ad is loading...")
            },onAdShow: {},
            onAdClicked: {
                print("haudau loadNativeCollapse Ad clicked")
            },
            onAdPaidEvent: { adValue, currencyCode in
                print("haudau  loadNativeCollapse Ad generated revenue: \(adValue) \(currencyCode)")
            }
        )
        
        loadNativeAd(listener: nativeAdListener)
    }
    
    func showCollapse(listenerGameObject: String) {
        DispatchQueue.main.async {
            print("haudau showCollapse: ViewModel instance = \(Unmanaged.passUnretained(self.nativeViewModel).toOpaque())")
            print("haudau showCollapse: nativeAd111 = \(self.nativeViewModel.nativeAd)")
            
            guard let viewController = self.uiViewController else {
                print("ViewController is not set")
                return
            }
            
            guard let nativeAd = self.nativeViewModel.nativeAd else {
                print("haudau showCollapse: nativeAd is nil")
                self.sendUnityEvent(gameObject: listenerGameObject, methodName:"onAdShowFailed", message: "")
                return
            }
            
            self.isAutoShow = false
            
            let listener = AdmobNativeCollapseListener(
                onMinimize: {
                    self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onMinimize", message: "")
                },
                onAdShowFailed: {
                    self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdShowFailed", message: "")
                }
            )
            
            
            self.nativeCollapseView.fillData(nativeAd: nativeAd)
            self.nativeCollapseView.setListener(listener: listener)
            
            
            
            
            viewController.view.addSubview( self.nativeCollapseView)
            
            // Set constraints
            self.nativeCollapseView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.nativeCollapseView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                self.nativeCollapseView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                self.nativeCollapseView.heightAnchor.constraint(equalToConstant: 300),
                self.nativeCollapseView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])
            
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                viewController.modalPresentationStyle = .overCurrentContext
                rootVC.present(viewController, animated: true)
            }
        }
    }
    
    

    
//    func setAutoReload(_ reload: Bool) {
//        isAutoReload = reload
//    }
}
