//
//  JSONTests.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/26/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import XCTest
import SaguaroJSON

class JSONTests: XCTestCase {
    let dataset = TestDataset()
    let jnparser = JNParser()

    func testInstance() {
        let fs = JSON.DateFormatString
        let parser = JSON.jnparser

        XCTAssertNotNil( fs )
        XCTAssertNotNil( parser )

    }

    func testParse() {
        guard let jsonString = dataset.readFixtureFile("user-response.json") else {
            XCTFail( "failed to read json file" )
            return
        }

        guard let map = JSON.parse( jsonString ) else {
            XCTFail( "could not parse string: \( jsonString )")
            return
        }

        print( map )
        XCTAssertEqual( map["status"] as? String, JSONResponseWrapper.Ok, "shoud be ok")
        XCTAssertEqual( map["version"] as? String, "1.0", "version")
        XCTAssertEqual( map["ts"] as? UnixTimestamp, 1435866398489, "timestamp")

        guard let user = map["user"] as? [String:AnyObject] else {
            XCTFail("could not read user node")
            return
        }

        XCTAssertEqual(user["id"] as? String, "782eac7c109311e59549f31803fe7988", "id check")
        XCTAssertEqual(user["status"] as? String, "active", "status")

        guard let org = user["salesOrg"] as? [String:AnyObject] else {
            XCTFail("could not parse sales org from user: \( user )")
            return
        }

        XCTAssertEqual(org["id"] as? String, "0718085a109611e59d35034011efdf8c", "id check")
        XCTAssertEqual(org["status"] as? String, "active", "status")
    }

    func testStringify() {
        let obj = dataset.createComplexJSONMap()

        guard let jsonString = JSON.stringify( obj ) else {
            XCTFail("could not stringify object: \( obj )")
            return
        }

        XCTAssert( jsonString.characters.count > 200, "length" )

        guard let map = JSON.parse( jsonString ) else {
            XCTFail("json string was not valid")
            return
        }

        XCTAssertEqual(obj["name"] as? String, map["name"] as? String, "id match")


    }


}
