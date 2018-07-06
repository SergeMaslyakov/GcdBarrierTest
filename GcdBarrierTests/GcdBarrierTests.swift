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

    private let readQueue = DispatchQueue(label: "ReadQueue", qos: .default, attributes: .concurrent)
    private let writeQueue = DispatchQueue(label: "WriteQueue", qos: .default, attributes: .concurrent)

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

        for idx in 1..<1001 {

            readGroup.enter()
            readQueue.asyncAfter(deadline: .now() + .milliseconds(100 + idx), execute: {
                let token = self.dataHolder?.getAccessToken()
                print("Read token: \(token ?? "nil")")

                readGroup.leave()
            })

            if idx % 2 == 0 {
                writeGroup.enter()
                writeQueue.asyncAfter(deadline: .now() + .milliseconds(100 + idx), execute: {
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
