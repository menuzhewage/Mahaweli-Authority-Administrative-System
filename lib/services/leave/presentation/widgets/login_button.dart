import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String value;
  final Future<void> Function() onPressed;

  const LoginButton({
    super.key,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF634682),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
