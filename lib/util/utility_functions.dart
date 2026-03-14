import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_saver_ffi/file_saver_ffi.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class UtilityFunctions {
  static String getRoutePath({required String name}) => '/$name';

  static Future<String?> getIPAddress() async {
    return NetworkInfo().getWifiIP();
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static void shareText(String text) {
    Share.share(text, subject: 'Share by NetShare');
  }

  static Future<bool> checkStoragePermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    final status = await Permission.storage.status;
    switch (status) {
      case PermissionStatus.granted:
        onGranted?.call();
        return true;
      case PermissionStatus.permanentlyDenied:
        onPermanentlyDenied?.call();
        return false;
      default:
        {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted:
              onGranted?.call();
              return true;
            case PermissionStatus.permanentlyDenied:
              onPermanentlyDenied?.call();
              return false;
            default:
              onDenied?.call();
              return false;
          }
        }
    }
  }

  static Future<bool> checkCameraPermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    final status = await Permission.camera.status;
    switch (status) {
      case PermissionStatus.granted:
        onGranted?.call();
        return true;
      case PermissionStatus.permanentlyDenied:
        onPermanentlyDenied?.call();
        return false;
      default:
        {
          final requested = await Permission.camera.request();
          switch (requested) {
            case PermissionStatus.granted:
              onGranted?.call();
              return true;
            case PermissionStatus.permanentlyDenied:
              onPermanentlyDenied?.call();
              return false;
            default:
              onDenied?.call();
              return false;
          }
        }
    }
  }

  static Future<bool> checkManageExternalStoragePermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    final status = await Permission.manageExternalStorage.status;
    switch (status) {
      case PermissionStatus.granted:
        onGranted?.call();
        return true;
      case PermissionStatus.permanentlyDenied:
        onPermanentlyDenied?.call();
        return false;
      default:
        {
          final requested = await Permission.manageExternalStorage.request();
          switch (requested) {
            case PermissionStatus.granted:
              onGranted?.call();
              return true;
            case PermissionStatus.permanentlyDenied:
              onPermanentlyDenied?.call();
              return false;
            default:
              onDenied?.call();
              return false;
          }
        }
    }
  }

  static Future<int> get androidSDKVersion async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt;
  }

  static Future<bool> get isNeedGrantStoragePermission async {
    if (!Platform.isAndroid) {
      return false;
    }
    final sdkVersion = await androidSDKVersion;
    return 28 >= sdkVersion;
  }

  static Future<bool> get isNeedAccessAllFileStoragePermission async {
    if (!Platform.isAndroid) {
      return false;
    }
    final sdkVersion = await androidSDKVersion;
    return 30 <= sdkVersion;
  }

  /// Parse ip (v4) address with [rawInput] which has format:
  /// ip:port (eg: 192.168.0.100:8080)
  static Tuple2<String, int> parseIPAddress(String rawInput) {
    void error(String msg) {
      throw FormatException('Illegal IPv4 address, $msg');
    }

    if (rawInput.isEmpty || !rawInput.contains(':')) {
      error('IP is empty or wrong input format');
    }

    final addressParts = rawInput.split(':');
    final ip = addressParts[0];
    final port = addressParts[1];

    final ipBlocks = ip.split('.');
    if (ipBlocks.length != 4) {
      error('IP address should contain exactly 4 parts');
    }
    for (var e in ipBlocks) {
      int? byte = int.tryParse(e);
      if (null == byte) {
        error('one of IP part is not an integer');
      }
      if (byte! < 0 || byte > 255) {
        error('each part must be in the range of `0..255`');
      }
    }
    int? intPort = int.tryParse(port);
    if (null == intPort) {
      error('port is not an integer');
    }
    return Tuple2(ip, intPort!);
  }

    static Future<bool> isFileExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;

    final uri = Uri.tryParse(filePath);
    if (uri == null) return false;

    return await FileSaver.canOpenFile(uri);
  }
}
