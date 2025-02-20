//
//  NativeAdListener.swift
//  AdmobNativeSDK
//
//  Created by DinhTrungHau on 25/12/2024.
//

import Foundation
protocol NativeAdListener {
    func onLoadSuccess()
    func onLoadFail()
    func onAdLoading()
    func onAdClicked()
    func onAdPaidEvent(adValue: Int64, currencyCode: String)
}
