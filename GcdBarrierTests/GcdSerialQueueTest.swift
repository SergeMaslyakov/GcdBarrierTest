//
//  GcdSerialQueueTest.swift
//  GcdBarrierTests
//
//  Created by Serge Maslyakov on 26/07/2018.
//  Copyright © 2018 SergeM. All rights reserved.
//

import XCTest
@testable import GcdBarrierTest

class GcdSerialQueueTest: XCTestCase {

    private var dataHolder: SerialDataHolder?
    private var readExpectation: XCTestExpectation?
    private var writeExpectation: XCTestExpectation?

    private let readQueue = DispatchQueue(label: "ReadQueue", qos: .default, attributes: .concurrent)
    private let writeQueue = DispatchQueue(label: "WriteQueue", qos: .default, attributes: .concurrent)

    override func setUp() {
        super.setUp()

        dataHolder = SerialDataHolder()
        readExpectation = XCTestExpectation(description: "READ")
        writeExpectation = XCTestExpectation(description: "WRITE")
    }

    override func tearDown() {
        dataHolder = nil
        readExpectation = nil
        writeExpectation = nil

        super.tearDown()
    }

    func testAccess() {
        let readGroup = DispatchGroup()
        let writeGroup = DispatchGroup()

        for idx in 1..<1001 {

            readGroup.enter()
            readQueue.asyncAfter(deadline: .now() + (0.1 + 0.001 * Double(idx)), execute: {
                _ = self.dataHolder?.getAccessToken()

                readGroup.leave()
            })

            if idx % 10 == 0 {
                writeGroup.enter()
                writeQueue.asyncAfter(deadline: .now() + (0.1 * 0.01 * Double(idx)), execute: {
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
