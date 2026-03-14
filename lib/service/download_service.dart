import 'dart:async';
import 'dart:io';

import 'package:file_saver_ffi/file_saver_ffi.dart';
import 'package:mime/mime.dart';
import 'package:netshare/entity/download/download_entity.dart';
import 'package:netshare/entity/download/download_state.dart';
import 'package:netshare/entity/internal_error.dart';
import 'package:path/path.dart' as path;

class DownloadService {
  StreamController downloadStreamController =
      StreamController<DownloadEntity>.broadcast();

  Stream<DownloadEntity> get downloadStream =>
      downloadStreamController.stream as Stream<DownloadEntity>;

  void disposeStream() {
    downloadStreamController.close();
  }

  void updateDownloadState(DownloadEntity downloadEntity) {
    downloadStreamController.sink.add(downloadEntity);
  }

  void startDownloading(String fileUrl, {Function(InternalError)? onError}) {
    final encodedUrl = Uri.encodeFull(fileUrl);
    final rawFileName = path.basename(fileUrl);
    final ext = path.extension(rawFileName).replaceFirst('.', '');
    final baseName = path.basenameWithoutExtension(rawFileName);
    final mimeType = lookupMimeType(rawFileName) ?? 'application/octet-stream';
    final fileType = CustomFileType(ext: ext, mimeType: mimeType);

    final initial =
        DownloadEntity(rawFileName, fileUrl, '', DownloadState.downloading);
    updateDownloadState(initial);

    FileSaver.save(
      input: SaveInput.network(url: encodedUrl),
      fileName: baseName,
      fileType: fileType,
      // for iOS, it will automatically save to app's document directory, so no need to add subDir
      subDir: Platform.isIOS ?  null : 'NetShare',
    ).listen(
      (event) {
        switch (event) {
          case SaveProgressUpdate(:final progress):
            updateDownloadState(initial.copyWith(progress: progress));
          case SaveProgressComplete(:final uri):
            updateDownloadState(initial.copyWith(
              savedDir: uri.toString(),
              state: DownloadState.succeed,
            ));
          case SaveProgressError():
            updateDownloadState(initial.copyWith(state: DownloadState.failed));
          default:
            break;
        }
      },
      onError: (_) =>
          updateDownloadState(initial.copyWith(state: DownloadState.failed)),
    );
  }
}
