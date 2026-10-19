import re, pathlib

m = pathlib.Path('android/app/src/main/AndroidManifest.xml')
s = m.read_text()

perms = """<uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
"""
s = s.replace('<application', perms + '    <application', 1)
s = s.replace('<application', '<application android:usesCleartextTraffic="true"', 1)
s = s.replace('android:name=".MainActivity"',
              'android:name="com.ryanheise.audioservice.AudioServiceActivity"')

svc = """
        <service android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService"/>
            </intent-filter>
        </service>
        <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON"/>
            </intent-filter>
        </receiver>
    """
s = s.replace('</application>', svc + '</application>', 1)
m.write_text(s)

for f in ['android/app/build.gradle.kts', 'android/app/build.gradle']:
    p = pathlib.Path(f)
    if p.exists():
        t = p.read_text()
        new = 'minSdk = 23' if f.endswith('.kts') else 'minSdkVersion 23'
        t = re.sub(r'minSdk(Version)?\s*=?\s*flutter\.minSdkVersion', new, t)
        p.write_text(t)
print('Android ayarlari tamam')
