//
//  JSONResponseWrapper.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/26/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import Foundation

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
