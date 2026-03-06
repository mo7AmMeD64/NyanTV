// lib/screens/witcher/witcher_details.dart
// صفحة تفاصيل الأنمي + قائمة الحلقات (من Witcher API)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anymex/controllers/witcher/witcher_api.dart';
import 'package:anymex/screens/witcher/witcher_player.dart';

class WitcherDetails extends StatefulWidget {
  final WAnime anime;
  const WitcherDetails({super.key, required this.anime});

  @override
  State<WitcherDetails> createState() => _WitcherDetailsState();
}

class _WitcherDetailsState extends State<WitcherDetails> {
  List<WEpisode> _episodes = [];
  String? _nextToken;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    try {
      final result =
          await WitcherApi.instance.fetchEpisodes(widget.anime.id);
      if (mounted) {
        setState(() {
          _episodes = result.episodes;
          _nextToken = result.nextToken;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _nextToken == null) return;
    setState(() => _loadingMore = true);
    try {
      final result = await WitcherApi.instance
          .fetchEpisodes(widget.anime.id, pageToken: _nextToken);
      if (mounted) {
        setState(() {
          _episodes = [..._episodes, ...result.episodes];
          _nextToken = result.nextToken;
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── رأس الصفحة ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.anime.poster,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.grey[900]),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: widget.anime.poster,
                            width: 70,
                            height: 98,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.anime.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 6, color: Colors.black)
                                      ])),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(widget.anime.type,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── قائمة الحلقات ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Row(
                children: [
                  const Icon(Icons.video_library_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'الحلقات (${_episodes.length}${_nextToken != null ? '+' : ''})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text('فشل التحميل',
                          style: TextStyle(color: Colors.grey[500])),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _loadEpisodes();
                          },
                          child: const Text('إعادة المحاولة')),
                    ],
                  ),
                ),
              ),
            )
          else if (_episodes.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('لا توجد حلقات بعد',
                      style: TextStyle(color: Colors.grey[500])),
                ),
              ),
            )
          else ...[
            // شبكة الحلقات
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _EpisodeBox(
                      ep: _episodes[i],
                      anime: widget.anime,
                      allEps: _episodes,
                      index: i),
                  childCount: _episodes.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
              ),
            ),

            // زر تحميل المزيد
            if (_nextToken != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: ElevatedButton.icon(
                    onPressed: _loadingMore ? null : _loadMore,
                    icon: _loadingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add_circle_outline),
                    label: Text(_loadingMore
                        ? 'جاري التحميل...'
                        : 'عرض المزيد من الحلقات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary.withOpacity(0.15),
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ─── صندوق حلقة واحدة ────────────────────────────────────
class _EpisodeBox extends StatelessWidget {
  final WEpisode ep;
  final WAnime anime;
  final List<WEpisode> allEps;
  final int index;

  const _EpisodeBox({
    required this.ep,
    required this.anime,
    required this.allEps,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final num = ep.number > 0 ? ep.number : index + 1;

    return GestureDetector(
      onTap: () => Get.to(
        () => WitcherPlayer(
          episode: ep,
          anime: anime,
          allEpisodes: allEps,
          initialIndex: index,
        ),
        transition: Transition.fadeIn,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('حلقة',
                style: TextStyle(fontSize: 9, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Text(
              num.toString().padLeft(3, '0'),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary),
            ),
          ],
        ),
      ),
    );
  }
}
