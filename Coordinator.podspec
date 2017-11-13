Pod::Spec.new do |s|
  s.name             = 'Coordinator'
  s.version          = '0.1.0'
  s.summary          = 'Simple framework adding navigation coordinators to iOS.'
  s.description      = <<-DESC
  Coordinator is a series of protocols and extensions that, when implemented, encapsulate
  all navigation logic in 'coordinator' objects that keep view controllers smaller, more
  reusable, and more uniform in terms of dependency declaration and navigation.
  DESC

  s.homepage         = 'https://github.com/Saelyria/Coordinator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aaron Bosnjak' => 'aaron.bosnjak707@gmail.com' }
  s.source           = { :git => 'https://github.com/Saelyria/Coordinator.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = 'Source/Coordinator/**/*'
    ss.ios.framework  = "UIKit"
  end

  s.subspec "RxSwift" do |ss|
    ss.source_files = "Source/RxCoordinator/"
    ss.dependency "Coordinator/Core"
    ss.dependency "RxSwift", "~> 4.0"
  end
end
