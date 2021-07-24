Pod::Spec.new do |s|
  s.name         = 'SensorsABTesting'
  s.version      = "0.0.5"
  s.summary      = 'The official iOS SDK of Sensors A/B Testing.'
  s.homepage     = 'http://www.sensorsdata.cn'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/sensorsdata/abtesting-sdk-ios.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Sensors Data'
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.module_name  = "SensorsABTest"
  s.requires_arc = true
  s.cocoapods_version = '>= 1.5.0'
  s.ios.framework = 'UIKit', 'Foundation'
  s.dependency 'SensorsAnalyticsSDK', '>=2.6.3'

  s.source_files = 'SensorsABTest/**/*.{h,m}'
  s.public_header_files = 'SensorsABTest/**/SensorsABTestConfigOptions.h', 'SensorsABTest/**/SensorsABTest.h'

end
