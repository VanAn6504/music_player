import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.audio,
    ].request();

    bool isStorageGranted = statuses[Permission.storage]?.isGranted ?? false;
    bool isAudioGranted = statuses[Permission.audio]?.isGranted ?? false;

    if (isStorageGranted || isAudioGranted) {
      return true;
    }

    if ((statuses[Permission.storage]?.isPermanentlyDenied ?? false) ||
        (statuses[Permission.audio]?.isPermanentlyDenied ?? false)) {
      await openAppSettings();
    }

    return false;
  }

  Future<bool> requestAudioPermission() async {
    return await requestStoragePermission();
  }

  Future<bool> hasPermissions() async {
    bool storagePermission = await Permission.storage.isGranted;
    bool audioPermission = await Permission.audio.isGranted;
    return storagePermission || audioPermission;
  }
}
