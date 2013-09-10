Pod::Spec.new do |s|
  s.name     = 'HPComboxPopover'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'Combox Modal'
  s.author   = { 'Herve Peroteau' => 'herve.peroteau@gmail.com' }
  s.description = 'Combox Modal'
  s.platform = :ios
  s.source = { :git => "https://github.com/herveperoteau/HPComboxPopover.git"}
  s.source_files = 'HPComboxPopover'
  s.requires_arc = true
  s.resources = ["HPComboxPopover/*.png", "HPComboxPopover/*.xib"]
  
end
