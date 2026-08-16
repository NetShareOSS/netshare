import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart' as dartz;
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRWidget extends StatefulWidget {
  const ScanQRWidget({Key? key}) : super(key: key);

  @override
  State<ScanQRWidget> createState() => _ScanQRWidgetState();
}

class _ScanQRWidgetState extends State<ScanQRWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final qrScanResult = ValueNotifier('');
  late final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  Future? _connectedIPFuture;
  StreamSubscription? _connectedIPSubscription;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.stop();
    } else if (Platform.isIOS) {
      controller.start();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    qrScanResult.dispose();
    _connectedIPSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan to connect',
          style: CommonTextStyle.textStyleAppbar,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: MobileScanner(
                        controller: controller,
                        onDetect: _onBarcodeScanned,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: seedColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: qrScanResult,
                        builder: (context, value, child) {
                          return Text(
                            'Detected result: ${value.isEmpty ? 'None' : value}',
                            textAlign: TextAlign.start,
                            style: CommonTextStyle.textStyleNormal.copyWith(
                              fontSize: 18.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 24.0),
                FloatingActionButton.extended(
                  onPressed: () => _onClickConnect(),
                  icon: const Icon(Icons.router_outlined,
                      color: textIconButtonColor),
                  label: Text(
                    'Connect',
                    style: CommonTextStyle.textStyleNormal
                        .copyWith(color: textIconButtonColor),
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
          ],
        ),
      ),
    );
  }

  void _onBarcodeScanned(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        qrScanResult.value = code;
      }
    }
  }

  _onClickConnect() {
    final address = qrScanResult.value;
    dartz.Tuple2<String, int> parsedAddress;
    try {
      parsedAddress = UtilityFunctions.parseIPAddress(address);
    } catch (e) {
      debugPrint(e.toString());
      return;
    }
    final ipAddress = parsedAddress.value1;
    final port = parsedAddress.value2;

    debugPrint('Connecting to $ipAddress:$port');

    _connectedIPSubscription?.cancel();
    try {
      _connectedIPFuture =
          Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5))
              .catchError((error) {
        if (mounted) {
          context.showSnackbar('Failed to connect!');
        }
        throw error;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    _connectedIPSubscription = _connectedIPFuture?.asStream().listen((socket) {
      debugPrint('Connected to $ipAddress:$port');
      if (mounted) {
        context
            .read<ConnectionProvider>()
            .updateConnectedIPAddress(newIpAddress: '$ipAddress:$port');
        context
            .read<ConnectionProvider>()
            .updateConnectionStatus(newStatus: ConnectionStatus.connected);
      }
      socket.destroy();

      if (mounted && context.canPop()) {
        context.pop(true);
      }
    });
  }
}
