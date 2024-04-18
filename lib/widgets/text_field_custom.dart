import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  final Widget? prefixIcon;
  final String? labelText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final void Function()? onTap;

  const TextFieldCustom({
    super.key,
    this.prefixIcon,
    this.labelText,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        labelText: labelText,
        suffixIcon: suffixIcon,
      ),
      controller: controller,
      maxLines: null,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      onTap: onTap,
      onTapOutside: ((event) {
        FocusScope.of(context).unfocus();
      }),
    );
  }
}
