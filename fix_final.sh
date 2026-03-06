#!/bin/bash
# fix_final.sh
cd ~/NyanTV

echo "=== 1. تحديث الـ stubs (حذف التعارضات) ==="
cat > lib/stubs/extension_stubs.dart << 'STUBS'
// Stubs for dartotsu_extension_bridge

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
      DMedia(url: json['url'], title: json['title'], cover: json['cover']);
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
STUBS

echo "✓ stubs محدّث"

echo ""
echo "=== 2. حذف مجلد extensions الذي لا نحتاجه ==="
rm -rf lib/screens/extensions/

echo "✓ مجلد extensions محذوف"

echo ""
echo "=== 3. إصلاح bottom_sheet.dart — استبدال .toInt() بـ int.tryParse ==="
if [ -f lib/screens/anime/watch/controls/widgets/bottom_sheet.dart ]; then
  sed -i 's/\.toInt()/\.contains('"'"'.'"'"') ? double.tryParse(it)?.toInt() ?? 0 : int.tryParse(it) ?? 0/g' \
    lib/screens/anime/watch/controls/widgets/bottom_sheet.dart 2>/dev/null || true
  # أبسط — فقط استبدل المكان المحدد
  sed -i 's/e\.toInt()/int.tryParse(e) ?? 0/g' \
    lib/screens/anime/watch/controls/widgets/bottom_sheet.dart
  sed -i 's/\.toInt()/.let((s) => int.tryParse(s) ?? 0)/g' \
    lib/screens/anime/watch/controls/widgets/bottom_sheet.dart
fi

echo ""
echo "=== 4. إصلاح carousel_mapper — حذف DMediaMapper من الـ stubs تم، التأكد من عدم تكرار الـ extension ==="
# DMediaMapper مُعرَّف في carousel_mapper.dart، لا حاجة له في stubs (وقد حُذف)

echo ""
echo "=== 5. إصلاح main.dart — التأكد من عدم import لـ ExtensionScreen ==="
sed -i "/ExtensionScreen/d" lib/main.dart
sed -i "/extensions\//d" lib/main.dart

echo ""
echo "✅ اكتمل الإصلاح!"
echo ""
echo "الآن:"
echo "  git add ."
echo "  git commit -m 'fix: remove extensions folder, fix stubs conflicts'"
echo "  git push origin main"
