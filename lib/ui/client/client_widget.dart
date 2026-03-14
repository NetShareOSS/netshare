import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/provider/app_provider.dart';
import 'package:netshare/repository/file_repository.dart';
import 'package:netshare/service/download_service.dart';
import 'package:netshare/data/hivedb/clients/shared_file_client.dart';
import 'package:netshare/entity/connection_status.dart';
import 'package:netshare/entity/download/download_state.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/ui/client/connect_widget.dart';
import 'package:netshare/ui/client/navigation_widget.dart';
import 'package:netshare/ui/common_view/connection_status_info.dart';
import 'package:netshare/ui/common_view/two_modes_switcher.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:provider/provider.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/list_file/list_shared_files_widget.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/entity/function_mode.dart';

class ClientWidget extends StatefulWidget {
  const ClientWidget({super.key});

  @override
  State<ClientWidget> createState() => _ClientWidgetState();
}

class _ClientWidgetState extends State<ClientWidget> {

  final fileRepository = getIt.get<FileRepository>();

  late TwoModeSwitcher _twoModeSwitcher;
  final GlobalKey<TwoModeSwitcherState> _twoModeSwitcherKey = GlobalKey<TwoModeSwitcherState>();

  @override
  void initState() {
    super.initState();
    // always fetch list files when first open Home screen
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final files = (await fileRepository.getSharedFilesWithState()).getOrElse(() => {});
      if (mounted) {
        context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
        context.read<AppProvider>().updateAppMode(appMode: FunctionMode.client);
      }
    });
    _downloadStreamListener();
    _initSwitcher();
  }

  void _downloadStreamListener() {
    getIt.get<DownloadService>().downloadStream.listen((downloadEntity) {
      debugPrint("[DownloadService] Download stream log: $downloadEntity");

      // update state to the list files
      if (mounted) {
        context.read<FileProvider>().updateFile(
          fileName: downloadEntity.fileName,
          newFileState: downloadEntity.state.toSharedFileState,
          savedDir: downloadEntity.savedDir,
          progress: downloadEntity.state == DownloadState.downloading
              ? downloadEntity.progress
              : null,
        );
      }

      // add succeed file to Hive database
      if (downloadEntity.state == DownloadState.succeed) {
        getIt.get<SharedFileClient>().add(
              SharedFile(
                name: downloadEntity.fileName,
                url: downloadEntity.url,
                savedDir: downloadEntity.savedDir,
                state: DownloadState.succeed.toSharedFileState,
              ),
            );
      }
    });
  }

  void _initSwitcher() {
    _twoModeSwitcher = TwoModeSwitcher(
      key: _twoModeSwitcherKey,
      switchInitValue: false,
      onValueChanged: (mode) => context.switchingModes(
        newMode: mode == true ? FunctionMode.server : FunctionMode.client,
        confirmCallback: (isUserAgreed) {
          if(isUserAgreed) {
            _disconnect();
            // force using goNamed instead of pushName, due to:
            // Client and Server widget are sibling widgets, not descendants
            // Need replacing to target route, not adding
            context.goNamed(mServerPath);
          } else {
            _twoModeSwitcherKey.currentState?.updateExternalValue(false);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('Disconnected Client!');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(builder: (BuildContext ct, value, Widget? child) {
      final connectionStatus = value.connectionStatus;
      final connectedIPAddress = value.connectedIPAddress;
      final isConnected = connectionStatus == ConnectionStatus.connected;
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: !Platform.isIOS ? _twoModeSwitcher : const SizedBox.shrink(),
          actions: [
            ConnectionStatusInfo(
              isConnected: isConnected,
              connectedIPAddress: connectedIPAddress,
            ),
            isConnected
                ? IconButton(
                    onPressed: () {
                      _disconnect();
                    },
                    icon: const Icon(Icons.link_off),
                  )
                : IconButton(
                    onPressed: () => _onClickManualButton(),
                    icon: const Icon(Icons.link),
                  ),
          ],
        ),
        body: Column(
          children: [
            NavigationWidgets(connectionStatus: connectionStatus),
            const Expanded(child: ListSharedFiles()),
            isConnected ? const SizedBox.shrink() : _buildConnectOptions(),
          ],
        ),
      );
    });
  }

  _buildConnectOptions() => Container(
    margin: const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UtilityFunctions.isMobile
                ? Row(
                    children: [
                      FloatingActionButton.extended(
                        heroTag: const Text("Scan"),
                        onPressed: () => _onClickScanButton(),
                        label: Text(
                          'Scan to connect',
                          style: CommonTextStyle.textStyleNormal.copyWith(
                            color: textIconButtonColor,
                            fontSize: 14.0,
                          ),
                        ),
                        icon: const Icon(Icons.qr_code_scanner, color: textIconButtonColor),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  )
                : const SizedBox.shrink(),
            Flexible(
              child: FloatingActionButton.extended(
                heroTag: const Text("Manual"),
                onPressed: () => _onClickManualButton(),
                label: Text(
                  'Manual connect',
                  style: CommonTextStyle.textStyleNormal.copyWith(
                    color: textIconButtonColor,
                    fontSize: 14.0,
                  ),
                ),
                icon: const Icon(Icons.account_tree, color: textIconButtonColor),
              ),
            ),
          ],
        ),
  );

  _onClickScanButton() async {
    final isPermissionGranted = await UtilityFunctions.checkCameraPermission(
      onPermanentlyDenied: () => context.showOpenSettingsDialog(),
    );
    if(isPermissionGranted) {
      if(mounted) {
        final result = await context.pushNamed<bool>(mScanningPath);
        if(result == true) {
          _syncFiles();
        }
      }
    } else {
      if (mounted) {
        context.showSnackbar('Need Camera permission to continue');
      }
    }
  }

  _onClickManualButton() {
    if(UtilityFunctions.isDesktop) {
      showDialog(
        context: context,
        builder: (bsContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 2,
                maxHeight: MediaQuery.of(context).size.height / 2,
              ),
              child: ConnectWidget(onConnected: () async {
                Navigator.pop(context);
                _syncFiles();
              }),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (bsContext) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ConnectWidget(onConnected: () async {
              Navigator.pop(context);
              _syncFiles();
            }),
          );
        },
      );
    }
  }

  _disconnect() {
    context.read<ConnectionProvider>().disconnect();
    context.read<FileProvider>().clearAllFiles();
  }

  _syncFiles() async {
    final files = (await fileRepository.getSharedFilesWithState()).getOrElse(() => {});
    if (mounted) {
    context.read<FileProvider>().addAllSharedFiles(sharedFiles: files);
    }
  }
}
