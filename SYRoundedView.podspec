Pod::Spec.new do |s|
  s.name     = 'SYRoundedView'
  s.version  = '1.0.2'
  s.license  = 'Custom'
  s.summary  = 'A simple way to have rounded corners in your views'
  s.homepage = 'https://github.com/dvkch/SYRoundedView'
  s.author   = { 'Stan Chevallier' => 'contact@stanislaschevallier.fr' }
  s.source   = { :git => 'https://github.com/dvkch/SYRoundedView.git', :tag => s.version.to_s }
  s.source_files = 'SYRoundedView/SYRoundedView.{h,m}'
  s.requires_arc = true

  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  s.ios.deployment_target = '5.0'
end
