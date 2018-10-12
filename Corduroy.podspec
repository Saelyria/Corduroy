Pod::Spec.new do |s|
  s.name             = 'Corduroy'
  s.version          = '0.1.0'
  s.summary          = 'Advanced navigation framework for iOS.'
  s.description      = <<-DESC
  Corduroy is an advanced navigation framework that makes your navigation logic more type-safe, more
  self-documenting, and simply more powerful, adding features like URL-based routing, navigation
  preconditions, and more.
  DESC

  s.homepage         = 'https://github.com/Saelyria/Corduroy'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aaron Bosnjak' => 'aaron.bosnjak707@gmail.com' }
  s.source           = { :git => 'https://github.com/Saelyria/Corduroy.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = 'Core/'
    ss.ios.framework = "UIKit"
  end
end
