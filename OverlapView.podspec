Pod::Spec.new do |s|
  s.name             = 'OverlapView'
  s.version          = '1.0.1'
  s.summary          = 'Library for creating overlapping views'
  s.description      = 'You can create a view that can be displayed in a new window (over the old one) or in another view. You can customize the transition animation, create descendant classes.'
  s.homepage         = 'https://github.com/DPLibs/OverlapView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dmitriy Polyakov' => 'dmitriyap11@gmail.com' }
  s.source           = { :git => 'https://github.com/DPLibs/OverlapView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'OverlapView/Classes/**/*'
  s.swift_version = '4.2'
end
