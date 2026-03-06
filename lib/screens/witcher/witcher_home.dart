// lib/screens/witcher/witcher_home.dart
// الصفحة الرئيسية المعتمدة على Witcher API بدلاً من الامتدادات
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anymex/controllers/witcher/witcher_api.dart';
import 'package:anymex/screens/witcher/witcher_details.dart';
import 'package:anymex/utils/tv_scroll_mixin.dart';
import 'package:anymex/constants/themes.dart';

class WitcherHome extends StatefulWidget {
  const WitcherHome({super.key});

  @override
  State<WitcherHome> createState() => _WitcherHomeState();
}

class _WitcherHomeState extends State<WitcherHome> with TVScrollMixin {
  final _scroll = ScrollController();
  List<WAnime> _all = [];
  bool _loading = true;
  String? _error;

  @override
  ScrollController get scrollController => _scroll;

  @override
  void initState() {
    super.initState();
    initTVScroll();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    disposeTVScroll();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await WitcherApi.instance.fetchMain();
      if (mounted) setState(() { _all = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text('خطأ في الاتصال', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () { setState(() { _loading = true; _error = null; }); _load(); }, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }

    final featured = _all.take(3).toList();
    final trending = _all.skip(3).take(7).toList();
    final rest     = _all.skip(10).toList();

    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        physics: getTVScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            pinned: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              children: [
                Text('Anime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: primary)),
              ],
            ),
          ),

          // ─── البانر الدوار ────────────────────────────────
          if (featured.isNotEmpty)
            SliverToBoxAdapter(child: _FeaturedCarousel(items: featured)),

          // ─── رائج الآن ────────────────────────────────────
          if (trending.isNotEmpty) ...[
            _sectionHeader('رائج الآن 🔥'),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trending.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _MiniCard(anime: trending[i]),
                ),
              ),
            ),
          ],

          // ─── أحدث الحلقات ────────────────────────────────
          _sectionHeader('أحدث الحلقات المضافة'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _AnimeCard(anime: rest[i]),
                childCount: rest.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.62,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _sectionHeader(String title) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
}

// ─── البانر الرئيسي ──────────────────────────────────────
class _FeaturedCarousel extends StatefulWidget {
  final List<WAnime> items;
  const _FeaturedCarousel({required this.items});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final _controller = PageController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    final next = (_current + 1) % widget.items.length;
    _controller.animateToPage(next,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.items.length,
            itemBuilder: (_, i) {
              final a = widget.items[i];
              return GestureDetector(
                onTap: () => Get.to(() => WitcherDetails(anime: a),
                    transition: Transition.rightToLeft),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: a.poster,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: Colors.grey[900]),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text('مميز #${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                          const SizedBox(height: 6),
                          Text(a.name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(blurRadius: 8, color: Colors.black)
                                  ])),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => Get.to(
                                () => WitcherDetails(anime: a),
                                transition: Transition.rightToLeft),
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('شاهد الآن'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 14,
          child: Row(
            children: List.generate(
              widget.items.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _current == i
                      ? primary
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── بطاقة صغيرة (trending) ──────────────────────────────
class _MiniCard extends StatelessWidget {
  final WAnime anime;
  const _MiniCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => WitcherDetails(anime: anime), transition: Transition.rightToLeft),
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: anime.poster,
                    width: 110,
                    height: 155,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.grey[900], width: 110, height: 155),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('HD',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(anime.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── بطاقة الشبكة ────────────────────────────────────────
class _AnimeCard extends StatelessWidget {
  final WAnime anime;
  const _AnimeCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => WitcherDetails(anime: anime), transition: Transition.rightToLeft),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: anime.poster,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Container(color: Colors.grey[900]),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Text(anime.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
