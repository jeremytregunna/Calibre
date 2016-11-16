Pod::Spec.new do |s|
  s.osx.deployment_target     = '10.12'
  s.ios.deployment_target     = '10.0'
  s.tvos.deployment_target    = '10.0'
  s.watchos.deployment_target = '3.0'
  s.name                      = 'Calibre'
  s.version                   = '3.0.0'
  s.license                   = { :type => 'MIT', :file => 'LICENSE' }
  s.summary                   = 'Reactive programming library inspired by Redux'
  s.homepage                  = 'https://github.com/Greenshire/Calibre'
  s.authors                   = { 'Jeremy Tregunna' => 'jeremy@tregunna.ca' }
  s.source                    = { :git => 'https://github.com/Greenshire/Calibre.git', :tag => '2.0.0' }
  s.requires_arc              = true
  s.source_files              = "Calibre/**/*.swift"
  s.resources                 = "Calibre/**/*.plist"
end
