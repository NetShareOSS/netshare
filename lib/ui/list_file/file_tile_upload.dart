import 'package:material_ui/material_ui.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/ui/common_view/conditional_parent_widget.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';

class FileTileUpload extends StatefulWidget {
  final SharedFile sharedFile;
  final Function? onRemoveItem;

  const FileTileUpload({
    Key? key,
    required this.sharedFile,
    this.onRemoveItem,
  }) : super(key: key);

  @override
  State<FileTileUpload> createState() => _FileTileUploadState();
}

class _FileTileUploadState extends State<FileTileUpload> {
  final hoveringState = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: UtilityFunctions.isDesktop,
      rightParent: ({child}) => MouseRegion(
        onEnter: (event) => hoveringState.value = true,
        onExit: (event) => hoveringState.value = false,
        child: child ?? const SizedBox.shrink(),
      ),
      leftParent: ({child}) => Dismissible(
        direction: DismissDirection.endToStart,
        key: Key(widget.sharedFile.name ?? ''),
        onDismissed: (direction) {
          widget.onRemoveItem?.call();
          context.showSnackbar('${widget.sharedFile.name} is removed');
        },
        background: Container(
          color: Colors.redAccent,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Remove',
            style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      child: _buildChild(),
    );
  }

  _buildChild() => Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    child: Row(
      children: [
        Icon(widget.sharedFile.fileIcon, color: Theme.of(context).colorScheme.secondary),
        _buildFileInfo(),
        _buildRemoveButton(),
      ],
    ),
  );

  _buildFileInfo() => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        widget.sharedFile.name ?? 'unknown',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );

  _buildRemoveButton() {
    if (UtilityFunctions.isMobile) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder(
      valueListenable: hoveringState,
      builder: (context, state, child) {
        if (!state) return const SizedBox.shrink();
        return InkWell(
          customBorder: const CircleBorder(),
          onTap: () => widget.onRemoveItem?.call(),
          child: const Icon(
            Icons.remove_circle,
            color: Colors.redAccent,
            size: 20.0,
          ),
        );
      },
    );
  }
}
