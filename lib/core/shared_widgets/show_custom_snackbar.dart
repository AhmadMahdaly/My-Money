import 'package:opration/features/intro/my_app.dart';

void showCustomSnackBar({
  String? message,
  bool? isError,
}) {
  GlobalVariable.showMessage(message ?? '', isError: isError ?? false);
}
