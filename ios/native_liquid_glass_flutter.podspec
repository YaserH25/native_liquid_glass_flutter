#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_liquid_glass_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_liquid_glass_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Native iOS Liquid Glass surfaces and adaptive Flutter fallbacks.'
  s.description      = <<-DESC
Native iOS Liquid Glass surfaces, UIKit system overlays, and adaptive Flutter fallbacks.
                       DESC
  s.homepage         = 'https://github.com/YaserH25/native_liquid_glass_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Yaser Hesham' => 'https://github.com/YaserH25' }
  s.source           = { :path => '.' }
  s.source_files = 'native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'

  s.resource_bundles = {
    'native_liquid_glass_flutter_privacy' => [
      'native_liquid_glass_flutter/Sources/native_liquid_glass_flutter/PrivacyInfo.xcprivacy'
    ]
  }
end
