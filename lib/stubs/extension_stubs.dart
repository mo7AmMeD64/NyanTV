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
