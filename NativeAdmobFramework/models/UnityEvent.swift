//
//  UnityEvent.swift
//  SwiftUIDemo
//
//  Created by DinhTrungHau on 30/12/2024.
//

import Foundation
public class UnityEvent {
    var gameObj: String
    var methodName: String
    var message: String
    
    init(gameObj: String, methodName: String, message: String) {
        self.gameObj = gameObj
        self.methodName = methodName
        self.message = message
    }
    
    func logEvent() {
        print("Sending event to Unity")
        print("Game Object: \(gameObj)")
        print("Method Name: \(methodName)")
        print("Message: \(message)")
    }
}
