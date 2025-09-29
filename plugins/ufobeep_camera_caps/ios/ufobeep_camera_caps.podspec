Pod::Spec.new do |s|
  s.name             = 'ufobeep_camera_caps'
  s.version          = '0.1.0'
  s.summary          = 'Camera capabilities plugin for UFOBeep'
  s.description      = 'Exposes device camera zoom capabilities for dynamic UI'
  s.homepage         = 'https://ufobeep.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'UFOBeep' => 'dev@ufobeep.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end