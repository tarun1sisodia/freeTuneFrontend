import 'package:flutter/material.dart';

class BasicAppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final double? textSize;
  final double? height;
  final FontWeight? weight;

  const BasicAppButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.textSize,
    this.height,
    this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(height ?? 80),
        backgroundColor: Colors.white, // Or primary color from Palette
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: textSize ?? 20,
          fontWeight: weight ?? FontWeight.bold,
          color: Colors.black, // Contrast color
        ),
      ),
    );
  }
}
