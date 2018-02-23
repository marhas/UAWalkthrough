fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios show_podspec_version
```
fastlane ios show_podspec_version
```
Displays the podspec version number.
### ios bump_project_version
```
fastlane ios bump_project_version
```
Bumps the project version number. Defaults to bumping the patch number, use 'type:minor' or 'type:major' to override.
### ios bump_podspec
```
fastlane ios bump_podspec
```
Bumps the podspec version number. Defaults to bumping the patch number, use 'type:minor' or 'type:major' to override.
### ios create_new_version
```
fastlane ios create_new_version
```
Creates a new version of the pod by incrementing the patch, minor or major number of the version number and then commits the changes.
  Defaults to bumping the patch version.
  Use 'type:minor' or 'type:major' to override.
  Use 'version:x.y.z' if you want to set a fixed version number.
  Use 'settings:true' if you want to include the settings bundle (if you have one) in the version bump.
  
### ios push_pod
```
fastlane ios push_pod
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
