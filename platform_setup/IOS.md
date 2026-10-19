# iOS kurulumu

ios/Runner/Info.plist içine:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
  <string>voip</string>   <!-- DJ modunda ekran kilitliyken mikrofon yayını için -->
</array>
<key>NSMicrophoneUsageDescription</key>
<string>Canlı yayın yapabilmek için mikrofona erişim gerekir.</string>
<key>NSAppTransportSecurity</key>
<dict><key>NSAllowsArbitraryLoads</key><true/></dict>
```
Podfile: `platform :ios, '13.0'`
