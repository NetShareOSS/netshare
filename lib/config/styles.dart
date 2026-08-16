import 'package:material_ui/material_ui.dart';

const seedColor = Color(0xFF78909C);
const backgroundColor = Color(0xFFF5F5F5);
const textIconButtonColor = Color(0xFF546E7A);
const textIconButtonColorActivated = Color(0xFFFFFFFF);
const disabledButtonColor = Color(0xFFB0BEC5);
const textFieldBackgroundColor = Color(0xFFEEEEEE);

class CommonTextStyle {
  static const textStyleNormal = TextStyle(
    color: textIconButtonColor,
    fontSize: 16.0,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
  );

  static const textStyleAppbar = TextStyle(
    color: textIconButtonColor,
    fontSize: 20.0,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
  );
}

class CommonButtonStyle {
  static final buttonStyleNormal = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.blue),
      ),
    ),
  );
}
