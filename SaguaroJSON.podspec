Pod::Spec.new do |s|
  s.name        = "SaguaroJSON"
  s.version     = "0.95.0"
  s.summary     = "JSON parser for iOS/OSX applications written in Swift 3.0"
  s.homepage    = "https://github.com/darrylwest/saguaro-json"
  s.license     = { :type => "MIT" }
  s.authors     = { "darryl.west" => "darryl.west@raincitysoftware.com" }
  s.osx.deployment_target = "10.10"
  s.ios.deployment_target = "9.0"
  s.source      = { :git => "https://github.com/darrylwest/saguaro-json.git", :tag => s.version }
  s.source_files = "SaguaroJSON/*.swift"
end
