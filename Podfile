platform :ios, '9.0'

workspace 'Corduroy'

target 'CorduroyExample' do
   use_frameworks!
   project 'CorduroyExample/CorduroyExample'

   pod 'Corduroy', :path => '.'
end

target 'Tests' do
   use_frameworks!
   project 'CorduroyTests/CorduroyTests'

   pod 'Corduroy', :path => '.'
   pod 'Nimble', '~> 8'
end
