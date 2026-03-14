import 'package:dartz/dartz.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/data/hivedb/clients/shared_file_client.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/api_error.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/util/utility_functions.dart';

class FileRepository {
  final ApiService apiService;

  FileRepository(this.apiService);

  // 1. Fetch list file from remote server
  // 2. Update file state if it's downloaded before or existing on device storage
  Future<Either<ApiError, Set<SharedFile>>> getSharedFilesWithState() async {
    final originalFiles = await apiService.getSharedFiles();
    if (originalFiles.isLeft()) {
      return Left(originalFiles.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final originalFilesRight = originalFiles.getOrElse(() => {});

    // For the context why needs to update file's URL, see:
    // https://github.com/huynguyennovem/netshare/issues/47
    String connectedAddress = 'http://${getIt.get<GlobalScopeData>().connectedIPAddress}';

    final newFileList = await Future.wait(originalFilesRight.map((file) async {
      // check exist in Hive
      final savedAvailableFile = await getIt.get<SharedFileClient>().get(file.name);
      if (null == savedAvailableFile) {
        return file.copyWith(url: '$connectedAddress/${file.name}');
      }

      return await UtilityFunctions.isFileExists(savedAvailableFile.savedDir)
          ? savedAvailableFile.copyWith(url: '$connectedAddress/${file.name}')
          : file.copyWith(url: '$connectedAddress/${file.name}');
    }));
    return Right(newFileList.toSet());
  }
}
