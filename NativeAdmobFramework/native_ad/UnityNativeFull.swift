//
//  UnityNativeFull.swift
//  NativeAdmobSDK
//
//  Created by DinhTrungHau on 13/2/25.
//

import Foundation
import GoogleMobileAds
import SwiftUI

class AdmobNativeFullScreenListener: AnyObject {
    let onAdClosed: () -> Void
    let onAdShowFailed:() -> Void
    init( onAdClosed: @escaping () -> Void,onAdShowFailed: @escaping () -> Void){
        self.onAdClosed = onAdClosed
        self.onAdShowFailed = onAdShowFailed
    }
}

class UnityNativeFull: UnityNativeAd {
    
    private var tag: String = "UnityNativeFull"
    
    private var mListenerGameObject: String = ""
    
    
    private weak var viewController: UIViewController?
    
    private var nativeViewModel = NativeAdmobViewModel()
    
    private var nativeFullAdView : NativeFullContentView!
    
    var onAdLoaded: ((NativeAd) -> Void)?
    
    override func setupNativeKey(viewController: UIViewController, nativeKey: String) {
        super.setupNativeKey(viewController: viewController, nativeKey: nativeKey)
        
        self.viewController = viewController
        
        nativeFullAdView = NativeFullContentView()
    }
    
    func isNativeFullLoaded() -> Bool {
        return nativeViewModel.nativeAd != nil
    }
    
    
    func loadNativeFull(listenerGameObject: String) {
        mListenerGameObject = listenerGameObject
        print("haudau loadNativeFull")
        let nativeAdListener = NativeAdListenerWrapper(
            onLoadSuccess: { ad in
                print("haudau loadNativeFull success \(ad)")
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onLoadSuccess", message: "")
                self.onAdLoaded?(ad)
                self.nativeViewModel.updateAd(nativeAd: ad) // Cập nhật quảng cáo vào viewModel
                
            },
            onLoadFail: { error in
                print("haudau loadNativeFull Ad failed to load: \(error.localizedDescription)")
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onLoadFail", message: "")
            },
            onAdLoading: {
                print("haudau loadNativeFull Ad is loading...")
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdLoading", message: "")
            },
            onAdShow: {
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdShow", message: "")
            },
            onAdClicked: {
                print("haudau loadNativeFull Ad clicked")
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "onAdClicked", message: "")
            },
            onAdPaidEvent: { adValue, currencyCode in
                print("haudau  loadNativeFull Ad generated revenue: \(adValue) \(currencyCode)")
                self.sendUnityEvent(gameObject: listenerGameObject, methodName: "OnAdPaidEvent", message: "\(adValue)|\(currencyCode)")
            }
        )
        
        loadNativeAd(listener: nativeAdListener)
    }
    
    
    func showNativeFull(listenerGameObject: String) {
        DispatchQueue.main.async {
            print("haudau showNativeFull: ViewModel instance = \(Unmanaged.passUnretained(self.nativeViewModel).toOpaque())")
            print("haudau showNativeFull: nativeAd111 = \(String(describing: self.nativeViewModel.nativeAd))")
            
            guard let viewController = self.viewController else {
                print("ViewController is not set")
                return
            }
            
            guard let nativeAd = self.nativeViewModel.nativeAd else {
                self.sendUnityEvent(gameObject: listenerGameObject, methodName:"onAdShowFailed", message: "")
                print("haudau showCollapse: nativeAd is nil")
                return
            }
            
            
            let listener = AdmobNativeFullScreenListener(
                onAdClosed: {
                    self.destroyNativeAd()
                    self.sendUnityEvent(gameObject: listenerGameObject, methodName:"onAdClosed", message: "")
                    
                },
                onAdShowFailed: {
                    self.sendUnityEvent(gameObject: listenerGameObject, methodName:"onAdShowFailed", message: "")
                }
            )

        
            self.nativeFullAdView.fillData(nativeAd: nativeAd)
            self.nativeFullAdView.setListener(admodNativeFullScreenListener: listener)
            
            self.nativeFullAdView.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.addSubview(self.nativeFullAdView)
            
            NSLayoutConstraint.activate([
                self.nativeFullAdView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                self.nativeFullAdView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                self.nativeFullAdView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                self.nativeFullAdView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                viewController.modalPresentationStyle = .fullScreen
                rootVC.present(viewController, animated: true)
            }}
    }
    
}
