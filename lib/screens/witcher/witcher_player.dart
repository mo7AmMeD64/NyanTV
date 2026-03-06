// lib/screens/witcher/witcher_player.dart
// مشغل الفيديو المدمج مع اختيار السيرفرات
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nyantv/controllers/witcher/witcher_api.dart';

class WitcherPlayer extends StatefulWidget {
  final WEpisode episode;
  final WAnime anime;
  final List<WEpisode> allEpisodes;
  final int initialIndex;

  const WitcherPlayer({
    super.key,
    required this.episode,
    required this.anime,
    required this.allEpisodes,
    required this.initialIndex,
  });

  @override
  State<WitcherPlayer> createState() => _WitcherPlayerState();
}

class _WitcherPlayerState extends State<WitcherPlayer> {
  late final Player _player;
  late final VideoController _videoController;

  List<WServer> _servers = [];
  WServer? _activeServer;
  bool _loadingServers = true;
  bool _showControls = true;
  String? _error;

  late WEpisode _currentEp;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _currentEp = widget.episode;
    _currentIndex = widget.initialIndex;

    // إخفاء شريط الحالة وضبط الاتجاه أفقياً
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _loadServers();
  }

  @override
  void dispose() {
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _loadServers() async {
    if (mounted) setState(() { _loadingServers = true; _error = null; });
    try {
      final parsed = WitcherApi.parseLink(_currentEp.link);
      final servers = await WitcherApi.instance.fetchServers(parsed.anime, parsed.ep);
      if (servers.isEmpty) throw Exception('لا توجد سيرفرات');
      if (mounted) {
        setState(() {
          _servers = servers;
          _loadingServers = false;
          _activeServer = servers.first;
        });
        _playServer(servers.first);
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loadingServers = false; });
    }
  }

  Future<void> _playServer(WServer server) async {
    setState(() => _activeServer = server);
    await _player.open(Media(server.bestUrl), play: true);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _playEpisode(int index) {
    if (index < 0 || index >= widget.allEpisodes.length) return;
    setState(() {
      _currentIndex = index;
      _currentEp = widget.allEpisodes[index];
      _servers = [];
      _activeServer = null;
    });
    _loadServers();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // ─── الفيديو ──────────────────────────────────
            Center(child: Video(controller: _videoController)),

            // ─── التحميل ──────────────────────────────────
            if (_loadingServers)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // ─── خطأ ──────────────────────────────────────
            if (_error != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 50),
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _loadServers,
                        child: const Text('إعادة المحاولة')),
                  ],
                ),
              ),

            // ─── واجهة التحكم ─────────────────────────────
            if (_showControls && !_loadingServers && _error == null)
              AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: _ControlsOverlay(
                  player: _player,
                  anime: widget.anime,
                  episode: _currentEp,
                  servers: _servers,
                  activeServer: _activeServer,
                  onServerSelect: _playServer,
                  onPrev: _currentIndex > 0
                      ? () => _playEpisode(_currentIndex - 1)
                      : null,
                  onNext: _currentIndex < widget.allEpisodes.length - 1
                      ? () => _playEpisode(_currentIndex + 1)
                      : null,
                  onClose: () => Get.back(),
                  primary: primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── طبقة أدوات التحكم ───────────────────────────────────
class _ControlsOverlay extends StatelessWidget {
  final Player player;
  final WAnime anime;
  final WEpisode episode;
  final List<WServer> servers;
  final WServer? activeServer;
  final void Function(WServer) onServerSelect;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onClose;
  final Color primary;

  const _ControlsOverlay({
    required this.player,
    required this.anime,
    required this.episode,
    required this.servers,
    required this.activeServer,
    required this.onServerSelect,
    required this.onPrev,
    required this.onNext,
    required this.onClose,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // تعتيم خلفي
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),

        // ─── شريط علوي ────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white),
                  onPressed: onClose,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(anime.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'حلقة ${episode.number.toString().padLeft(3, '0')}',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── أزرار وسط ────────────────────────────────
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // السابقة
              _CircleBtn(
                icon: Icons.skip_previous,
                onTap: onPrev,
                size: 36,
              ),
              const SizedBox(width: 20),
              // رجوع 10 ثوانٍ
              _CircleBtn(
                icon: Icons.replay_10,
                onTap: () => player.seek(
                    (player.state.position) - const Duration(seconds: 10)),
                size: 30,
              ),
              const SizedBox(width: 16),
              // تشغيل/إيقاف
              StreamBuilder<bool>(
                stream: player.stream.playing,
                builder: (_, snap) {
                  final playing = snap.data ?? false;
                  return GestureDetector(
                    onTap: () => player.playOrPause(),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: primary.withOpacity(0.5),
                                blurRadius: 12)
                          ]),
                      child: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              // تقديم 10 ثوانٍ
              _CircleBtn(
                icon: Icons.forward_10,
                onTap: () => player.seek(
                    (player.state.position) + const Duration(seconds: 10)),
                size: 30,
              ),
              const SizedBox(width: 20),
              // التالية
              _CircleBtn(
                icon: Icons.skip_next,
                onTap: onNext,
                size: 36,
              ),
            ],
          ),
        ),

        // ─── شريط سفلي (شريط التقدم + السيرفرات) ────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // شريط التقدم
                StreamBuilder<Duration>(
                  stream: player.stream.position,
                  builder: (_, posSnap) {
                    return StreamBuilder<Duration>(
                      stream: player.stream.duration,
                      builder: (_, durSnap) {
                        final pos = posSnap.data ?? Duration.zero;
                        final dur = durSnap.data ?? Duration.zero;
                        final progress =
                            dur.inMilliseconds > 0
                                ? pos.inMilliseconds /
                                    dur.inMilliseconds
                                : 0.0;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_fmt(pos),
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11)),
                                Text(_fmt(dur),
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                                overlayShape:
                                    SliderComponentShape.noOverlay,
                                trackHeight: 3,
                                activeTrackColor: primary,
                                inactiveTrackColor:
                                    Colors.white.withOpacity(0.3),
                                thumbColor: primary,
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: (v) {
                                  if (dur > Duration.zero) {
                                    player.seek(Duration(
                                        milliseconds: (v *
                                                dur.inMilliseconds)
                                            .toInt()));
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                // السيرفرات
                if (servers.isNotEmpty)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: servers.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final s = servers[i];
                        final isActive = activeServer?.name == s.name;
                        final label = s.name +
                            (s.quality != null
                                ? ' [${s.quality}p]'
                                : '');
                        return GestureDetector(
                          onTap: () => onServerSelect(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? primary
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isActive
                                      ? primary
                                      : Colors.transparent),
                            ),
                            child: Text(label,
                                style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey[300],
                                    fontSize: 12)),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _CircleBtn({required this.icon, required this.onTap, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.3 : 1,
        child: Container(
          width: size + 16,
          height: size + 16,
          decoration: BoxDecoration(
              color: Colors.black45, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}
