import 'package:material_ui/material_ui.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width / 3,
      ),
      child: const ListTile(
        leading: Icon(Icons.warning_rounded, color: Colors.yellow),
        title: Text('Something was wrong'),
      ),
    );
  }
}
