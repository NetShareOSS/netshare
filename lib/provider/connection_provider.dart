
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/data/pref_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/connection_status.dart';

class ConnectionProvider extends ChangeNotifier {
  ConnectionStatus _connectionStatus = ConnectionStatus.idle;
  ConnectionStatus get connectionStatus => _connectionStatus;

  String _connectedIPAddress = '';
  String get connectedIPAddress => _connectedIPAddress;

  void updateConnectionStatus({required ConnectionStatus newStatus}) {
    _connectionStatus = newStatus;
    getIt.get<GlobalScopeData>().updateConnectionStatus(newStatus: newStatus);
    notifyListeners();
  }

  void updateConnectedIPAddress({required String newIpAddress}) {
    _connectedIPAddress = newIpAddress;
    getIt.get<GlobalScopeData>().updateConnectedIPAddress(newIpAddress: newIpAddress);
    getIt.get<PrefData>().saveLastConnectedAddress(newIpAddress);
    notifyListeners();
  }

  void disconnect() {
    _connectedIPAddress = '';
    _connectionStatus = ConnectionStatus.idle;
    getIt.get<GlobalScopeData>().resetAllData();
    notifyListeners();
  }
}