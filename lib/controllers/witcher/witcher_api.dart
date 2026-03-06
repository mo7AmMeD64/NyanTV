// lib/controllers/witcher/witcher_api.dart
// كنترولر للتواصل مع API الخاص بـ Witcher
import 'dart:convert';
import 'package:http/http.dart' as http;

const _base = 'https://1we323-witcher.hf.space/api';
const _firestoreBase =
    'https://firestore.googleapis.com/v1/projects/animewitcher-1c66d/databases/(default)/documents';

// ─── النماذج ─────────────────────────────────────────────

class WAnime {
  final String id;
  final String name;
  final String poster;
  final String type;

  WAnime({
    required this.id,
    required this.name,
    required this.poster,
    required this.type,
  });

  factory WAnime.fromJson(Map<String, dynamic> j) => WAnime(
        id: j['id'] ?? j['objectID'] ?? '',
        name: j['name'] ?? j['title'] ?? '',
        poster: j['poster'] ?? j['image'] ?? '',
        type: j['type'] ?? 'TV',
      );
}

class WEpisode {
  final String title;
  final String link; // "animeId|epId"

  WEpisode({required this.title, required this.link});

  int get number {
    final m = RegExp(r'\d+').firstMatch(title);
    return m != null ? int.tryParse(m.group(0)!) ?? 0 : 0;
  }
}

class WServer {
  final String name;
  final String url;
  final String? proxyUrl;
  final String? quality;
  final String? lang;
  final bool playable;

  WServer({
    required this.name,
    required this.url,
    this.proxyUrl,
    this.quality,
    this.lang,
    this.playable = false,
  });

  String get bestUrl {
    if (proxyUrl != null && proxyUrl!.isNotEmpty) {
      return 'https://1we323-witcher.hf.space$proxyUrl';
    }
    return url;
  }

  factory WServer.fromJson(Map<String, dynamic> j) => WServer(
        name: j['name'] ?? 'سيرفر',
        url: j['url'] ?? '',
        proxyUrl: j['proxy_url'],
        quality: j['quality']?.toString(),
        lang: j['lang'],
        playable: j['playable'] == true,
      );
}

// ─── API ──────────────────────────────────────────────────

class WitcherApi {
  WitcherApi._();
  static final instance = WitcherApi._();

  // جلب الصفحة الرئيسية
  Future<List<WAnime>> fetchMain({int page = 1}) async {
    final res = await http.get(Uri.parse('$_base/main?page=$page'));
    final data = jsonDecode(res.body) as Map;
    final hits = (data['hits'] as List? ?? []);
    return hits.map((h) => WAnime.fromJson(h as Map<String, dynamic>)).toList();
  }

  // البحث
  Future<List<WAnime>> search(String q) async {
    final res =
        await http.get(Uri.parse('$_base/search?q=${Uri.encodeComponent(q)}'));
    final data = jsonDecode(res.body);
    final List raw = data is List ? data : (data['hits'] as List? ?? []);
    return raw.map((h) => WAnime.fromJson(h as Map<String, dynamic>)).toList();
  }

  // جلب صفحة حلقات (Firestore مع pagination)
  Future<({List<WEpisode> episodes, String? nextToken})> fetchEpisodes(
      String animeId,
      {String? pageToken,
      int pageSize = 100}) async {
    var url =
        '$_firestoreBase/anime_list/${Uri.encodeComponent(animeId)}/episodes?pageSize=$pageSize';
    if (pageToken != null) url += '&pageToken=${Uri.encodeComponent(pageToken)}';

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body) as Map;
    final docs = (data['documents'] as List? ?? []).map((doc) {
      final epId = (doc['name'] as String).split('/').last;
      return WEpisode(title: epId, link: '$animeId|$epId');
    }).toList();

    docs.sort((a, b) => a.number.compareTo(b.number));
    return (episodes: docs, nextToken: data['nextPageToken'] as String?);
  }

  // جلب سيرفرات الحلقة
  Future<List<WServer>> fetchServers(String animeId, String epId) async {
    final res = await http.get(Uri.parse(
        '$_base/servers_resolved?anime=${Uri.encodeComponent(animeId)}&ep=${Uri.encodeComponent(epId)}'));
    final data = jsonDecode(res.body) as Map;
    final servers = (data['servers'] as List? ?? [])
        .map((s) => WServer.fromJson(s as Map<String, dynamic>))
        .toList();
    // فضّل الـ playable
    servers.sort((a, b) => (b.playable ? 1 : 0) - (a.playable ? 1 : 0));
    return servers;
  }

  // تحليل رابط الحلقة "animeId|epId"
  static ({String anime, String ep}) parseLink(String link) {
    if (link.contains('|')) {
      final parts = link.split('|');
      return (anime: parts[0], ep: parts[1]);
    }
    return (anime: link, ep: '');
  }
}
