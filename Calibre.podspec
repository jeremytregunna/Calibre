Pod::Spec.new do |s|
  s.ios.deployment_target = '8.1'
  s.name                  = 'Calibre'
  s.version               = '2.0.0'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.summary               = 'Reactive programming library inspired by Redux'
  s.homepage              = 'https://github.com/Greenshire/Calibre'
  s.authors               = { 'Jeremy Tregunna' => 'jeremy@tregunna.ca' }
  s.source                = { :git => 'https://github.com/Greenshire/Calibre.git', :tag => '2.0.0' }
  s.requires_arc          = true
  s.source_files          = "Calibre/**/*.swift"
  s.resources             = "Calibre/**/*.plist"
end
