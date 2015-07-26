# Saguaro JSON 

_JSON parse and stringify for iOS/OSX/Swift 2.0 applications_

<a href="https://developer.apple.com/swift/"><img src="http://raincitysoftware.com/swift2-badge.png" alt="" width="65" height="20" border="0" /></a>
[![Build Status](https://travis-ci.org/darrylwest/saguaro-json.svg?branch=master)](https://travis-ci.org/darrylwest/saguaro-json)

## Installation

* cocoapods (unpublished, so pull from repo)
* git subproject/framework (from repo)

## How to use

### The simplest uses case:

let jsonString = ... // some json string
let map = JSON.parse( jsonString ) // returns [String:AnyObject]?

...

let map = someObject.toMap() // [String:AnyObject]
let jsonString = JSON.stringify( map )

_See the unit tests and test fixtures for more examples..._

## License: MIT

Use as you wish.  Please fork and help out if you can.

- - -
darryl.west@raincitysoftware.com | Version 00.90.13
