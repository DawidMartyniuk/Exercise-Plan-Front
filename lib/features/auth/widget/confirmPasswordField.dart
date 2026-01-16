import "package:flutter/material.dart";
import "password_field.dart";

class ConfirmPasswordField extends StatelessWidget {
  final TextEditingController confirmPasswordController;
  final TextEditingController originalPasswordController;
  final bool isEnabled;
  final bool isPasswordVisible;
  final VoidCallback togglePasswordVisibility;
  final Key? fieldKey;

  const ConfirmPasswordField({
    super.key,
    required this.confirmPasswordController,
    required this.originalPasswordController,
    required this.togglePasswordVisibility,
    this.isEnabled = true,
    this.isPasswordVisible = false,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return PasswordField(
      passwordController: confirmPasswordController,
      togglePasswordVisibility: togglePasswordVisibility,
      isEnabled: isEnabled,
      isPasswordVisible: isPasswordVisible,
      labelText: "Confirm Password",
      confirmController: originalPasswordController,
      fieldKey: fieldKey,
      isRequired: true,
    );
  }
}
