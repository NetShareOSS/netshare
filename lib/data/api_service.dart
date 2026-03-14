import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/api_error.dart';
import 'package:netshare/entity/file_upload.dart';
import 'package:netshare/entity/shared_file_entity.dart';

class ApiService {
  String domain =
      'http://${getIt.get<GlobalScopeData>().connectedIPAddress}'; // http://ip:port

  void refreshDomain() {
    domain = 'http://${getIt.get<GlobalScopeData>().connectedIPAddress}';
  }

  Future<Either<ApiError, Set<SharedFile>>> getSharedFiles() async {
    refreshDomain();
    try {
      final endpoint = '$domain/files';
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final listRes = jsonDecode(response.body) as List;
        return Right(listRes.map((e) => SharedFile.fromJson(e)).toSet());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return const Left(ApiError.empty());
  }

  Future<Either<ApiError, List<SharedFile>>> uploadFile({
    required List<FileUpload> files,
    void Function(double progress)? onProgress,
  }) async {
    refreshDomain();
    final endpoint = '$domain/upload';
    final request = _MultipartRequestWithProgress(
      "POST",
      Uri.parse(endpoint),
      onProgress: (bytesSent, totalBytes) {
        if (totalBytes <= 0) {
          return;
        }
        onProgress?.call((bytesSent / totalBytes).clamp(0.0, 1.0));
      },
    );
    List<http.MultipartFile> newList = [];
    int totalFileBytes = 0;
    for (var file in files) {
      totalFileBytes += await File(file.path).length();
      newList.add(await http.MultipartFile.fromPath('files', file.path));
    }
    request.files.addAll(newList);
    request.headers['x-upload-total-bytes'] = totalFileBytes.toString();
    onProgress?.call(0.0);
    try {
      final response = await request.send();
      final resStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        onProgress?.call(1.0);
        final listRes = jsonDecode(resStr) as List;
        return Right(listRes.map((e) => SharedFile.fromJson(e)).toList());
      } else {
        return const Left(ApiError('Upload failed', 417));
      }
    } catch (e) {
      debugPrint(e.toString());
      return const Left(ApiError.unknown());
    }
  }
}

class _MultipartRequestWithProgress extends http.MultipartRequest {
  _MultipartRequestWithProgress(
    super.method,
    super.url, {
    required this.onProgress,
  });

  final void Function(int bytesSent, int totalBytes) onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final totalBytes = contentLength;
    int bytesSent = 0;
    return http.ByteStream(
      byteStream.transform(
        StreamTransformer.fromHandlers(
          handleData: (List<int> data, EventSink<List<int>> sink) {
            bytesSent += data.length;
            onProgress(bytesSent, totalBytes);
            sink.add(data);
          },
          handleDone: (EventSink<List<int>> sink) {
            onProgress(totalBytes, totalBytes);
            sink.close();
          },
        ),
      ),
    );
  }
}
