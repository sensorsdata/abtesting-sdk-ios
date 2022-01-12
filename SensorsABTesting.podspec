Pod::Spec.new do |s|
  s.name         = 'SensorsABTesting'
  s.version      = "0.2.0"
  s.summary      = 'The official iOS/macOS SDK of Sensors A/B Testing.'
  s.homepage     = 'http://www.sensorsdata.cn'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/sensorsdata/abtesting-sdk-ios.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Sensors Data'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.module_name  = "SensorsABTest"
  s.requires_arc = true
  s.cocoapods_version = '>= 1.5.0'
  s.ios.framework = 'UIKit', 'Foundation'

#  依赖 SA 最低版本
  s.dependency 'SensorsAnalyticsSDK', '>=4.2.0'

  s.source_files = 'SensorsABTest/**/*.{h,m}'
  s.public_header_files = 'SensorsABTest/**/SensorsABTestConfigOptions.h', 'SensorsABTest/**/SensorsABTest.h', 'SensorsABTest/**/SensorsABTestExperiment.h'

end
