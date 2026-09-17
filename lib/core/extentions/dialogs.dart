import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';
import 'package:lottie/lottie.dart';

enum DialogType { error, success, warning }

dynamic showMyDialog(
  BuildContext context,
  String message, {
  DialogType type = DialogType.error,
}) 

{
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: type == DialogType.error
          ? const Color.fromARGB(255, 173, 2, 33)
          : type == DialogType.warning
          ? Colors.orange
          : AppColors.primaryColor,
      content: Text(message),
    ),
  );
}

dynamic  showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Lottie.asset("assets/images/loading.json", width: 250)],
      ),
    ),
  );
}
