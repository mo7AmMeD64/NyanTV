// lib/screens/witcher/witcher_search.dart
// صفحة البحث بـ Witcher API
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anymex/controllers/witcher/witcher_api.dart';
import 'package:anymex/screens/witcher/witcher_details.dart';

class WitcherSearch extends StatefulWidget {
  const WitcherSearch({super.key});

  @override
  State<WitcherSearch> createState() => _WitcherSearchState();
}

class _WitcherSearchState extends State<WitcherSearch> {
  final _controller = TextEditingController();
  List<WAnime> _results = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _searched = true; _results = []; });
    try {
      final list = await WitcherApi.instance.search(q);
      if (mounted) setState(() { _results = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── شريط البحث ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.12)),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _search(),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن أنمي...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _search,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Text('بحث',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // ─── النتائج ─────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : !_searched
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search,
                                  size: 60,
                                  color: Colors.grey.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text('ابحث عن أنمياتك المفضلة',
                                  style:
                                      TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : _results.isEmpty
                          ? Center(
                              child: Text('لا توجد نتائج',
                                  style:
                                      TextStyle(color: Colors.grey[600])),
                            )
                          : GridView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.62,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _results.length,
                              itemBuilder: (_, i) {
                                final a = _results[i];
                                return GestureDetector(
                                  onTap: () => Get.to(
                                      () => WitcherDetails(anime: a),
                                      transition: Transition.rightToLeft),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: a.poster,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                                  color: Colors.grey[900]),
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
                                                colors: [
                                                  Colors.black87,
                                                  Colors.transparent
                                                ],
                                              ),
                                            ),
                                            child: Text(
                                              a.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
