import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/data/pref_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/ui/common_view/address_field_widget.dart';
import 'package:netshare/util/extension.dart';
import 'package:provider/provider.dart';


class ConnectWidget extends StatefulWidget {
  const ConnectWidget({Key? key, required this.onConnected}) : super(key: key);

  final Function onConnected;

  @override
  State<ConnectWidget> createState() => _ConnectWidgetState();
}

class _ConnectWidgetState extends State<ConnectWidget> {
  Future? _connectedIPFuture;
  StreamSubscription? _connectedIPSubscription;

  final _ipTextController = TextEditingController();
  final _portTextController = TextEditingController(text: '8080');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final lastAddress = await getIt.get<PrefData>().getLastConnectedAddress();
      if(lastAddress != null && lastAddress.isNotEmpty) {
        final addresses = lastAddress.split(':');
        _ipTextController.text = addresses[0];
        _portTextController.text = addresses[1];
        return;
      }
      // get current IP if there is no saved address
      final deviceIP = getIt.get<GlobalScopeData>().currentDeviceIPAddress;
      if (deviceIP.isNotEmpty) {
        _ipTextController.text = deviceIP.substring(0, 8);  // remove last ip block, for eg: 192.168.1.
      }
    });
  }

  @override
  void dispose() {
    _ipTextController.dispose();
    _portTextController.dispose();
    _connectedIPSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: _buildMainLayout(),
    );
  }

  _buildMainLayout() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Manual connect',
                style: CommonTextStyle.textStyleNormal,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: AddressFieldWidget(
                ipTextController: _ipTextController,
                portTextController: _portTextController,
                backgroundColor: textFieldBackgroundColor,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 24.0),
                FloatingActionButton.extended(
                  onPressed: () => _onClickConnect(
                    ipAddress: _ipTextController.text,
                    port: int.parse(_portTextController.text),
                  ),
                  icon: const Icon(Icons.router_outlined, color: textIconButtonColor),
                  label: Text(
                    'Connect',
                    style: CommonTextStyle.textStyleNormal.copyWith(color: textIconButtonColor),
                  ),
                ),
                const SizedBox(width: 8.0),
                FutureBuilder(
                  future: _connectedIPFuture,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        );
                      default:
                        return const SizedBox(
                          width: 16.0,
                          height: 16.0,
                        );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  _onClickConnect({required String ipAddress, required int port}) {
    debugPrint('[ConnectWidget] Connecting to $ipAddress:$port');

    // dismissing keyboard while connecting
    FocusScope.of(context).unfocus();

    _connectedIPSubscription?.cancel();
    try {
      _connectedIPFuture = Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5))
          .catchError((error) {
        if (mounted) {
          context.showSnackbar('Failed to connect!');
        }
        throw error;
      });
    } catch (e) {
      debugPrint('[ConnectWidget] ${e.toString()}');
    }
    _connectedIPSubscription = _connectedIPFuture?.asStream().listen((socket) {
      debugPrint('[ConnectWidget] Connected to $ipAddress:$port');
      if (mounted) {
        context
            .read<ConnectionProvider>()
            .updateConnectedIPAddress(newIpAddress: '$ipAddress:$port');
        context
            .read<ConnectionProvider>()
            .updateConnectionStatus(newStatus: ConnectionStatus.connected);
      }
      socket.destroy();
      widget.onConnected.call();
    });
  }
}
