//
//  NativeAdmobViewModel.swift
//  SwiftUIDemo
//
//  Created by DinhTrungHau on 30/12/2024.
//

import Foundation
import Combine
import GoogleMobileAds

class NativeAdmobViewModel: ObservableObject {
    @Published var nativeAd: NativeAd?
    init() {
        print("haudau ViewModel init: \(Unmanaged.passUnretained(self).toOpaque())")
    }
    func updateAd(nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        print("haudau NativeAdmobViewModel update \(nativeAd)")
    }
}
