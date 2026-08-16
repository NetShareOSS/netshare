import 'package:material_ui/material_ui.dart';
import 'package:netshare/config/styles.dart';

class EmptyWidget extends StatelessWidget {

  final String message;

  const EmptyWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ic_empty.png',
            color: Theme.of(context).colorScheme.secondary,
            width: 48.0,
            height: 48.0,
          ),
          Text(message, style: CommonTextStyle.textStyleNormal),
        ],
      )
    );
  }
}
