#
# Be sure to run `pod lib lint UAWalkthrough.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UAWalkthrough'
  s.version          = '0.1.0'
  s.summary          = 'Create an onboarding experience for your app by highlighting and annotating its different elements.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Quickly onboard users to your app by highlighting important UI elements and create text bubbles with appropriate descriptions. Super easy to implement in your own project.
                       DESC

  s.homepage         = 'https://github.com/marhas/UAWalkthrough'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'marhas' => 'marcel@unbadapps.com' }
  s.source           = { :git => 'https://github.com/marhas/UAWalkthrough.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mhasselaar'

  s.ios.deployment_target = '9.0'

  s.source_files = 'UAWalkthrough/Classes/**/*'
  
  # s.resource_bundles = {
  #   'UAWalkthrough' => ['UAWalkthrough/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
