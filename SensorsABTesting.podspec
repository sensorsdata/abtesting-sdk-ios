Pod::Spec.new do |s|
  s.name         = 'SensorsABTesting'
  s.version      = "1.1.0"
  s.summary      = 'The official iOS/macOS SDK of Sensors A/B Testing.'
  s.homepage     = 'http://www.sensorsdata.cn'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/sensorsdata/abtesting-sdk-ios.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Sensors Data'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.13'
  s.module_name  = "SensorsABTest"
  s.requires_arc = true
  s.ios.framework = 'UIKit', 'Foundation'

  # 限制 CocoaPods 版本
  s.cocoapods_version = '>= 1.12.0'

#  依赖 SA 最低版本
  s.dependency 'SensorsAnalyticsSDK', '>=4.5.6'

  s.source_files = 'SensorsABTest/**/*.{h,m}'
  s.public_header_files = 'SensorsABTest/include/*.h'
  s.resource_bundle = { 'SensorsABTesting' => 'SensorsABTest/Resources/**/*'}


end
