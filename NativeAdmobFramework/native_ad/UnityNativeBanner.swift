//
//  UnityNativeFull.swift
//  NativeAdmobSDK
//
//  Created by DinhTrungHau on 13/2/25.
//

import Foundation
import GoogleMobileAds
import SwiftUI

class AdmobNativeBannerListener: AnyObject {
    let onAdShowFailed:() -> Void
    init(onAdShowFailed: @escaping () -> Void){
        self.onAdShowFailed = onAdShowFailed
    }
}



class UnityNativeBanner: UnityNativeAd {
    
    private var tag: String = "UnityNativeBanner"
    
    private var mListenerGameObject: String = ""
    private var isAutoReload: Bool  = false
    private var isAutoShow: Bool  = false
    
    private weak var viewController: UIViewController?
    
    private var nativeBannerView: NativeBannerContentView!
    
    private var nativeViewModel = NativeAdmobViewModel()
    
    
    
    
    var onAdLoaded: ((GADNativeAd) -> Void)?
    

    override func setupNativeKey(viewController: UIViewController, nativeKey: String) {
        super.setupNativeKey(viewController: viewController, nativeKey: nativeKey)
        self.viewController = viewController
        nativeBannerView = NativeBannerContentView()
    }
    
    
    
    func loadNativeBanner(listenerGameObject: String) {
        mListenerGameObject = listenerGameObject
        print("haudau loadNativeBanner")
        let nativeAdListener = NativeAdListenerWrapper(
            onLoadSuccess: { ad in
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onLoadSuccess", message: "")
                print("haudau loadNativeCollapse success \(ad)")
                self.onAdLoaded?(ad)
                self.nativeViewModel.updateAd(nativeAd: ad) // Cập nhật quảng cáo vào viewModel
                
                if self.isAutoShow {
                    self.showNativeBanner(listenerGameObject: listenerGameObject)
                }
            },
            onLoadFail: { error in
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onLoadFail", message: "")
                print("haudau loadNativeCollapse Ad failed to load: \(error.localizedDescription)")
            },
            onAdLoading: {
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdLoading", message: "")
                print("haudau loadNativeCollapse Ad is loading...")
            },onAdShow: {
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdShow", message: "")
            },
            onAdClicked: {
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdClicked", message: "")
                print("haudau loadNativeCollapse Ad clicked")
            },
            onAdPaidEvent: { adValue, currencyCode in
                print("haudau  loadNativeCollapse Ad generated revenue: \(adValue) \(currencyCode)")
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "OnAdPaidEvent", message: "\(adValue)|\(currencyCode)")
            }
        )
        
        
        loadNativeAd(listener: nativeAdListener)
    }
    
    
    func showNativeBanner(listenerGameObject: String) {
        DispatchQueue.main.async {
            print("haudau showCollapse: ViewModel instance = \(Unmanaged.passUnretained(self.nativeViewModel).toOpaque())")
            print("haudau showCollapse: nativeAd111 = \(self.nativeViewModel.nativeAd)")
            
            guard let viewController = self.viewController else {
                print("ViewController is not set")
                return
            }
            
            guard let nativeAd = self.nativeViewModel.nativeAd else {
                self.sendUnityEvent(gameObject: listenerGameObject, methodName:"onAdShowFailed", message: "")
                print("haudau showCollapse: nativeAd is nil")
                return
            }
            
            let listener = AdmobNativeBannerListener(
                onAdShowFailed: {
                    self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdShowFailed", message: "")
                }
            )
            
            self.nativeBannerView.fillData(nativeAd: nativeAd)
            self.nativeBannerView.setListener(listener: listener)
            
            viewController.view.addSubview( self.nativeBannerView)
            
            // Set constraints
            self.nativeBannerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.nativeBannerView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                self.nativeBannerView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                self.nativeBannerView.heightAnchor.constraint(equalToConstant: 115),
                self.nativeBannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])
            
            
            
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                viewController.modalPresentationStyle = .overCurrentContext
                rootVC.present(viewController, animated: true)
            }
        }
    }
    
    func setAutoShow(_ autoShow: Bool) {
        isAutoShow = autoShow
    }
    
    func setAutoReload(_ reload: Bool) {
        isAutoReload = reload
    }
}
