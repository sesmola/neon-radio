import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/station.dart';
import 'audio_handler.dart';

class RadioProvider extends ChangeNotifier {
  final RadioAudioHandler _handler;
  RadioProvider(this._handler) {
    _init();
  }

  final List<Station> stations = defaultStations;
  Station? current;
  bool playing = false;
  bool loading = false;
  String? error;

  String nowTitle = 'Bir istasyon seçin';
  String nowArtist = '';
  final List<TrackInfo> history = [];
  Set<String> favoriteIds = {};

  double volume = 1.0;
  Duration? sleepLeft;
  Timer? _sleepTimer;
  String? _lastRaw;

  AudioPlayer get _p => _handler.player;

  List<Station> get favorites =>
      stations.where((s) => favoriteIds.contains(s.id)).toList();

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteIds = (prefs.getStringList('favs') ?? []).toSet();

    _p.playerStateStream.listen((s) {
      playing = s.playing;
      loading = s.processingState == ProcessingState.loading ||
          s.processingState == ProcessingState.buffering;
      notifyListeners();
    });

    // Radyo akışındaki ICY metadata ("Sanatçı - Şarkı")
    _p.icyMetadataStream.listen(_onIcy);
    notifyListeners();
  }

  void _onIcy(IcyMetadata? m) {
    final raw = m?.info?.title?.trim();
    if (raw == null || raw.isEmpty || raw == _lastRaw) return;
    _lastRaw = raw;

    final parts = raw.split(' - ');
    if (parts.length >= 2) {
      nowArtist = parts.first.trim();
      nowTitle = parts.sublist(1).join(' - ').trim();
    } else {
      nowArtist = current?.name ?? '';
      nowTitle = raw;
    }

    history.insert(
      0,
      TrackInfo(
          artist: nowArtist, title: nowTitle, station: current?.name ?? ''),
    );
    if (history.length > 50) history.removeLast();

    final item = _handler.mediaItem.value;
    if (item != null) {
      _handler.mediaItem.add(item.copyWith(title: nowTitle, artist: nowArtist));
    }
    notifyListeners();
  }

  Future<void> selectStation(Station s) async {
    current = s;
    error = null;
    _lastRaw = null;
    nowTitle = 'Yayına bağlanılıyor…';
    nowArtist = s.name;
    notifyListeners();
    try {
      await _handler.playStation(s);
    } catch (e) {
      error = 'Yayına bağlanılamadı. İnternetinizi veya URL\'yi kontrol edin.';
      nowTitle = 'Bağlantı hatası';
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (playing) {
      await _handler.pause();
    } else {
      await selectStation(current ?? stations.first);
    }
  }

  Future<void> setVolume(double v) async {
    volume = v;
    await _p.setVolume(v);
    notifyListeners();
  }

  bool isFavorite(Station s) => favoriteIds.contains(s.id);

  Future<void> toggleFavorite(Station s) async {
    isFavorite(s) ? favoriteIds.remove(s.id) : favoriteIds.add(s.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favs', favoriteIds.toList());
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    setSleepTimer(null);
    await _handler.stop();
    nowTitle = 'Bir istasyon seçin';
    nowArtist = '';
    notifyListeners();
  }

  // ---- Uyku zamanlayıcısı ----
  void setSleepTimer(Duration? d) {
    _sleepTimer?.cancel();
    sleepLeft = d;
    if (d == null) {
      notifyListeners();
      return;
    }
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      final left = (sleepLeft ?? Duration.zero) - const Duration(seconds: 1);
      if (left <= Duration.zero) {
        t.cancel();
        sleepLeft = null;
        await _handler.stop();
      } else {
        sleepLeft = left;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
