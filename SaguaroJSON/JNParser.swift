//
//  JNParser.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/4/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import Foundation

public typealias UnixTimestamp = Int

struct JNDateFormatter {
    private let formatter:NSDateFormatter
    
    func dateFromString(dateString:String) -> NSDate? {
        guard let date = formatter.dateFromString( dateString ) as NSDate! else {
            return nil
        }
        
        return date
    }
    
    func stringFromDate(date:NSDate) -> String {
        return formatter.stringFromDate( date )
    }
    
    init() {
        formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
    }
}

public class JNParser {
    private let formatter:JNDateFormatter
    
    public func createUnixTimeStamp() -> UnixTimestamp {
        return UnixTimestamp( NSDate().timeIntervalSince1970 * 1000 )
    }
    
    final public func dateFromString(dateString: String) -> NSDate? {
        return formatter.dateFromString( dateString )
    }
    
    final public func stringFromDate(date:NSDate) -> String {
        return formatter.stringFromDate(date)
    }
    
    final public func prepareObjectMap(map:[String:AnyObject]) -> [String:AnyObject] {
        var obj = [String:AnyObject]()
        
        // walk the object to convert all dates to strings: won't handle an array of dates, but that's unlikely...
        for (key, value) in map {
            switch value {
            case let date as NSDate:
                obj[ key ] = stringFromDate( date )
            case let objMap as [String:AnyObject]:
                obj[ key ] = self.prepareObjectMap( objMap )
            default:
                obj[ key ] = value
            }
        }
        
        return obj
    }
    
    final public func stringify(map:[String:AnyObject], pretty:Bool? = true) -> String? {
        let obj = prepareObjectMap( map )
        
        if (!NSJSONSerialization.isValidJSONObject(obj)) {
            logerror("\( __FUNCTION__ ): serialization validation error for object: \( obj )")
            assert(false, "serialization error")
            return nil
        }
        
        do {
            let options = NSJSONWritingOptions.PrettyPrinted
            let data = try NSJSONSerialization.dataWithJSONObject(obj, options: options)
            
            if let json = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return json as String
            }
            
        } catch {
            logerror( "\( __FUNCTION__ ): stringify could not serialize data with json object: \( obj )")
            assert(false, "serialization error")
        }
        
        return nil
    }
    
    final public func parse(jsonString: String) -> [String:AnyObject]? {
        
        // TODO: implement me
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) else {
            logerror("\( __FUNCTION__ ): parse error in json string: \( jsonString )")
            return nil
        }
        
        do {
            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers )
            
            return (obj as! [String : AnyObject])
        } catch {
            logerror("\( __FUNCTION__ ): parse failed on json string: \( jsonString )")
            return nil
        }
    }
    
    func logerror(msg:String) {
        NSLog("ERROR \( __FILE__)::\( msg )")
    }
    
    public init() {
        formatter = JNDateFormatter()
    }
    
}
