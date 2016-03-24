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
        XCTAssert(jstr.characters.count >= 800, "should match the character count")

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
        XCTAssert(jstr.characters.count >= 500, "should match the character count")

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
            return XCTFail("should create a date string")
        }

        guard let ds:String = jnparser.stringFromDate( date ) else {
            return XCTFail("should create a date string")
        }

        guard let dt = jnparser.dateFromString( ds ) else {
            return XCTFail("should create a date from json string")
        }

        print("ds: \( ds ) dt: \( dt )")

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
    
    func testPaserNonStandardDateFromString() {
        let ds1 = "2015-02-12T23:15:45.944+0000"
        
        guard let dt = jnparser.dateFromString( ds1 ) else {
            return XCTFail("could not parse date from \( ds1 )")
        }
        
        print("ds: \( ds1 ) dt: \( dt )")
    }

    func testParseBadDateFromJSONString() {
        let ds = "2015/06/18 00:47:49"

        let dt = jnparser.dateFromString(ds)

        XCTAssertNil(dt, "should not be nil")
    }

    func testColorToMap() {
        var count = 9
        while (count > 0) {
            let n = Double( count )
            let r = CGFloat( 0.111 + (n / 15) )
            let g = CGFloat( 0.999 - (n / 14) )
            let b = CGFloat( 0.9 - (n / 10) )
            let a = CGFloat( 0.25 + (n / 50) )

            let color = UIColor(red: r, green: g, blue: b, alpha: a)
            let map = jnparser.colorToMap( color )

            print( map )

            XCTAssertNotNil(map, "should not be nil")

            guard let red = map[ RGBAType.red.rawValue ],
                    let green = map[ RGBAType.green.rawValue ],
                    let blue = map[ RGBAType.blue.rawValue ],
                    let alpha = map[ RGBAType.alpha.rawValue ] else {
                return XCTFail("should have a red color")
            }

            XCTAssertEqual(CGFloat( red ), r, "red")
            XCTAssertEqual(CGFloat( green ), g, "green")
            XCTAssertEqual(CGFloat( blue ), b, "blue")
            XCTAssertEqual(CGFloat( alpha ), a, "alpha")

            count -= 1;
        }
    }

    func testColorFromMap() {

        var count = 9
        while (count > 0) {
            let n = Double( count )
            let red = 0.111 + (n / 19)
            let green = 0.999 - (n / 13)
            let blue = 0.9 - (n / 100)
            let alpha = 0.25 + (n / 38)

            let map = [
                RGBAType.red.rawValue: red,
                RGBAType.green.rawValue: green,
                RGBAType.blue.rawValue: blue,
                RGBAType.alpha.rawValue: alpha
            ]
            
            guard let color = jnparser.colorFromMap( map ) else {
                XCTFail("should convert map to color")
                return
            }
            
            print( color )
            var r:CGFloat = 0.0
            var g:CGFloat = 0.0
            var b:CGFloat = 0.0
            var a:CGFloat = 0.0

            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            XCTAssertEqual(r, CGFloat( red ), "red")
            XCTAssertEqual(g, CGFloat( green ), "green")
            XCTAssertEqual(b, CGFloat( blue ), "blue")
            XCTAssertEqual(a, CGFloat( alpha ), "alpha")

            count -= 1;
        }

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
