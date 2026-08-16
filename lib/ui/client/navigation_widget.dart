import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/connection_status.dart';

class NavigationWidgets extends StatefulWidget {
  final ConnectionStatus connectionStatus;

  const NavigationWidgets({Key? key, required this.connectionStatus})
      : super(key: key);

  @override
  State<NavigationWidgets> createState() => _NavigationWidgetsState();
}

class _NavigationWidgetsState extends State<NavigationWidgets> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Builder(builder: (context) {
            final isConnected =
                widget.connectionStatus == ConnectionStatus.connected;
            return FloatingActionButton.extended(
              backgroundColor: isConnected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : disabledButtonColor,
              heroTag: const Text('Send files'),
              onPressed: () => _onClickSend(),
              icon: Icon(Icons.send,
                  color: isConnected
                      ? textIconButtonColor
                      : textIconButtonColorActivated),
              label: Text(
                'Send files',
                style: CommonTextStyle.textStyleNormal.copyWith(
                  color: isConnected
                      ? textIconButtonColor
                      : textIconButtonColorActivated,
                ),
              ),
            );
          }),
          Builder(builder: (context) {
            final isConnected =
                widget.connectionStatus == ConnectionStatus.connected;
            return FloatingActionButton.extended(
              backgroundColor: isConnected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : disabledButtonColor,
              heroTag: const Text('Send text'),
              onPressed: () => _onClickShareText(),
              icon: Icon(Icons.chat_bubble,
                  color: isConnected
                      ? textIconButtonColor
                      : textIconButtonColorActivated),
              label: Text(
                'Share text',
                style: CommonTextStyle.textStyleNormal.copyWith(
                  color: isConnected
                      ? textIconButtonColor
                      : textIconButtonColorActivated,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _onClickSend() {
    if (widget.connectionStatus != ConnectionStatus.connected) return;
    context.pushNamed(mSendFilesPath);
  }

  void _onClickShareText() {
    if (widget.connectionStatus != ConnectionStatus.connected) return;
    context.pushNamed(mSendTextPath);
  }
}
