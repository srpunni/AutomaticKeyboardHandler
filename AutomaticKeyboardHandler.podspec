Pod::Spec.new do |s|
s.name             = 'AutomaticKeyboardHandler'
s.version          = '1.0.7'
s.summary          = 'By far the most fantastic view I have seen in my entire life. No joke.'

s.description      = <<-DESC
This fantastic view changes its color gradually makes your app look fantastic!
DESC

s.homepage         = 'https://github.com/srpunni/AutomaticKeyboardHandler'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Sukhpal Singh' => 'srpunni@gmail.com' }
s.source           = { :git => 'https://github.com/srpunni/AutomaticKeyboardHandler.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'
s.source_files = 'AutomaticKeyboardHandler/**/*.swift'
s.resources = "AutomaticKeyboardHandler/**/*.{png,jpeg,jpg,storyboard,xib}"

end

