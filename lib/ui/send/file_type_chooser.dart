import 'package:material_ui/material_ui.dart';
import 'package:netshare/config/styles.dart';

class FileTypeChooser extends StatefulWidget {
  const FileTypeChooser({super.key, required this.onSelectedType});
  final Function(int) onSelectedType;

  @override
  State<FileTypeChooser> createState() => _FileTypeChooserState();
}

class _FileTypeChooserState extends State<FileTypeChooser> {
  int _fileType = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select source',
            style: CommonTextStyle.textStyleNormal,
          ),
          RadioListTile(
            title: const Row(
              children: [
                Icon(Icons.perm_media),
                SizedBox(width: 8.0),
                Text('Media'),
              ],
            ),
            value: 0,
            groupValue: _fileType,
            onChanged: (value) {
              setState(() {
                _fileType = value ?? 0;
              });
            },
          ),
          RadioListTile(
            title: const Row(
              children: [
                Icon(Icons.file_copy_rounded),
                SizedBox(width: 8.0),
                Text('File'),
              ],
            ),
            value: 1,
            groupValue: _fileType,
            onChanged: (value) {
              setState(() {
                _fileType = value ?? 1;
              });
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: FloatingActionButton.extended(
              onPressed: () => widget.onSelectedType.call(_fileType),
              label: Text(
                '   Select   ',
                style: CommonTextStyle.textStyleNormal.copyWith(color: textIconButtonColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
