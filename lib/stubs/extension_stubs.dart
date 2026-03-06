// lib/stubs/extension_stubs.dart
// Stubs لاستبدال dartotsu_extension_bridge - لا وظيفة حقيقية
enum ExtensionType { aniyomi, mangayomi }

class Source {
  final String name;
  final String id;
  final ExtensionType extensionType;
  const Source({
    this.name = '',
    this.id = '',
    this.extensionType = ExtensionType.aniyomi,
  });
}

class AniyomiExtensions {}
class MangayomiExtensions {}
