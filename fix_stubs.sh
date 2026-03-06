#!/bin/bash
# fix_stubs.sh — يحدث ملف الـ stubs بالأنواع الناقصة
cd ~/NyanTV

cat > lib/stubs/extension_stubs.dart << 'STUBS'
// Stubs for dartotsu_extension_bridge — replaces the removed dependency

// ---- Enums ----
enum ExtensionType {
  anime,
  manga,
  novel,
  mangayomi,
  aniyomi;

  dynamic getManager() => null;
}

enum ItemType { anime, manga, novel, unknown }

// ---- Classes ----
class Source {
  final int? id;
  final String? name;
  final String? lang;
  final bool? hasUpdate;
  final bool? isNsfw;
  final String? iconUrl;
  final String? version;
  final ExtensionType? extensionType;
  const Source({
    this.id,
    this.name,
    this.lang,
    this.hasUpdate,
    this.isNsfw,
    this.iconUrl,
    this.version,
    this.extensionType,
  });
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

// String extension stub
extension StringToIntExt on String {
  int toInt() => int.tryParse(this) ?? 0;
}

// DMedia extension mapper stub
extension DMediaMapper on DMedia {
  dynamic toCarouselData() => null;
}
STUBS

echo "✓ تم تحديث الـ stubs"
echo ""
echo "الآن:"
echo "  git add lib/stubs/extension_stubs.dart"
echo "  git commit -m 'fix: add missing Source fields and ExtensionType methods to stubs'"
echo "  git push origin main"
