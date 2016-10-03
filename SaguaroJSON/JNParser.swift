//
//  JNParser.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/4/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import Foundation

public typealias UnixTimestamp = Double

public protocol JSONDateType {
    func dateFromString(_ dateString: String) -> Date?
    func stringFromDate(_ date:Date) -> String
    func createUnixTimestamp() -> UnixTimestamp
}

public protocol JSONParserType {
    func parseDate(_ obj:AnyObject?) -> Date?
    func stringify(_ map:[String:AnyObject]) -> String?
    func parse(_ jsonString: String) -> [String:AnyObject]?
}

public class JNRect {
    let x:Double
    let y:Double
    let width:Double
    let height:Double

    public init(x:Double, y:Double, width:Double, height:Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public init(rect:CGRect) {
        self.x = Double( rect.origin.x )
        self.y = Double( rect.origin.y )
        self.width = Double( rect.width )
        self.height = Double( rect.height )
    }

    public func toCGRect() -> CGRect {
        return CGRect(x: CGFloat( x ), y: CGFloat( y ), width: CGFloat( width ), height: CGFloat( height ))
    }

    /// convert a CGRect to object or return nil
    public func toMap() -> [String:Double] {
        let map = [
            "x":x,
            "y":y,
            "width":width,
            "height":height
        ]

        return map
    }

}

public struct JNDateFormatter: JSONDateType {
    fileprivate let formatter:DateFormatter

    public func dateFromString(_ dateString:String) -> Date? {
        let dts = dateString.replacingOccurrences(of: "+0000", with: "Z")
        
        guard let date = formatter.date( from: dts ) as Date! else {
            return nil
        }

        return date
    }

    public func stringFromDate(_ date:Date) -> String {
        return formatter.string( from: date )
    }

    public func createUnixTimestamp() -> UnixTimestamp {
        return Double( Date().timeIntervalSince1970 * 1000 )
    }

    init() {
        formatter = DateFormatter()
        formatter.dateFormat = JSON.DateFormatString
        formatter.timeZone = TimeZone(abbreviation: "UTC")
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

    public func parseDate(_ obj:AnyObject?) -> Date? {
        switch obj {
        case is Date:
            return obj as? Date
        case is String:
            return formatter.dateFromString( obj as! String )
        default:
            return nil
        }
    }

    public func dateFromString(_ dateString: String) -> Date? {
        return formatter.dateFromString( dateString )
    }

    public func stringFromDate(_ date:Date) -> String {
        return formatter.stringFromDate(date)
    }

    public func prepareObjectArray(_ list:[AnyObject]) -> [AnyObject] {
        var array = [AnyObject]()

        for value in list {

            switch value {
            case let date as Date:
                array.append( stringFromDate( date ) as AnyObject )
            case let objMap as [String:AnyObject]:
                array.append( self.prepareObjectMap( objMap ) as AnyObject)
            case let objArray as [AnyObject]:
                array.append( self.prepareObjectArray( objArray ) as AnyObject)
            default:
                array.append( value )
            }
        }

        return array
    }

    /// convert a UIColor to rbga map
    public func colorToMap(_ color:UIColor) -> [String:Double] {
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
    public func colorFromMap(_ colorNode:[String:AnyObject]) -> UIColor? {
        guard let r = colorNode[ RGBAType.red.rawValue ] as? CGFloat,
            let g = colorNode[ RGBAType.green.rawValue ] as? CGFloat,
            let b = colorNode[ RGBAType.blue.rawValue ] as? CGFloat,
            let a = colorNode[ RGBAType.alpha.rawValue ] as? CGFloat else {

                return nil
        }

        return UIColor(red:r, green:g, blue:b, alpha:a)
    }


    /// convert an object stored as a JNRect to a cgrect
    public func rectFromMap(_ map:[String:AnyObject]) -> CGRect? {
        guard let x = map[ "x" ] as? CGFloat,
            let y = map[ "y" ] as? CGFloat,
            let width = map[ "width" ] as? CGFloat,
            let height = map[ "height" ] as? CGFloat else {

            return nil
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    /// prepare the map by converting NSDate and UIColor
    public func prepareObjectMap(_ map:[String:AnyObject]) -> [String:AnyObject] {
        var obj = [String:AnyObject]()

        // walk the object to convert all dates to strings: won't handle an array of dates, but that's unlikely...
        for (key, value) in map {
            switch value {
            case let color as UIColor:
                obj[ key ] = colorToMap( color ) as AnyObject
            case let date as Date:
                obj[ key ] = stringFromDate( date ) as AnyObject
            case let objMap as [String:AnyObject]:
                obj[ key ] = self.prepareObjectMap( objMap ) as AnyObject
            case let objArray as [AnyObject]:
                obj[ key ] = self.prepareObjectArray( objArray ) as AnyObject
            case let rect as JNRect:
                obj[ key ] = rect.toMap() as AnyObject
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
    public func stringify(_ map: [String : AnyObject]) -> String? {
        return self.stringify(map, pretty: false)
    }

    /// given a map<string:anyobject> convert to a json string
    public func stringify(_ map:[String:AnyObject], pretty:Bool? = false) -> String? {
        let obj = prepareObjectMap( map )

        if (!JSONSerialization.isValidJSONObject(obj)) {
            NSLog("\( #function ): serialization validation error for object: \( obj )")
            assert(false, "serialization error")
            return nil
        }

        do {
            // this mess is to get around the 2.0 way of handling options
            let data:Data

            if pretty! {
                data = try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.prettyPrinted)
            } else {
                data = try JSONSerialization.data(withJSONObject: obj, options: [])
            }

            if let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return json as String
            }

        } catch {
            NSLog( "\( #function ): stringify could not serialize data with json object: \( obj )")
            assert(false, "serialization error")
        }

        return nil
    }

    /// parse the string and return map or nil
    public func parse(_ jsonString: String) -> [String:AnyObject]? {
        guard let data = jsonString.data(using: String.Encoding.utf8) else {
            NSLog("\( #function ): parse error in json string: \( jsonString )")
            return nil
        }

        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers )

            return (obj as! [String : AnyObject])
        } catch {
            NSLog("\( #function ): parse failed on json string: \( jsonString )")
            return nil
        }
    }
}

