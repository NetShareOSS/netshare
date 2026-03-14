import 'package:flutter/cupertino.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/shared_file_state.dart';

class FileProvider extends ChangeNotifier {
  final List<SharedFile> _files = [];
  List<SharedFile> get files => _files;

  final Map<String, double> _progressMap = {};

  double getProgress(String fileName) => _progressMap[fileName] ?? 0.0;

  void addSharedFile({required SharedFile sharedFile}) {
    _files.add(sharedFile);
    notifyListeners();
  }

  void addAllSharedFiles({required Set<SharedFile> sharedFiles, bool isAppending = false}) {
    if(!isAppending) {
      _files.clear();
    }
    _files.addAll(sharedFiles);
    notifyListeners();
  }

  void clearAllFiles() {
    _files.clear();
    _progressMap.clear();
    notifyListeners();
  }

  void updateFile({
    required String fileName,
    required SharedFileState newFileState,
    required String savedDir,
    double? progress,
  }) {
    if(_files.isEmpty) return;
    final oldFile = _files.firstWhere((file) => fileName.trim() == file.name?.trim());
    final oldIndex = _files.indexOf(oldFile);
    final updatedFile = oldFile.copyWith(state: newFileState, savedDir: savedDir);
    _files[oldIndex] = updatedFile;
    if (progress != null) {
      _progressMap[fileName] = progress;
    } else {
      _progressMap.remove(fileName);
    }
    notifyListeners();
  }
}
