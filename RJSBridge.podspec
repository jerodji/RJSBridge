#
# Be sure to run `pod lib lint RJSBridge.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RJSBridge'
  s.version          = '0.1.0'
  s.summary          = 'an bridge to JavaScript, easy to use, simple, without invading.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: An bridge to JavaScript, easy to use, simple, without invading. 
Only one bridge to js, then use OC objc_msgSend to specific method.
                       DESC

  s.homepage         = 'https://github.com/jerodji/RJSBridge.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jerod' => 'jjd510@163.com' }
  s.source           = { :git => 'https://github.com/jerodji/RJSBridge.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RJSBridge/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RJSBridge' => ['RJSBridge/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
