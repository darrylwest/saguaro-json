//
//  JNParser.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/4/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import Foundation

public typealias UnixTimestamp = Int

public protocol JSONDateType {
    func dateFromString(dateString: String) -> NSDate?
    func stringFromDate(date:NSDate) -> String
    func createUnixTimestamp() -> UnixTimestamp
}

public protocol JSONParserType {
    func parseDate(obj:AnyObject?) -> NSDate?
    func stringify(map:[String:AnyObject]) -> String?
    func parse(jsonString: String) -> [String:AnyObject]?
}

public struct JNDateFormatter: JSONDateType {
    private let formatter:NSDateFormatter

    public func dateFromString(dateString:String) -> NSDate? {
        guard let date = formatter.dateFromString( dateString ) as NSDate! else {
            return nil
        }

        return date
    }

    public func stringFromDate(date:NSDate) -> String {
        return formatter.stringFromDate( date )
    }

    public func createUnixTimestamp() -> UnixTimestamp {
        return Int( NSDate().timeIntervalSince1970 * 1000 )
    }

    init() {
        formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    }
}

public enum RGBAType: String {
    case red, blue, green, alpha
}

/// JNParser - this is the primary json parse interface.  It's primary fuctions are to serialize (stringify) objects to json
/// strings or to prase strings to return a object graph
public struct JNParser: JSONParserType, JSONDateType {

    public let formatter:JNDateFormatter

    public init() {
        formatter = JNDateFormatter()
    }

    public func parseDate(obj:AnyObject?) -> NSDate? {
        switch obj {
        case is NSDate:
            return obj as? NSDate
        case is String:
            return formatter.dateFromString( obj as! String )
        default:
            return nil
        }
    }

    public func dateFromString(dateString: String) -> NSDate? {
        return formatter.dateFromString( dateString )
    }

    public func stringFromDate(date:NSDate) -> String {
        return formatter.stringFromDate(date)
    }

    public func prepareObjectArray(list:[AnyObject]) -> [AnyObject] {
        var array = [AnyObject]()

        for value in list {

            switch value {
            case let date as NSDate:
                array.append( stringFromDate( date ) )
            case let objMap as [String:AnyObject]:
                array.append( self.prepareObjectMap( objMap ))
            case let objArray as [AnyObject]:
                array.append( self.prepareObjectArray( objArray ))
            default:
                array.append( value )
            }
        }

        return array
    }

    /// convert a UIColor to rbga map
    public func colorToMap(color:UIColor) -> [String:Double] {
        var r:CGFloat = 0.0
        var g:CGFloat = 0.0
        var b:CGFloat = 0.0
        var a:CGFloat = 0.0

        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        let map = [
            RGBAType.red.rawValue:Double(r),
            RGBAType.green.rawValue:Double(g),
            RGBAType.blue.rawValue:Double(b),
            RGBAType.alpha.rawValue:Double(a)
        ]

        return map
    }

    /// convert a map to UIColor object or return nil
    public func colorFromMap(colorNode:[String:AnyObject]) -> UIColor? {
        guard let r = colorNode[ RGBAType.red.rawValue ] as? CGFloat,
            let g = colorNode[ RGBAType.green.rawValue ] as? CGFloat,
            let b = colorNode[ RGBAType.blue.rawValue ] as? CGFloat,
            let a = colorNode[ RGBAType.alpha.rawValue ] as? CGFloat else {

                return nil
        }

        return UIColor(red:r, green:g, blue:b, alpha:a)
    }

    /// prepare the map by converting NSDate and UIColor
    public func prepareObjectMap(map:[String:AnyObject]) -> [String:AnyObject] {
        var obj = [String:AnyObject]()

        // walk the object to convert all dates to strings: won't handle an array of dates, but that's unlikely...
        for (key, value) in map {
            switch value {
            case let color as UIColor:
                obj[ key ] = colorToMap( color )
            case let date as NSDate:
                obj[ key ] = stringFromDate( date )
            case let objMap as [String:AnyObject]:
                obj[ key ] = self.prepareObjectMap( objMap )
            case let objArray as [AnyObject]:
                obj[ key ] = self.prepareObjectArray( objArray )
            default:
                obj[ key ] = value
            }
        }

        return obj
    }

    /// return the unix timestamp
    public func createUnixTimestamp() -> UnixTimestamp {
        return formatter.createUnixTimestamp()
    }

    /// given a map<string:anyobject> convert to a json string
    public func stringify(map: [String : AnyObject]) -> String? {
        return self.stringify(map, pretty: false)
    }

    /// given a map<string:anyobject> convert to a json string
    public func stringify(map:[String:AnyObject], pretty:Bool? = false) -> String? {
        let obj = prepareObjectMap( map )

        if (!NSJSONSerialization.isValidJSONObject(obj)) {
            NSLog("\( __FUNCTION__ ): serialization validation error for object: \( obj )")
            assert(false, "serialization error")
            return nil
        }

        do {
            // this mess is to get around the 2.0 way of handling options
            let data:NSData

            if pretty! {
                data = try NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.PrettyPrinted)
            } else {
                data = try NSJSONSerialization.dataWithJSONObject(obj, options: [])
            }

            if let json = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return json as String
            }

        } catch {
            NSLog( "\( __FUNCTION__ ): stringify could not serialize data with json object: \( obj )")
            assert(false, "serialization error")
        }

        return nil
    }

    /// parse the string and return map or nil
    public func parse(jsonString: String) -> [String:AnyObject]? {
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) else {
            NSLog("\( __FUNCTION__ ): parse error in json string: \( jsonString )")
            return nil
        }

        do {
            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers )

            return (obj as! [String : AnyObject])
        } catch {
            NSLog("\( __FUNCTION__ ): parse failed on json string: \( jsonString )")
            return nil
        }
    }
}

/// JSONResponseWrapper - parse and generate the standard wrapper used to exchange JSON data
public struct JSONResponseWrapper: CustomStringConvertible {
    public let status:String
    public let ts:Int
    public let version:String
    public private(set) var reason:String = ""
    public let isOk:Bool

    public init?(jsonObject: [String:AnyObject]) {
        guard let status = jsonObject[ "status" ] as? String,
            let version = jsonObject[ "version" ] as? String,
            let ts = jsonObject[ "ts" ] as? Int else { return nil }

        self.status = status
        self.version = version
        self.ts = ts

        if status != JSONResponseWrapper.Ok {
            isOk = false
            if let reason = jsonObject[ "reason" ] as? String {
                self.reason = reason
            }
        } else {
            isOk = true
        }
    }

    public var description:String {
        let text = "status:\( status ), ts:\( ts ), version:\( version )"

        if status != JSONResponseWrapper.Ok {
            return text + ", reason:\( reason )"
        } else {
            return text
        }
    }

    static public func createWrapper(key key:String, value:AnyObject) -> [String:AnyObject] {
        let formatter = JNParser().formatter
        let wrapper:[String:AnyObject] = [
            "status":JSONResponseWrapper.Ok,
            "ts":formatter.createUnixTimestamp(),
            "version":"1.0",
            key:value
        ]
        
        return wrapper
    }
    
    static public let Ok = "ok"
    static public let Failed = "failed"
}
