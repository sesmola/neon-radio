# Android kurulumu

`flutter create --platforms=android,ios .` ile klasörleri oluşturduktan sonra:

## 1) android/app/build.gradle  (minSdk)
```gradle
defaultConfig { minSdkVersion 23 }
```

## 2) android/app/src/main/AndroidManifest.xml
`<manifest>` içine:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
`<application>` etiketine (HTTP radyo akışları için): `android:usesCleartextTraffic="true"`

`<activity>` sınıfını değiştirin:
```xml
<activity android:name="com.ryanheise.audioservice.AudioServiceActivity" ... >
```
`<application>` içine servis + receiver:
```xml
<service android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true" tools:ignore="Instantiatable">
  <intent-filter><action android:name="android.media.browse.MediaBrowserService"/></intent-filter>
</service>
<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true" tools:ignore="Instantiatable">
  <intent-filter><action android:name="android.intent.action.MEDIA_BUTTON"/></intent-filter>
</receiver>
```
(`<manifest>` etiketine `xmlns:tools="http://schemas.android.com/tools"` ekleyin.)
