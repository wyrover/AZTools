Pod::Spec.new do |s|
  s.name         = "AZTools"
  s.version      = "0.0.4"
  s.summary      = "AZTools"
  s.description  = "AZTools is a collection of my usually use helpers"
  s.homepage     = "https://github.com/gbammc/AZTools"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "gbammc" => "gbammc@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target = '5.0'
  s.source       = { :git => "https://github.com/gbammc/AZTools.git", :tag => "0.0.4" }
  s.source_files = 'UIColor+Helper', 'UIView+Helper', 'UIImage+Helper', 'AZNavigationController'
  s.resource     = 'Resource/*' 
  s.framework  = 'CoreGraphics', 'QuartzCore'
  s.requires_arc = true
end
