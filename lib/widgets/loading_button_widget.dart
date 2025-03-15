import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      icon:
          isLoading
              ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(strokeWidth: 3),
              )
              : icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
      label: Text(label),
    );
  }
}
