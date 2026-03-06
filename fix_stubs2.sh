#!/bin/bash
# fix_stubs2.sh — الإصلاح النهائي للـ stubs
cd ~/NyanTV

echo "=== 1. تحديث الـ stubs ==="
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

// ---- Source ----
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
  const Source({
    this.id,
    this.name,
    this.lang,
    this.hasUpdate,
    this.isNsfw,
    this.iconUrl,
    this.version,
    this.baseUrl,
    this.methods,
    this.extensionType,
  });
}

// ---- DMedia ----
class DMedia {
  final String? url;
  final String? title;
  final String? cover;
  final String? description;
  final String? genre;
  final ItemType? itemType;
  final List<dynamic> episodes;
  const DMedia({
    this.url,
    this.title,
    this.cover,
    this.description,
    this.genre,
    this.itemType,
    this.episodes = const [],
  });

  static DMedia fromJson(Map<String, dynamic> json) => DMedia(
    url: json['url'],
    title: json['title'],
    cover: json['cover'],
  );

  DMedia withUrl(String url) => DMedia(
    url: url,
    title: title,
    cover: cover,
    description: description,
    genre: genre,
    itemType: itemType,
    episodes: episodes,
  );
}

// ---- DEpisode ----
class DEpisode {
  final String? name;
  final String? url;
  final double? episodeNum;
  final int? episodeNumber;
  const DEpisode({this.name, this.url, this.episodeNum, this.episodeNumber});
}

// ---- Track ----
class Track {
  final String? url;
  final String? label;
  const Track({this.url, this.label});
}

// ---- SourcePreference ----
class SourcePreference {
  const SourcePreference();
}

// ---- Isar schema stubs ----
class MSourceSchema {}
class SourcePreferenceSchema {}
class SourcePreferenceStringValueSchema {}
class BridgeSettingsSchema {}

// ---- Extension manager stubs ----
class DartotsuExtensionBridge {
  DartotsuExtensionBridge([dynamic isar]);
  Future<void> init() async {}
}

class AniyomiExtensions {
  const AniyomiExtensions();
}

class MangayomiExtensions {
  const MangayomiExtensions();
}

// ---- DMedia extension mapper stub ----
extension DMediaMapper on DMedia {
  dynamic toCarouselData() => null;
}
STUBS

echo "✓ تم تحديث الـ stubs"

echo ""
echo "=== 2. حذف Video من الـ stubs لتجنب التعارض مع media_kit_video ==="
# Video موجود في media_kit_video و models/Offline/Hive/video.dart
# لا نحتاجه في الـ stubs

echo ""
echo "=== 3. إزالة StringToIntExt لتجنب التعارض مع StringExtensions ==="
# toInt موجود في string_extensions.dart، لا نضيفه مجدداً

echo "✓ اكتمل الإصلاح"
echo ""
echo "الخطوة التالية:"
echo "  git add lib/stubs/extension_stubs.dart"
echo "  git commit -m 'fix: complete stubs with all missing fields, remove conflicting Video and toInt'"
echo "  git push origin main"
