//
//  AsyncDataHolder.swift
//  GcdBarrierTest
//
//  Created by Serge Maslyakov on 26/06/2018.
//  Copyright © 2018 SergeM. All rights reserved.
//

import Foundation

class AsyncDataHolder {

    private let asyncQueue = DispatchQueue(label: "AsyncDataHolderQueue", qos: .background, attributes: .concurrent)
    private var accessToken: String?

    func set(accessToken: String?) {
        asyncQueue.async(flags: .barrier) {
            print("Write token: \(accessToken ?? "nil")")
            self.accessToken = accessToken
        }
    }

    func getAccessToken() -> String? {
        return asyncQueue.sync {
            accessToken
        }
    }
}
