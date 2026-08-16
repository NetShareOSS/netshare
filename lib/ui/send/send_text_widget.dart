import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/entity/file_upload.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/ui/common_view/connection_status_info.dart';
import 'package:netshare/util/extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SendTextWidget extends StatefulWidget {
  const SendTextWidget({super.key});

  @override
  State<SendTextWidget> createState() => _SendTextWidgetState();
}

class _SendTextWidgetState extends State<SendTextWidget> {
  final _textController = TextEditingController();
  final ValueNotifier<bool> _isCreating = ValueNotifier(false);

  @override
  void dispose() {
    _textController.dispose();
    _isCreating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder:
          (BuildContext context, ConnectionProvider connection, Widget? child) {
        final connectionStatus = connection.connectionStatus;
        final connectedIPAddress = connection.connectedIPAddress;
        final isConnected = connectionStatus == ConnectionStatus.connected;
        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            appBar: AppBar(
              elevation: 4.0,
              title: isConnected
                  ? ConnectionStatusInfo(
                      isConnected: isConnected,
                      connectedIPAddress: connectedIPAddress,
                    )
                  : Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Send Text',
                        style: CommonTextStyle.textStyleAppbar,
                      ),
                    ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: _buildTextInputArea(),
                ),
                _buildCreateButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your message',
            style: CommonTextStyle.textStyleNormal.copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Type your message here...',
                  border: InputBorder.none,
                ),
                style: CommonTextStyle.textStyleNormal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      width: double.infinity,
      child: ValueListenableBuilder(
        valueListenable: _isCreating,
        builder: (context, isCreating, child) {
          return FloatingActionButton.extended(
            onPressed: isCreating ? null : () => _createFileAndNavigate(),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create File & Send',
                  style: CommonTextStyle.textStyleNormal.copyWith(
                    fontSize: 14.0,
                    color: textIconButtonColor,
                  ),
                ),
                const SizedBox(width: 8.0),
                if (isCreating)
                  const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: textIconButtonColor,
                    ),
                  ),
              ],
            ),
            icon: const Icon(Icons.create, color: textIconButtonColor),
          );
        },
      ),
    );
  }

  Future<void> _createFileAndNavigate() async {
    if (_textController.text.trim().isEmpty) {
      context.showSnackbar('Please enter some text');
      return;
    }

    _isCreating.value = true;

    try {
      // Create a temporary file with the text content.
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'message_$timestamp.txt';
      final file = File('${directory.path}/$fileName');

      // Write the text content to the file.
      await file.writeAsString(_textController.text.trim());

      // Navigate to SendWidget with the created file.
      if (mounted) {
        final fileUpload = FileUpload(file.path);
        await context.pushNamed(mSendFilesPath, extra: fileUpload);

        // Clear the text field after successful navigation.
        _textController.clear();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackbar('Failed to create file: $e');
      }
    } finally {
      _isCreating.value = false;
    }
  }
}
