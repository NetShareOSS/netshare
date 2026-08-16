import 'package:material_ui/material_ui.dart';

class TwoModeSwitcher extends StatefulWidget {
  final bool switchInitValue;
  final Text? leftValue;
  final Text? rightValue;
  final Function(bool)? onValueChanged;

  const TwoModeSwitcher({
    Key? key,
    this.switchInitValue = false,
    this.leftValue,
    this.rightValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<TwoModeSwitcher> createState() => TwoModeSwitcherState();
}

class TwoModeSwitcherState extends State<TwoModeSwitcher> {
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
    switchValue = widget.switchInitValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.leftValue ?? const SizedBox.shrink(),
        Switch(
          activeThumbImage: Image.asset('assets/images/server.png').image,
          inactiveThumbImage: Image.asset('assets/images/client.png').image,
          activeColor: Theme.of(context).colorScheme.primaryContainer,
          inactiveThumbColor: Theme.of(context).colorScheme.primaryContainer,
          trackColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.primaryContainer),
          trackOutlineColor: MaterialStatePropertyAll<Color>(Theme.of(context).colorScheme.primaryContainer),
          value: switchValue,
          onChanged: (bool value) {
            setState(() {
              switchValue = value;
            });
            widget.onValueChanged?.call(value);
          },
        ),
        widget.rightValue ?? const SizedBox.shrink(),
      ],
    );
  }

  void updateExternalValue(bool newValue) {
    setState(() {
      switchValue = newValue;
    });
  }
}
