import 'package:flutter/material.dart';

class TextFormFieldCustom extends StatelessWidget {
  final Widget? prefixIcon;
  final String? labelText;
  final Widget? suffixIcon;
  final InputBorder? border;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final void Function()? onTap;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const TextFormFieldCustom({
    super.key,
    this.prefixIcon,
    this.labelText,
    this.suffixIcon,
    this.border,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.readOnly = false,
    this.onTap,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        labelText: labelText,
        suffixIcon: suffixIcon,
        border: border,
      ),
      controller: controller,
      focusNode: focusNode,
      maxLines: null,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      onTap: onTap,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}
