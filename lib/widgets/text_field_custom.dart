import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  final Widget? prefixIcon;
  final String? labelText;
  final Widget? suffixIcon;
  final InputBorder? border;
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
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        labelText: labelText,
        suffixIcon: suffixIcon,
        border: border,
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
