Pod::Spec.new do |s|
  s.name         = 'CMDHue'
  s.version      = '0.1.0'
  s.summary      = 'Objective-C SDK for working with Hue lights.'
  s.homepage     = 'https://github.com/calebd/hue-sdk-objc'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Caleb Davenport' => 'calebmdavenport@gmail.com' }
  s.source       = { :git => 'https://github.com/calebd/hue-sdk-objc.git', :tag => "v#{s.version}" }

  s.source_files = 'CMDHue/**/*.{h,m}'
  s.requires_arc = true
  
  s.dependency 'ReactiveCocoa'
  
  s.platform = :ios, '6.0'
end