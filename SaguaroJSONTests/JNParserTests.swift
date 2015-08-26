//
//  JNParserTests.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/4/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import XCTest
import SaguaroJSON

class JNParserTests: XCTestCase {
    let dataset = TestDataset()
    let jnparser = JNParser()

    func testStringifyPretty() {
        let obj = dataset.createComplexJSONMap()

        let jstr = jnparser.stringify( obj, pretty:true )!

        print( jstr )
        XCTAssertNotNil(jstr, "should not be nil")

        // not a great test, but it should return predictable results...
        XCTAssert(jstr.characters.count >= 862, "should match the character count")

        let jsonObject = jnparser.parse( jstr )
        print( jsonObject )
        XCTAssertNotNil( jsonObject, "should not be nil")
    }

    func testStringify() {
        let obj = dataset.createComplexJSONMap()

        let jstr = jnparser.stringify( obj )!

        print( jstr )
        XCTAssertNotNil(jstr, "should not be nil")

        // not a great test, but it should return predictable non-pretty length...
        XCTAssert(jstr.characters.count >= 567, "should match the character count")

        let jsonObject = jnparser.parse( jstr )
        print( jsonObject )
        XCTAssertNotNil( jsonObject, "should not be nil")
    }

    func testParse() {
        let complexMap = dataset.createComplexJSONMap()

        // print( doiMap )

        let jstr = jnparser.stringify( complexMap )!

        print( jstr )

        XCTAssertNotNil(jstr, "json string should not be nil")

        let jmap = jnparser.parse( jstr )

        XCTAssertNotNil(jmap, "json map should not be nil")
    }

    func testParseDateFromJSONString() {
        let parts = NSDateComponents()

        parts.year = 2015
        parts.month = 6
        parts.day = 18
        parts.hour = 9
        parts.minute = 47
        parts.second = 49

        let calendar = NSCalendar.currentCalendar()
        guard let date = calendar.dateFromComponents( parts ) else {
            XCTFail("should create a date string")
            return
        }

        guard let ds:String = jnparser.stringFromDate( date ) else {
            XCTFail("should create a date string")
            return
        }

        guard let dt = jnparser.dateFromString( ds ) else {
            XCTFail("should create a date from json string")
            return
        }

        XCTAssertNotNil(dt, "should not be nil")

        XCTAssertEqual(dt, date, "dates should match")

        let parsedParts:NSDateComponents = calendar.components([ .Year, .Month, .Day, .Hour, .Minute, .Second ], fromDate: dt)

        // print( parsedParts )

        XCTAssertEqual(parsedParts.year, parts.year, "should match")
        XCTAssertEqual(parsedParts.month, parts.month, "should match")
        XCTAssertEqual(parsedParts.day, parts.day, "should match")
        XCTAssertEqual(parsedParts.hour, parts.hour, "should match")
        XCTAssertEqual(parsedParts.minute, parts.minute, "should match")
        XCTAssertEqual(parsedParts.second, parts.second, "should match")
    }

    func testParseBadDateFromJSONString() {
        let ds = "2015/06/18 00:47:49"

        let dt = jnparser.dateFromString(ds)

        XCTAssertNil(dt, "should not be nil")
    }

    func testColorToMap() {
        let color = UIColor.grayColor()
        let map = jnparser.colorToMap( color )

        XCTAssertNotNil(map, "should not be nil")

        guard let red = map[ RGBAType.red.rawValue ],
                let green = map[ RGBAType.green.rawValue ],
                let blue = map[ RGBAType.blue.rawValue ],
                let alpha = map[ RGBAType.alpha.rawValue ] else {
            return XCTFail("should have a red color")
        }

        XCTAssertEqual(red, 0.5, "red")
        XCTAssertEqual(green, 0.5, "green")
        XCTAssertEqual(blue, 0.5, "blue")
        XCTAssertEqual(alpha, 1.0, "alpha")
    }

    func testColorFromMap() {
        let map = [
            RGBAType.red.rawValue:0.333,
            RGBAType.green.rawValue:0.666,
            RGBAType.blue.rawValue:0.9,
            RGBAType.alpha.rawValue:0.5
        ]
        
        guard let color = jnparser.colorFromMap( map ) else {
            XCTFail("should convert map to color")
            return
        }
        
        print( color )
        
    }

    func testCGRectToMap() {
        var cgrect = CGRect()

        cgrect.origin.x = CGFloat( 100 )
        cgrect.origin.y = CGFloat( 150 )
        cgrect.size.width = CGFloat( 500 )
        cgrect.size.height = CGFloat( 400 )

        let rect = JNRect( rect:cgrect )

        let map = rect.toMap()

        XCTAssertNotNil(map, "should not be nil")
        guard let x = map[ "x" ],
                let y = map[ "y" ],
                let width = map[ "width" ],
                let height = map[ "height" ] else {

            return XCTFail("should have x/y/width/height")
        }

        XCTAssertEqual(CGFloat( x ), cgrect.origin.x, "x")
        XCTAssertEqual(CGFloat( y ), cgrect.origin.y, "y")
        XCTAssertEqual(CGFloat( width ), cgrect.width, "w")
        XCTAssertEqual(CGFloat( height ), cgrect.height, "h")
    }

    func testCGRectFromMap() {
        let map = [
            "x":-11.33,
            "y":4.22,
            "width":25.44,
            "height":4423.33
        ]

        guard let rect = jnparser.rectFromMap( map ) else {
            return XCTFail("could not create rect from map: \( map )")
        }

        XCTAssertEqual(rect.origin.x, CGFloat( -11.33 ), "x")
    }
    
}
