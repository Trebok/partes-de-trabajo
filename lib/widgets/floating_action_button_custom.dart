import 'package:flutter/material.dart';

class FloatingActionButtonCustom extends StatelessWidget {
  final void Function()? onPressed;
  const FloatingActionButtonCustom({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0097B2),
              Color(0xFF7ED957),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}
