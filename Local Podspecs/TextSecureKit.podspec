Pod::Spec.new do |s|
  s.name                = "TextSecureKit"
  s.version             = "0.1"
  s.summary             = "TextSecureKit is the TextSecure component of Signal on iOS."
  s.homepage            = "https://github.com/WhisperSystems/TextSecureKit"
  s.license             = "GPLv2"
  s.license             = { :type => "GPLv2", :file => "LICENSE" }
  s.author              = { "Frederic Jacobs" => "github@fredericjacobs.com" }
  s.social_media_url    = "http://twitter.com/FredericJacobs"
  s.source              = { :git => "https://github.com/WhisperSystems/TextSecureKit.git", :tag => "#{s.version}" }
  s.source_files        = "TextSecureKit/Classes/*.{h,m}", "TextSecureKit/Classes/**/*.{h,m}"
  s.public_header_files = "TextSecureKit/Classes/*.{h}", "TextSecureKit/Classes/**/*.{h}"
  s.dependency 'AxolotlKit'
  s.dependency 'YapDatabase/SQLCipher'
  s.dependency 'AFNetworking', '~> 2.4'
  s.dependency 'libPhoneNumber-iOS', '~> 0.7.2'
  s.dependency 'SocketRocketMirror'
  s.dependency 'MCSMKeychainItem'
end
