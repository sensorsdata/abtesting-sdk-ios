# Uncomment the next line to define a global platform for your project

workspace 'SensorsABTest'
project './Example/Example.xcodeproj'

target 'Example-iOS' do
  platform :ios, '9.0'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  #  pod 'SensorsAnalyticsSDK'
#  pod 'SensorsABTesting'

  pod 'SensorsABTesting', :path => './'
  pod 'SensorsAnalyticsSDK', '>= 4.5.6'

end


target 'Example-macOS' do
  platform :osx, '10.13'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  #  pod 'SensorsABTesting'

#  pod 'SensorsABTesting', :path => './'
#  pod 'SensorsAnalyticsSDK', '>= 4.5.6'

end
