import 'package:material_ui/material_ui.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/repository/file_repository.dart';
import 'package:netshare/ui/common_view/empty_widget.dart';
import 'package:netshare/ui/common_view/square_icon_button.dart';
import 'package:netshare/ui/list_file/file_tile_client.dart';
import 'package:provider/provider.dart';

const filesActionButtonSize = 36.0;

class ListSharedFiles extends StatefulWidget {
  const ListSharedFiles({super.key});

  @override
  State<ListSharedFiles> createState() => _ListSharedFilesState();
}

class _ListSharedFilesState extends State<ListSharedFiles> {

  final fileRepository = getIt.get<FileRepository>();
  final mainListScrollController = ScrollController();
  final searchController = SearchController();

  @override
  void dispose() {
    super.dispose();
    mainListScrollController.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(
      builder: (context, value, child) {
        final files = value.files;
        debugPrint('[ListSharedFiles] Fetched files: ${files.length}');
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              files.isNotEmpty ? _buildHeader(files) : const SizedBox.shrink(),
              Flexible(
                child: files.isNotEmpty
                    ? _buildListFiles(files)
                    : const EmptyWidget(message: 'No file found'),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildListFiles(files) => Container(
    margin: const EdgeInsets.all(16.0),
    child: Scrollbar(
      controller: mainListScrollController,
      thumbVisibility: false,
      child: Material(
        color: seedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        child: ListView.separated(
          controller: mainListScrollController,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return FileTileClient(sharedFile: files.elementAt(index));
          },
          separatorBuilder: (context, index) {
            return Divider(
              color: Colors.black12.withAlpha(20),
              height: 0.2,
              indent: 8.0,
              endIndent: 8.0,
              thickness: 0.5,
            );
          },
          itemCount: files.length,
        ),
      ),
    ),
  );

  _buildHeader(files) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildHeaderSearch(files),
      _buildHeaderReload(),
    ],
  );

  _buildHeaderSearch(List<SharedFile> files) {
    return Container(
      width: filesActionButtonSize,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SearchAnchor(
        searchController: searchController,
        viewHintText: 'Enter file name',
        builder: (BuildContext context, SearchController controller) {
          return SquareIconButton(
            icon: Icons.search,
            onPressed: () => controller.openView(),
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          return _genArrayFileTile(files, files);
        },
        viewShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        viewBuilder: (suggestions) {
          if(searchController.text.trim().isEmpty) {
            return ListView(
              children: suggestions.toList(),
            );
          }
          final filteredFiles = files.where((f) {
            return f.name!.toLowerCase().contains(searchController.text.toLowerCase());
          }).toList();
          return ListView(
            children: _genArrayFileTile(files, filteredFiles),
          );
        },
      ),
    );
  }

  _genArrayFileTile(List<SharedFile> oldFiles, List<SharedFile> filteredFiles) =>
      List<FileTileClient>.generate(filteredFiles.length, (int index) {
        return FileTileClient(
          sharedFile: filteredFiles.elementAt(index),
          enableFunctionality: false,
          onPressed: () {
            final oldIndex = oldFiles.indexWhere((f) => f.name == filteredFiles.elementAt(index).name);
            final contentSize = mainListScrollController.position.viewportDimension +
                mainListScrollController.position.maxScrollExtent;
            final target = contentSize * oldIndex / oldFiles.length;
            searchController.closeView(null);
            mainListScrollController.position.animateTo(
              target,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          },
        );
      });

  _buildHeaderReload() {
    return Row(
      children: [
        const Text('Recent files'),
        Container(
          width: filesActionButtonSize,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SquareIconButton(
            icon: Icons.sync,
            onPressed: () async {
              final files = (await fileRepository.getSharedFilesWithState()).getOrElse(() => {});
              if (mounted) {
                context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
              }
            },
          ),
        ),
      ],
    );
  }
}
