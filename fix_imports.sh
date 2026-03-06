#!/bin/bash
# fix_imports.sh — يُصلح جميع imports من dartotsu_extension_bridge
# شغّله من داخل مجلد NyanTV

set -e
cd ~/NyanTV

echo "=== 1. تحديث ملف الـ stubs ==="
cat > lib/stubs/extension_stubs.dart << 'STUBS'
// Stubs for dartotsu_extension_bridge — replaces the removed dependency

// ---- Enums ----
enum ExtensionType { anime, manga, novel }

enum ItemType { anime, manga, novel, unknown }

// ---- Classes ----
class Source {
  final int? id;
  final String? name;
  final String? lang;
  final bool? hasUpdate;
  final ExtensionType? extensionType;
  const Source({this.id, this.name, this.lang, this.hasUpdate, this.extensionType});
}

class DMedia {
  final String? url;
  final String? title;
  final String? cover;
  final ItemType? itemType;
  const DMedia({this.url, this.title, this.cover, this.itemType});
}

class DEpisode {
  final String? name;
  final String? url;
  final double? episodeNum;
  const DEpisode({this.name, this.url, this.episodeNum});
}

class Video {
  final String? url;
  final String? quality;
  const Video({this.url, this.quality});
}

class SourcePreference {
  const SourcePreference();
}

// Isar schema stubs
class MSourceSchema {}
class SourcePreferenceSchema {}
class SourcePreferenceStringValueSchema {}
class BridgeSettingsSchema {}

// Extension manager stubs
class DartotsuExtensionBridge {
  const DartotsuExtensionBridge(dynamic isar);
}

class AniyomiExtensions {
  const AniyomiExtensions();
}

class MangayomiExtensions {
  const MangayomiExtensions();
}

// String extension stub (for bottom_sheet.dart toInt)
extension StringToIntExt on String {
  int toInt() => int.tryParse(this) ?? 0;
}

// DMedia extension mapper stub
extension DMediaMapper on DMedia {
  dynamic toCarouselData() => null;
}
STUBS

echo "=== 2. استبدال جميع imports من dartotsu_extension_bridge ==="

STUB_IMPORT="import 'package:nyantv/stubs/extension_stubs.dart';"

FILES=(
  "lib/controllers/cacher/cache_controller.dart"
  "lib/controllers/offline/offline_storage_controller.dart"
  "lib/controllers/services/anilist/anilist_data.dart"
  "lib/controllers/services/mal/mal_service.dart"
  "lib/controllers/services/simkl/simkl_service.dart"
  "lib/controllers/services/widgets/widgets_builders.dart"
  "lib/controllers/source/source_controller.dart"
  "lib/controllers/source/source_mapper.dart"
  "lib/models/Media/media.dart"
  "lib/models/Offline/Hive/video.dart"
  "lib/models/models_convertor/carousel_mapper.dart"
  "lib/screens/anime/details_page.dart"
  "lib/screens/anime/watch/controller/player_controller.dart"
  "lib/screens/anime/watch/controls/widgets/bottom_sheet.dart"
  "lib/screens/anime/watch_page.dart"
  "lib/screens/anime/widgets/custom_list_dialog.dart"
  "lib/screens/anime/widgets/episode_list_builder.dart"
  "lib/screens/anime/widgets/episode_section.dart"
  "lib/screens/anime/widgets/episode_watch_screen.dart"
  "lib/screens/anime/widgets/wrongtitle_modal.dart"
  "lib/screens/extensions/ExtensionItem.dart"
  "lib/screens/extensions/ExtensionList.dart"
  "lib/screens/extensions/ExtensionScreen.dart"
  "lib/screens/extensions/ExtensionSettings/ExtensionSettings.dart"
  "lib/screens/extensions/widgets/repo_sheet.dart"
  "lib/screens/library/editor/list_editor.dart"
  "lib/screens/library/my_library.dart"
  "lib/screens/library/widgets/anime_card.dart"
  "lib/screens/library/widgets/common_widgets.dart"
  "lib/screens/library/widgets/history_model.dart"
  "lib/screens/search/source_search_page.dart"
  "lib/screens/settings/sub_settings/settings_extensions.dart"
  "lib/screens/settings/sub_settings/widgets/repo_dialog.dart"
  "lib/screens/settings/widgets/card_selector.dart"
  "lib/utils/deeplink.dart"
  "lib/utils/extension_utils.dart"
  "lib/utils/extensions.dart"
  "lib/utils/function.dart"
  "lib/utils/storage_provider.dart"
  "lib/widgets/common/cards/base_card.dart"
  "lib/widgets/common/cards/card_gate.dart"
  "lib/widgets/common/cards/media_cards.dart"
  "lib/widgets/common/future_reusable_carousel.dart"
  "lib/widgets/common/reusable_carousel.dart"
)

for FILE in "${FILES[@]}"; do
  if [ -f "$FILE" ]; then
    # احذف جميع imports من dartotsu
    sed -i "/import 'package:dartotsu_extension_bridge/d" "$FILE"
    # أضف import الـ stubs بعد السطر الأول (عادةً import dart: أو package:flutter)
    # تحقق أولاً أنه غير موجود
    if ! grep -q "extension_stubs.dart" "$FILE"; then
      sed -i "1s|^|$STUB_IMPORT\n|" "$FILE"
    fi
    echo "✓ $FILE"
  else
    echo "✗ غير موجود: $FILE"
  fi
done

echo ""
echo "=== 3. إصلاح isar في source_controller.dart ==="
# استبدل استدعاءات isar بقيم stub
sed -i 's/isar\./\/\/ isar./g' lib/controllers/source/source_controller.dart 2>/dev/null || true

echo ""
echo "=== اكتمل الإصلاح! ==="
echo "الخطوة التالية:"
echo "  git add ."
echo "  git commit -m 'fix: replace dartotsu imports with stubs'"
echo "  git push origin main"
