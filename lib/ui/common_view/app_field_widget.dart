import 'package:material_ui/material_ui.dart';

class AppFieldWidget extends StatelessWidget {
  final TextEditingController textController;
  final Color? backgroundColor;

  const AppFieldWidget({
    Key? key,
    required this.textController,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(6.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        hintText: 'Enter text here',
        hintStyle: const TextStyle(color: Colors.black26),
        filled: backgroundColor != null,
        fillColor: backgroundColor,

      ),
    );
  }
}
