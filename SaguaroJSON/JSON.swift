//
//  JSON.swift
//  SaguaroJSON
//
//  Created by darryl west on 7/26/15.
//  Copyright © 2015 darryl west. All rights reserved.
//

import Foundation

public struct JSON {
    public static let DateFormatString = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    public static let jnparser = JNParser()

    public static func stringify(map:[String:AnyObject], pretty:Bool? = false) -> String? {
        return jnparser.stringify( map, pretty: pretty! )
    }

    public static func parse(jsonString:String) -> [String:AnyObject]? {
        return jnparser.parse( jsonString )
    }
}