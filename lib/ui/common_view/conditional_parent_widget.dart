import 'package:material_ui/material_ui.dart';

class ConditionalParentWidget extends StatelessWidget {
  final bool condition;
  final Widget Function({Widget? child}) leftParent;
  final Widget Function({Widget? child}) rightParent;
  final Widget child;

  const ConditionalParentWidget({
    Key? key,
    required this.condition,
    required this.leftParent,
    required this.rightParent,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return condition ? rightParent(child: child) : leftParent(child: child);
  }
}
