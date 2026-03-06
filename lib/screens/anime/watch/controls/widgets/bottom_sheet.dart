import 'package:nyantv/stubs/extension_stubs.dart';
import 'package:nyantv/models/Offline/Hive/video.dart';
import 'package:nyantv/screens/anime/watch/controller/player_controller.dart';
import 'package:nyantv/screens/anime/widgets/episode/normal_episode.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' hide Track;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class DynamicBottomSheet extends StatefulWidget {
  final String title;
  final List<BottomSheetItem> items;
  final int? selectedIndex;
  final Function(int)? onItemSelected;
  final Widget? customContent;

  const DynamicBottomSheet({
    super.key,
    required this.title,
    this.items = const [],
    this.selectedIndex,
    this.onItemSelected,
    this.customContent,
  });

  @override
  State<DynamicBottomSheet> createState() => _DynamicBottomSheetState();
}

class _DynamicBottomSheetState extends State<DynamicBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<BottomSheetItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

//  void _filterItems(String query) {
//    setState(() {
//      if (query.isEmpty) {
//        _filteredItems = widget.items;
//      } else {
//        _filteredItems = widget.items
//            .where((item) =>
//                item.title.toLowerCase().let((s) => int.tryParse(s) ?? 0) ?? 0 : int.tryParse(it) ?? 0 - 1,
        separatorBuilder: (context, i) => const SizedBox(height: 8),
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          final episode = episodes[index];
          final isSelected = episode == selectedEpisode.value;

          return BetterEpisode(
            episode: episode,
            isSelected: isSelected,
            onTap: () => controller.changeEpisode(episode),
            layoutType: EpisodeLayoutType.compact,
            offlineEpisodes: offlineEpisode,
            fallbackImageUrl:
                controller.anilistData.cover ?? controller.anilistData.poster,
          );
        },
      ),
    );
  }

  static Future<T?> showCustom<T>(
      {required BuildContext context,
      required String title,
      required Widget content,
      bool isExpanded = false}) {
    return show<T>(
      context: context,
      title: title,
      isExpanded: isExpanded,
      customContent: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: content,
      ),
    );
  }

  static showLoader() {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: BorderRadius.circular((20)),
        child: Container(
          color: Get.theme.colorScheme.surface,
          child: const Center(
            child: ExpressiveLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  static hideLoader() => Get.back();
}
