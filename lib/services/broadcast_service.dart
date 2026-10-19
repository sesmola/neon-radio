import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum BroadcastState { idle, connecting, live, reconnecting, error }

/// Mikrofon -> WebRTC (WHIP protokolü) -> MediaMTX -> FFmpeg -> Icecast
/// Sunucu kurulumu için server/ klasörüne bakın.
class BroadcastService extends ChangeNotifier {
  BroadcastState state = BroadcastState.idle;
  String? message;
  Duration elapsed = Duration.zero;
  bool autoReconnect = true;
  bool muted = false;

  RTCPeerConnection? _pc;
  MediaStream? _stream;
  String? _resource;
  Timer? _clock;
  bool _wantLive = false;
  bool _retryPending = false;
  int _attempts = 0;
  String _url = '';
  String? _token;

  bool get isLive => state == BroadcastState.live;
  bool get isBusy =>
      state == BroadcastState.connecting || state == BroadcastState.reconnecting;

  Future<void> start(String whipUrl, {String? token}) async {
    if (_wantLive) return;
    _url = whipUrl.trim();
    _token = (token == null || token.trim().isEmpty) ? null : token.trim();

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      _set(BroadcastState.error, 'Mikrofon izni verilmedi');
      return;
    }

    _wantLive = true;
    _attempts = 0;
    elapsed = Duration.zero;
    await WakelockPlus.enable();
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isLive) {
        elapsed += const Duration(seconds: 1);
        notifyListeners();
      }
    });
    await _connect();
  }

  Future<void> _connect() async {
    _set(_attempts == 0 ? BroadcastState.connecting : BroadcastState.reconnecting,
        null);
    try {
      await _teardown(deleteResource: false);

      _stream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': false,
          'noiseSuppression': false,
          'autoGainControl': false,
        },
        'video': false,
      });
      for (final t in _stream!.getAudioTracks()) {
        t.enabled = !muted;
      }

      final pc = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'}
        ],
      });
      _pc = pc;

      for (final t in _stream!.getAudioTracks()) {
        await pc.addTrack(t, _stream!);
      }

      pc.onConnectionState = (s) {
        if (!_wantLive) return;
        if (s == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _attempts = 0;
          _set(BroadcastState.live, null);
        } else if (s == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            s == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          _scheduleReconnect();
        }
      };

      // WHIP: ICE toplamayı bekleyip tek seferde SDP gönder (non-trickle)
      final gathered = Completer<void>();
      pc.onIceGatheringState = (s) {
        if (s == RTCIceGatheringState.RTCIceGatheringStateComplete &&
            !gathered.isCompleted) {
          gathered.complete();
        }
      };

      final offer = await pc.createOffer({
        'offerToReceiveAudio': false,
        'offerToReceiveVideo': false,
      });
      await pc.setLocalDescription(offer);
      await gathered.future.timeout(const Duration(seconds: 4), onTimeout: () {});
      final local = await pc.getLocalDescription();

      final res = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Content-Type': 'application/sdp',
              if (_token != null) 'Authorization': 'Bearer $_token',
            },
            body: local!.sdp,
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception('Sunucu ${res.statusCode} döndü');
      }
      final loc = res.headers['location'];
      if (loc != null) _resource = Uri.parse(_url).resolve(loc).toString();

      await pc.setRemoteDescription(RTCSessionDescription(res.body, 'answer'));
    } catch (e) {
      debugPrint('Broadcast error: $e');
      _scheduleReconnect(error: e.toString());
    }
  }

  void _scheduleReconnect({String? error}) {
    if (!_wantLive || _retryPending) return;
    if (!autoReconnect || _attempts >= 20) {
      _wantLive = false;
      _finish();
      _set(BroadcastState.error, error ?? 'Bağlantı koptu');
      return;
    }
    _attempts++;
    _set(BroadcastState.reconnecting, error ?? 'Bağlantı koptu, yeniden deneniyor…');
    final wait = Duration(seconds: (_attempts * 2).clamp(2, 15));
    _retryPending = true;
    Future.delayed(wait, () {
      _retryPending = false;
      if (_wantLive && state == BroadcastState.reconnecting) _connect();
    });
  }

  void setAutoReconnect(bool v) {
    autoReconnect = v;
    notifyListeners();
  }

  void toggleMute() {
    muted = !muted;
    for (final t in _stream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      t.enabled = !muted;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    _wantLive = false;
    await _teardown(deleteResource: true);
    _finish();
    _set(BroadcastState.idle, null);
  }

  void _finish() {
    _clock?.cancel();
    WakelockPlus.disable();
  }

  Future<void> _teardown({required bool deleteResource}) async {
    if (deleteResource && _resource != null) {
      try {
        await http.delete(Uri.parse(_resource!), headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
        }).timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
    _resource = null;
    for (final t in _stream?.getTracks() ?? <MediaStreamTrack>[]) {
      await t.stop();
    }
    await _stream?.dispose();
    _stream = null;
    await _pc?.close();
    _pc = null;
  }

  void _set(BroadcastState s, String? msg) {
    state = s;
    message = msg;
    notifyListeners();
  }

  @override
  void dispose() {
    _wantLive = false;
    _clock?.cancel();
    super.dispose();
  }
}
