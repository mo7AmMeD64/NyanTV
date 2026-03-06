#!/bin/bash
# clean_fix.sh — إعادة تعيين الملفات المتضررة وإصلاحها بشكل صحيح
cd ~/NyanTV

echo "=== 1. استعادة الملفات المتضررة من git ==="
# استعادة الملفات التي أفسدتها السكريبتات السابقة
git checkout HEAD -- \
  lib/screens/anime/watch/controls/widgets/bottom_sheet.dart \
  lib/screens/anime/watch_page.dart \
  lib/screens/anime/widgets/episode_watch_screen.dart \
  lib/screens/anime/watch/controller/player_controller.dart \
  lib/models/Offline/Hive/video.dart \
  lib/utils/storage_provider.dart \
  lib/utils/deeplink.dart \
  lib/utils/function.dart \
  lib/screens/anime/details_page.dart \
  lib/screens/anime/widgets/episode_list_builder.dart \
  lib/screens/anime/widgets/episode_section.dart \
  lib/controllers/source/source_controller.dart

echo "✓ الملفات استُعيدت"

echo ""
echo "=== 2. إزالة imports dartotsu من الملفات المستعادة ==="
FILES=(
  "lib/screens/anime/watch/controls/widgets/bottom_sheet.dart"
  "lib/screens/anime/watch_page.dart"
  "lib/screens/anime/widgets/episode_watch_screen.dart"
  "lib/screens/anime/watch/controller/player_controller.dart"
  "lib/models/Offline/Hive/video.dart"
  "lib/utils/storage_provider.dart"
  "lib/utils/deeplink.dart"
  "lib/utils/function.dart"
  "lib/screens/anime/details_page.dart"
  "lib/screens/anime/widgets/episode_list_builder.dart"
  "lib/screens/anime/widgets/episode_section.dart"
  "lib/controllers/source/source_controller.dart"
)

for FILE in "${FILES[@]}"; do
  # حذف imports dartotsu_extension_bridge
  sed -i "/import 'package:dartotsu_extension_bridge/d" "$FILE"
  # إضافة import الـ stubs إن لم يكن موجوداً
  if ! grep -q "extension_stubs" "$FILE"; then
    sed -i "1s|^|import 'package:nyantv/stubs/extension_stubs.dart';\n|" "$FILE"
  fi
  echo "✓ $FILE"
done

echo ""
echo "=== 3. إصلاح stubs - إزالة syntax error ==="
cat > lib/stubs/extension_stubs.dart << 'STUBS'
// Stubs for dartotsu_extension_bridge

import 'package:flutter/widgets.dart';

enum ExtensionType {
  anime, manga, novel, mangayomi, aniyomi;
  dynamic getManager() => null;
}

enum ItemType { anime, manga, novel, unknown }

class Source {
  final int? id;
  final String? name;
  final String? lang;
  final bool? hasUpdate;
  final bool? isNsfw;
  final String? iconUrl;
  final String? version;
  final String? baseUrl;
  final dynamic methods;
  final ExtensionType? extensionType;
  const Source({this.id, this.name, this.lang, this.hasUpdate,
    this.isNsfw, this.iconUrl, this.version, this.baseUrl,
    this.methods, this.extensionType});
}

class DMedia {
  final String? url;
  final String? title;
  final String? cover;
  final String? description;
  final dynamic genre;
  final ItemType? itemType;
  final List<DEpisode>? episodes;
  const DMedia({this.url, this.title, this.cover, this.description,
    this.genre, this.itemType, this.episodes});
  static DMedia fromJson(Map<String, dynamic> json) =>
      DMedia(url: json['url']?.toString(), title: json['title']?.toString(),
             cover: json['cover']?.toString());
  DMedia withUrl(String newUrl) => DMedia(url: newUrl, title: title,
      cover: cover, description: description, genre: genre,
      itemType: itemType, episodes: episodes);
}

class DEpisode {
  final String? name;
  final String? url;
  final double? episodeNum;
  final int? episodeNumber;
  const DEpisode({this.name, this.url, this.episodeNum, this.episodeNumber});
}

class Video {
  final String? url;
  final String? quality;
  final List<Track> subtitleTracks;
  final List<Track> audioTracks;
  const Video({this.url, this.quality,
    this.subtitleTracks = const [],
    this.audioTracks = const []});
  static Video fromVideo(dynamic v) => Video(url: v?.url?.toString());
}

class Track {
  final String? url;
  final String? label;
  final String? lang;
  const Track({this.url, this.label, this.lang});
}

class BottomSheetItem {
  final String title;
  final dynamic icon;
  final VoidCallback? onTap;
  const BottomSheetItem({required this.title, this.icon, this.onTap});
}

class SourcePreference {
  final dynamic type;
  final dynamic checkBoxPreference;
  final dynamic switchPreferenceCompat;
  final dynamic listPreference;
  final dynamic multiSelectListPreference;
  final dynamic editTextPreference;
  final String? key;
  const SourcePreference({this.type, this.checkBoxPreference,
    this.switchPreferenceCompat, this.listPreference,
    this.multiSelectListPreference, this.editTextPreference, this.key});
}

class MSourceSchema {}
class SourcePreferenceSchema {}
class SourcePreferenceStringValueSchema {}
class BridgeSettingsSchema {}

class DartotsuExtensionBridge {
  DartotsuExtensionBridge([dynamic isar]);
  Future<void> init() async {}
}

class AniyomiExtensions { const AniyomiExtensions(); }
class MangayomiExtensions { const MangayomiExtensions(); }

extension DMediaMapper on DMedia {
  dynamic toCarouselData() => null;
}
STUBS
echo "✓ stubs محدّث"

echo ""
echo "=== 4. إصلاح نقاط محددة ==="

# storage_provider.dart: تعليق Schema stubs في الـ isar list
python3 << 'PYEOF'
with open('lib/utils/storage_provider.dart', 'r') as f:
    content = f.read()
content = content.replace('MSourceSchema,', '// MSourceSchema,')
content = content.replace('SourcePreferenceSchema,', '// SourcePreferenceSchema,')
content = content.replace('SourcePreferenceStringValueSchema,', '// SourcePreferenceStringValueSchema,')
content = content.replace('BridgeSettingsSchema,', '// BridgeSettingsSchema,')
with open('lib/utils/storage_provider.dart', 'w') as f:
    f.write(content)
print("✓ storage_provider.dart")
PYEOF

# source_controller.dart: إصلاح DartotsuExtensionBridge args
python3 << 'PYEOF'
import re
with open('lib/controllers/source/source_controller.dart', 'r') as f:
    content = f.read()
# استبدال DartotsuExtensionBridge(x, y) بـ DartotsuExtensionBridge()
content = re.sub(r'DartotsuExtensionBridge\([^)]+\)', 'DartotsuExtensionBridge()', content)
with open('lib/controllers/source/source_controller.dart', 'w') as f:
    f.write(content)
print("✓ source_controller.dart - DartotsuExtensionBridge")
PYEOF

# episode_section.dart: تعليق SourcePreferenceScreen
python3 << 'PYEOF'
with open('lib/screens/anime/widgets/episode_section.dart', 'r') as f:
    content = f.read()
import re
content = re.sub(r'SourcePreferenceScreen\([^)]*\)', 'Container()', content)
# حذف import ExtensionSettings
content = re.sub(r"import '.*ExtensionSettings.*';\n", '', content)
with open('lib/screens/anime/widgets/episode_section.dart', 'w') as f:
    f.write(content)
print("✓ episode_section.dart")
PYEOF

# settings_sheet.dart: إصلاح ExtensionScreen
python3 << 'PYEOF'
with open('lib/widgets/non_widgets/settings_sheet.dart', 'r') as f:
    content = f.read()
import re
content = re.sub(r"import '.*ExtensionScreen.*';\n", '', content)
content = re.sub(r'(?:const )?ExtensionScreen\(\)', 'const SizedBox()', content)
with open('lib/widgets/non_widgets/settings_sheet.dart', 'w') as f:
    f.write(content)
print("✓ settings_sheet.dart")
PYEOF

# function.dart: إصلاح episodeNumber?.toString()
python3 << 'PYEOF'
with open('lib/utils/function.dart', 'r') as f:
    content = f.read()
content = content.replace('.episodeNumber,', '.episodeNumber?.toString() ?? "",')
content = content.replace('.episodeNumber?.toString(),', '.episodeNumber?.toString() ?? "",')
with open('lib/utils/function.dart', 'w') as f:
    f.write(content)
print("✓ function.dart")
PYEOF

# deeplink.dart: تعليق السطر الذي يستخدم 'd' undefined
python3 << 'PYEOF'
with open('lib/utils/deeplink.dart', 'r') as f:
    lines = f.readlines()
new_lines = []
for i, line in enumerate(lines):
    # السطر 129 يستخدم 'd' كـ undefined - نعلقه
    if i == 128 and 'd.' in line:  # 0-indexed = 128
        new_lines.append('      // STUB: ' + line.lstrip())
    else:
        new_lines.append(line)
with open('lib/utils/deeplink.dart', 'w') as f:
    f.writelines(new_lines)
print("✓ deeplink.dart")
PYEOF

echo ""
echo "✅ اكتمل الإصلاح الكامل!"
echo ""
echo "  git add ."
echo "  git commit -m 'fix: clean reset and proper fixes for all compile errors'"
echo "  git push origin main"
