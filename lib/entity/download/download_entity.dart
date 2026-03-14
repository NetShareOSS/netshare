import 'package:equatable/equatable.dart';
import 'package:netshare/entity/download/download_state.dart';

class DownloadEntity extends Equatable {
  final String fileName;
  final String url;
  final String savedDir;
  final DownloadState state;
  final double progress;

  const DownloadEntity(
    this.fileName,
    this.url,
    this.savedDir,
    this.state, {
    this.progress = 0.0,
  });

  DownloadEntity copyWith({
    String? fileName,
    String? url,
    String? savedDir,
    DownloadState? state,
    double? progress,
  }) =>
      DownloadEntity(
        fileName ?? this.fileName,
        url ?? this.url,
        savedDir ?? this.savedDir,
        state ?? this.state,
        progress: progress ?? this.progress,
      );

  @override
  List<Object> get props => [fileName, url, savedDir, state, progress];
}
