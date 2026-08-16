import 'package:material_ui/material_ui.dart';

class ConfirmDialog extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Function? onCancel;
  final Function onConfirm;
  final String? cancelButtonTitle;
  final String? okButtonTitle;
  final double? dialogWidth;
  final double? dialogHeight;

  const ConfirmDialog({
    Key? key,
    required this.header,
    required this.body,
    this.onCancel,
    required this.onConfirm,
    this.cancelButtonTitle,
    this.okButtonTitle,
    this.dialogWidth,
    this.dialogHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: header),
                IconButton(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: body,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(cancelButtonTitle ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onConfirm.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(okButtonTitle ?? 'OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
