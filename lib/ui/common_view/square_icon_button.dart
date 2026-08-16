import 'package:material_ui/material_ui.dart';

class SquareIconButton extends StatelessWidget {

  final Function onPressed;
  final IconData icon;

  const SquareIconButton({Key? key, required this.onPressed, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () => onPressed.call(),
        child: Icon(icon, color: Colors.white, size: 20.0),
      ),
    );
  }
}
