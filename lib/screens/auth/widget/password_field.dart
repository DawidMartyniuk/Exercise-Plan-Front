import "package:flutter/material.dart";

class PasswordField extends StatelessWidget {
  final TextEditingController passwordController;
  final bool isEnabled;
  final bool isPasswordVisible;
  final VoidCallback togglePasswordVisibility;
  final String labelText;
  final bool isNewPassword;
  final String? confirmPassword;
  final bool isRequired;

  const PasswordField({
    super.key,
    required this.passwordController,
    required this.togglePasswordVisibility,
    this.isEnabled = true,
    this.isPasswordVisible = false,
    this.labelText = "Password",
    this.isNewPassword = false,
    this.confirmPassword, 
    this.isRequired = true, // ✅ DOMYŚLNIE TRUE - STĄD GWIAZDKI
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.visiblePassword,
      controller: passwordController,
      enabled: isEnabled,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        prefixIcon: Icon(
          labelText.toLowerCase().contains('confirm') 
              ? Icons.lock_outline 
              : Icons.lock,
          color: isEnabled
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey,
        ),
        // ✅ TUTAJ JEST PROBLEM - ZAWSZE DODAJE GWIAZDKĘ JEŚLI isRequired = true
        labelText: isRequired ? "$labelText" : labelText,
        suffixIcon: IconButton(
          onPressed: isEnabled ? togglePasswordVisibility : null,
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: isEnabled
                ? Theme.of(context).colorScheme.onSurface
                : Colors.grey,
          ),
        ),
        labelStyle: TextStyle(
          color: isEnabled
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey,
        ),
        filled: true,
        fillColor: isEnabled
            ? Theme.of(context).colorScheme.surface
            : Colors.grey.withAlpha(50),
      ),
      style: TextStyle(
        color: isEnabled
            ? Theme.of(context).colorScheme.onSurface
            : Colors.grey,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter ${labelText.toLowerCase()}';
        }

        if (!isRequired && (value == null || value.isEmpty)) {
          return null;
        }

        if (value!.length < 6) {
          return '${labelText} must be at least 6 characters long';
        }

        if (isNewPassword) {
          final hasUpperCase = value.contains(RegExp(r'[A-Z]'));
          final hasLowerCase = value.contains(RegExp(r'[a-z]'));
          final hasDigit = value.contains(RegExp(r'\d'));

          if (!hasUpperCase) {
            return '${labelText} must contain at least one uppercase letter';
          }
          if (!hasLowerCase) {
            return '${labelText} must contain at least one lowercase letter';
          }
          if (!hasDigit) {
            return '${labelText} must contain at least one number';
          }
        } else {
          final containsUpperCase = value.contains(RegExp(r'[A-Z]'));
          if (!containsUpperCase) {
            return '${labelText} must contain at least one uppercase letter';
          }
        }

        if (confirmPassword != null && value != confirmPassword) {
          return 'Passwords do not match';
        }

        return null;
      },
      obscureText: !isPasswordVisible,
    );
  }
}
