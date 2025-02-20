//
//  NativeAdCustomListener.swift
//  AdmobNativeSDK
//
//  Created by DinhTrungHau on 25/12/2024.
//

import Foundation

@objc public protocol NativeAdCustomListener {
    @objc optional func onAdLoading()
    @objc optional func onAdClicked()
    @objc optional func onAdImpression()
    
    func onAdLoaded()
    func onAdLoadFailed()
    func onAdPaidEvent(adValue: Int64, currencyCode: String)
}
