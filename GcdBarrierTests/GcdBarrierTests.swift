//
//  GcdBarrierTests.swift
//  GcdBarrierTests
//
//  Created by Serge Maslyakov on 26/06/2018.
//  Copyright © 2018 SergeM. All rights reserved.
//

import XCTest
@testable import GcdBarrierTest

class GcdBarrierTests: XCTestCase {
    
    private var dataHolder: AsyncDataHolder?
    private var readExpectation: XCTestExpectation?
    private var writeExpectation: XCTestExpectation?

    override func setUp() {
        super.setUp()

        dataHolder = AsyncDataHolder()
        readExpectation = XCTestExpectation(description: "READ")
        writeExpectation = XCTestExpectation(description: "WRITE")
    }

    override func tearDown() {
        dataHolder = nil
        readExpectation = nil
        writeExpectation = nil

        super.tearDown()
    }

    func testAsyncAccess() {
        let readGroup = DispatchGroup()
        let writeGroup = DispatchGroup()

        for idx in 1..<501 {

            readGroup.enter()
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + (0.1 + 0.001 * Double(idx)), execute: {
                _ = self.dataHolder?.getAccessToken()

                readGroup.leave()
            })

            if idx % 2 == 0 {
                writeGroup.enter()
                DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + (0.1 * 0.01 * Double(idx)), execute: {
                    let token = "\(idx)"

                    self.dataHolder?.set(accessToken: token)

                    writeGroup.leave()
                })
            }
        }

        readGroup.notify(queue: .main) {
            print("READ FINISHED")
            self.readExpectation?.fulfill()
        }

        writeGroup.notify(queue: .main) {
            print("WRITE FINISHED")
            self.writeExpectation?.fulfill()
        }

        wait(for: [readExpectation!, writeExpectation!], timeout: 20)
    }
}
