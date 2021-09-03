#
# Be sure to run `pod lib lint UAWalkthrough.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UAWalkthrough'
  s.version          = '2.1.5'
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
  s.author           = { 'marhas' => 'marcel@hasselaar.nu' }
  s.source           = { :git => 'https://github.com/marhas/UAWalkthrough.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mhasselaar'
  s.swift_version = "4.2"

  s.ios.deployment_target = '9.0'

  s.source_files = 'UAWalkthrough/Classes/**/*'
end
