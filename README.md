# 🎧 Neon Radyo (Flutter)

Koyu/neon temalı, 7/24 canlı radyo dinleme ve kendi yayınını verebileceğin **DJ modu** olan cross-platform (iOS + Android) uygulama.

## Neden Flutter?
Arka plan sesi için olgun ve kararlı `just_audio` + `audio_service` ikilisi, WebRTC için `flutter_webrtc` ve tek kod tabanında akıcı (60/120 fps) animasyon sunar.

## Özellikler
- Neon/gradient giriş ekranı (doğrulama simülasyonu, oturum hatırlama)
- "Hoş Geldiniz, [İsim]" (e-postadan otomatik isim üretir)
- Canlı yayın, ICY metadata ile **çalan şarkı / sanatçı**, ses dalgası animasyonu
- Arka planda ve kilit ekranında çalma, bildirimden Play/Pause
- Ses kontrolü, Play/Pause, favoriler (kalıcı), uyku zamanlayıcısı, son çalınanlar
- DJ / Yayıncı paneli: mikrofon → WebRTC (WHIP) → sunucu → Icecast; canlı göstergesi, süre, sessize alma, otomatik yeniden bağlanma

## Proje yapısı
```
lib/
├── main.dart                     # Başlangıç, Provider'lar, AudioService.init
├── theme/app_theme.dart          # Renkler + koyu tema
├── models/station.dart           # Station, TrackInfo, varsayılan istasyonlar
├── services/
│   ├── audio_handler.dart        # Arka plan ses (audio_service + just_audio)
│   ├── radio_provider.dart       # Durum: istasyon, favori, geçmiş, uyku, ses
│   ├── auth_service.dart         # Giriş simülasyonu + isim üretimi
│   └── broadcast_service.dart    # DJ modu: mikrofon -> WHIP (WebRTC)
├── screens/                      # login, main_shell, home, favorites, history, dj
└── components/                   # wave_animation, now_playing_card, station_tile, ...
server/                           # docker-compose + mediamtx.yml (DJ altyapısı)
platform_setup/                   # ANDROID.md, IOS.md
assets/images/                    # (logo/ikon için ayrılmış)
```

## Kurulum
```bash
flutter create --platforms=android,ios --org com.example .   # android/ ios/ klasörlerini üretir
flutter pub get
# platform_setup/ANDROID.md ve IOS.md adımlarını uygula
flutter run
```
> `flutter create .` mevcut `lib/` ve `pubspec.yaml` dosyalarının üzerine yazmaz.

## DJ modu mimarisi
```
Telefon mikrofon --WebRTC/WHIP--> MediaMTX --FFmpeg(MP3)--> Icecast --> dinleyiciler (7/24)
```
1. VPS'e `server/` klasörünü kopyala, şifreleri değiştir, `docker compose up -d`.
2. UDP 8189, TCP 8889 ve 8000 portlarını aç.
3. Uygulamada DJ sekmesine `http://SUNUCU_IP:8889/live/whip` yaz, **Yayını Başlat**.
4. `lib/models/station.dart` içindeki "Benim Yayınım" URL'sini `http://SUNUCU_IP:8000/live` yap.

**Önemli notlar**
- Telefon kapalı/uykudayken "7/24" yayın için sürekli açık bir kaynak gerekir: Gerçekten kesintisiz yayın için sunucuya bir **AutoDJ** (örn. Liquidsoap) kurup DJ'i canlı olmadığında müzik çalacak şekilde yedek kaynak yapmanı öneririm.
- Üretimde MediaMTX'te yayın yetkisini (kullanıcı/şifre/token) mutlaka aktif et, yoksa herkes yayın yapabilir.
- iOS arka plan mikrofon yayını Apple kısıtlarına tabidir; en güvenilir kullanım ekran açıkken (wakelock aktif).
- Gerçek giriş için `AuthService.login` içine kendi API çağrını ekle.
- Yayın yaptığın içeriğin telif/lisans sorumluluğu sana aittir.
