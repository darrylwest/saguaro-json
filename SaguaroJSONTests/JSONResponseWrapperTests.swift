//
//  JSONResponseWrapperTests.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/26/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import XCTest
import SaguaroJSON

class JSONResponseWrapperTests: XCTestCase {
    let dataset = TestDataset()
    let jnparser = JNParser()

    func testJSONReponseWrapper() {
        let ts = jnparser.createUnixTimestamp()
        let jsonObject:[String:AnyObject] = [
            "status":"ok",
            "version":"1.0",
            "ts": ts,
            "model":dataset.createDocumentIdentifierMap()
        ]

        print("json: \( jsonObject )")

        guard let wrapper = JSONResponseWrapper( jsonObject: jsonObject ) else {
            XCTFail("wrapper parser failed")
            return
        }

        XCTAssertEqual( wrapper.status, "ok", "wrapper status should be ok")
        XCTAssertEqual( wrapper.ts, ts, "wrapper time stamp should match")
        XCTAssertEqual( wrapper.version, "1.0", "version match")
    }

    func testJSONResponseWrapperFailed() {
        let ts = jnparser.createUnixTimestamp()
        let jsonObject:[String:AnyObject] = [
            "status":"failed",
            "version":"1.0",
            "ts": ts,
            "reason":"the reason it failed"
        ]

        print("json: \( jsonObject )")

        guard let wrapper = JSONResponseWrapper( jsonObject: jsonObject ) else {
            XCTFail("wrapper parser failed")
            return
        }

        XCTAssertEqual( wrapper.status, "failed", "wrapper status should be ok")
        XCTAssertEqual( wrapper.ts, ts, "wrapper time stamp should match")
        XCTAssertEqual( wrapper.version, "1.0", "version match")
        XCTAssertEqual( wrapper.reason, "the reason it failed", "reason match")
    }
    
}
