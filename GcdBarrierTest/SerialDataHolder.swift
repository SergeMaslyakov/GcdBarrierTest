//
//  SerialDataHolder.swift
//  GcdBarrierTest
//
//  Created by Serge Maslyakov on 26/07/2018.
//  Copyright © 2018 SergeM. All rights reserved.
//

import Foundation

class SerialDataHolder {

    private let serialQueue = DispatchQueue(label: "SerialDataHolderQueue", qos: .background)
    private var accessToken: String?

    func set(accessToken: String?) {
        serialQueue.async {
            print("Write token: \(accessToken ?? "nil")")
            self.accessToken = accessToken
        }
    }

    func getAccessToken() -> String? {
        return serialQueue.sync {
            accessToken
        }
    }
}
