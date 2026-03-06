import 'dart:io';
import 'package:anymex/stubs/extension_stubs.dart';

import 'package:anymex/main.dart' show isar;
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageProvider {
  Future<bool> requestPermission() async {
    Permission permission = Permission.manageExternalStorage;
    if (Platform.isAndroid) {
      if (await permission.isGranted) {
        return true;
      } else {
        final result = await permission.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
        return false;
      }
    }
    return true;
  }

  Future<Directory?> getDatabaseDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return dir;
    } else {
      String dbDir = path.join(dir.path, 'AnymeX', 'databases');
      await Directory(dbDir).create(recursive: true);
      return Directory(dbDir);
    }
  }

  Future<Isar> initDB(String? path, {bool inspector = false}) async {
    Directory? dir;
    if (path == null) {
      dir = await getDatabaseDirectory();
    } else {
      dir = Directory(path);
    }

    isar = Isar.openSync(
      [
        // // // MSourceSchema,
        // // // SourcePreferenceSchema,
        // // // SourcePreferenceStringValueSchema,
        BridgeSettingsSchema
      ],
      directory: dir!.path,
      name: 'AnymeX',
      inspector: false,
    );

    return isar;
  }
}
