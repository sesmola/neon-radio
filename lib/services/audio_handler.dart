import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../models/station.dart';

/// Arka planda, kilit ekranında ve bildirim çubuğunda çalmayı sağlayan handler.
class RadioAudioHandler extends BaseAudioHandler {
  final AudioPlayer player = AudioPlayer();

  RadioAudioHandler() {
    player.playbackEventStream.map(_toState).pipe(playbackState);
  }

  PlaybackState _toState(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
    );
  }

  /// Canlı yayında "devam et" her zaman canlı noktaya atlamalıdır;
  /// bu yüzden istasyonu her seferinde yeniden yüklüyoruz.
  Future<void> playStation(Station s) async {
    mediaItem.add(MediaItem(
      id: s.streamUrl,
      title: s.name,
      artist: s.genre,
      isLive: true,
    ));
    await player.setAudioSource(AudioSource.uri(Uri.parse(s.streamUrl)));
    player.play();
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    return super.stop();
  }
}
