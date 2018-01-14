Pod::Spec.new do |s|
  s.name             = 'Corduroy'
  s.version          = '0.1.0'
  s.summary          = 'Advanced navigation framework for iOS.'
  s.description      = <<-DESC
  Coordinator is a series of protocols and clases that, when implemented, encapsulate
  all navigation logic in 'coordinator' objects that keep view controllers smaller, more
  reusable, and more uniform in terms of dependency declaration and navigation. It also
  adds advanced navigation features like preconditions and type-safe dependency injection.
  DESC

  s.homepage         = 'https://github.com/Saelyria/Corduroy'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aaron Bosnjak' => 'aaron.bosnjak707@gmail.com' }
  s.source           = { :git => 'https://github.com/Saelyria/Corduroy.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = 'Source/Core/'
    ss.ios.framework  = "UIKit"
  end

  s.subspec "RxSwift" do |ss|
    ss.source_files = "Source/RxCorduroy/"
    ss.dependency "Corduroy/Core"
    ss.dependency "RxSwift", "~> 4.0"
  end
end
