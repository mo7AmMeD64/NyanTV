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

// Track stub
class Track {
  final String? url;
  final String? label;
  const Track({this.url, this.label});
});
}
