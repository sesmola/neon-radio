class Station {
  final String id;
  final String name;
  final String genre;
  final String streamUrl;

  const Station({
    required this.id,
    required this.name,
    required this.genre,
    required this.streamUrl,
  });
}

class TrackInfo {
  final String artist;
  final String title;
  final String station;
  final DateTime playedAt;

  TrackInfo({
    required this.artist,
    required this.title,
    required this.station,
    DateTime? playedAt,
  }) : playedAt = playedAt ?? DateTime.now();
}

/// Varsayılan 7/24 yayınlar (SomaFM). Kendi akış URL'lerinizi buraya ekleyin.
const List<Station> defaultStations = [
  Station(
    id: 'groovesalad',
    name: 'Groove Salad',
    genre: 'Chillout / Downtempo',
    streamUrl: 'https://ice1.somafm.com/groovesalad-128-mp3',
  ),
  Station(
    id: 'defcon',
    name: 'DEF CON Radio',
    genre: 'Electronic / Hacker',
    streamUrl: 'https://ice1.somafm.com/defcon-128-mp3',
  ),
  Station(
    id: 'spacestation',
    name: 'Space Station',
    genre: 'Ambient / Electronica',
    streamUrl: 'https://ice1.somafm.com/spacestation-128-mp3',
  ),
  Station(
    id: 'secretagent',
    name: 'Secret Agent',
    genre: 'Lounge / Spy',
    streamUrl: 'https://ice1.somafm.com/secretagent-128-mp3',
  ),
  // Kendi yayınınız (Icecast mount noktası):
  Station(
    id: 'mine',
    name: 'Benim Yayınım',
    genre: 'Canlı DJ',
    streamUrl: 'http://SUNUCU_IP:8000/live',
  ),
];
