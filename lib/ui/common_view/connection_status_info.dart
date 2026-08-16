import 'package:material_ui/material_ui.dart';
import 'package:netshare/config/styles.dart';

class ConnectionStatusInfo extends StatelessWidget {
  final bool isConnected;
  final String connectedIPAddress;

  const ConnectionStatusInfo({
    super.key,
    required this.isConnected,
    required this.connectedIPAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        isConnected
            ? const Icon(Icons.circle, size: 12.0, color: Colors.green)
            : const Icon(Icons.circle, size: 12.0, color: Colors.grey),
        const SizedBox(width: 6.0),
        Text(
          connectedIPAddress,
          style: CommonTextStyle.textStyleNormal.copyWith(color: textIconButtonColor),
        ),
      ],
    );
  }
}
