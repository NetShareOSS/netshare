import 'package:flutter/material.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/entity/download/download_state.dart';
import 'package:netshare/entity/file_upload.dart';
import 'package:netshare/entity/function_mode.dart';
import 'package:netshare/entity/internal_error.dart';
import 'package:netshare/entity/message_role.dart';
import 'package:netshare/entity/message_state.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/shared_file_state.dart';
import 'package:netshare/ui/common_view/confirm_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

extension ContextExt on BuildContext {
  void showSnackbar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      duration: duration ?? const Duration(seconds: 1),
      content: Text(message),
    ));
  }

  void handleInternalError({
    required InternalError internalError,
    bool shouldShowSnackbar = false,
  }) {
    debugPrint(internalError.message);
    if (shouldShowSnackbar) {
      showSnackbar(internalError.message);
    }
  }

  void switchingModes({
    required FunctionMode newMode,
    Function(bool)? confirmCallback,
  }) {
    showDialog(
      barrierDismissible: false,
      context: this,
      builder: (BuildContext ct) {
        return ConfirmDialog(
          dialogWidth: MediaQuery.of(this).size.width / 2,
          header: Text(
            'Switching to ${newMode.name}',
            style: Theme.of(ct).textTheme.headlineMedium?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          body: const Text(
            'Are you sure you want to switch to this mode?',
            textAlign: TextAlign.center,
          ),
          cancelButtonTitle: 'No',
          okButtonTitle: 'Yes, I\'m sure',
          onCancel: () => confirmCallback?.call(false),
          onConfirm: () => confirmCallback?.call(true),
        );
      },
    );
  }

  showOpenSettingsDialog() {
    showDialog(
      barrierDismissible: false,
      context: this,
      builder: (BuildContext context) {
        return ConfirmDialog(
          header: Text(
            'Open Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          body: const Text(
            'You need to grant permission from app\'s Settings',
            textAlign: TextAlign.center,
          ),
          onConfirm: () => openAppSettings(),
        );
      },
    );
  }
}

extension SharedFileExt on SharedFile {
  IconData get fileIcon {
    if (null == name) {
      return Icons.question_mark;
    }
    String ext;
    try {
      ext = p.extension(name!);
    } catch (e) {
      ext = '';
    }
    if (ext.isEmpty) return Icons.question_mark;
    final extension = p.extension(name!).substring(1).trim().toLowerCase();
    switch (extension) {
      case mTxt:
        return Icons.text_fields;
      case mPdf:
        return Icons.picture_as_pdf_outlined;
      case mMp4:
      case mAvi:
      case mMov:
        return Icons.video_collection_outlined;
      case mMp3:
      case mWav:
        return Icons.audio_file_outlined;
      case mSvg:
      case mPng:
      case mJpg:
      case mJpeg:
      case mBmp:
      case mWebp:
        return Icons.image_outlined;
      case mGif:
        return Icons.gif;
      case mDoc:
      case mDocX:
        return Icons.text_snippet_outlined;
      case mPpt:
      case mPptX:
        return Icons.slideshow;
      case mXls:
      case mXlsx:
        return Icons.table_chart;
      case mZip:
      case mRar:
        return Icons.folder_zip_outlined;
      case mExe:
        return Icons.data_object_sharp;
      case mApk:
      case mAab:
        return Icons.android;
      case mDmg:
        return Icons.phone_iphone;
    }
    return Icons.question_mark;
  }
}

extension DownloadStateExt on DownloadState {
  SharedFileState get toSharedFileState {
    switch (this) {
      case DownloadState.downloading:
        return SharedFileState.downloading;
      case DownloadState.succeed:
        return SharedFileState.available;
      default:
        return SharedFileState.none;
    }
  }
}

extension TimeFormat on Duration {
  String formatTime() => '$this'.split('.')[0].padLeft(8, '0');
}

extension XFileExtension on XFile {
  FileUpload get toFileUpload {
    return FileUpload(path);
  }
}

extension MessageStateExtension on MessageState {
  static const valueMap = {
    MessageState.sending: "sending",
    MessageState.sent: "sent",
    MessageState.error: "error",
  };

  String? get value => valueMap[this];

  static MessageState fromString(String input) {
    final valueMapEntries =
        valueMap.map<String, MessageState>((key, value) => MapEntry(value, key));
    MessageState? output = valueMapEntries[input];
    if (output == null) {
      throw 'Invalid Input';
    }
    return output;
  }
}

extension MessageRoleExtension on MessageRole {
  static const valueMap = {
    MessageRole.client: "client",
    MessageRole.server: "server",
  };

  String? get value => valueMap[this];

  static MessageRole fromString(String input) {
    final valueMapEntries =
        valueMap.map<String, MessageRole>((key, value) => MapEntry(value, key));
    MessageRole? output = valueMapEntries[input];
    if (output == null) {
      throw 'Invalid Input';
    }
    return output;
  }
}

extension FunctionModeExtension on FunctionMode {
  MessageRole toMessageRole() {
    switch(this) {
      case FunctionMode.server:
        return MessageRole.server;
      default:
        return MessageRole.client;
    }
  }
}
