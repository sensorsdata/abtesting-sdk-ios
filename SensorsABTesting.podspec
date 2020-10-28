Pod::Spec.new do |s|
  s.name         = 'SensorsABTesting'
  s.version      = "0.0.1"
  s.summary      = 'The official iOS SDK of Sensors A/B Testing.'
  s.homepage     = 'http://www.sensorsdata.cn'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.source       = { :git => 'https://github.com/sensorsdata/abtesting-sdk-ios.git', :tag => 'v' + s.version.to_s}
  s.author       = 'Sensors Data'
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.module_name  = "SensorsABTest"
  s.requires_arc = true
  s.static_framework = true
  s.cocoapods_version = '>= 1.5.0'
  s.ios.framework = 'UIKit', 'Foundation'
  s.dependency 'SensorsAnalyticsSDK', '>=2.1.14'
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  base_path = 'SensorsABTest/'
  s.vendored_frameworks = base_path + 'SensorsABTest.framework'

end
