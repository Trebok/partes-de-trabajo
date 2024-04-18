import 'package:flutter/material.dart';

class TextFormFieldCustom extends StatelessWidget {
  final Widget? prefixIcon;
  final String? labelText;
  final Widget? suffixIcon;
  final InputBorder? border;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final void Function()? onTap;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;

  const TextFormFieldCustom({
    super.key,
    this.prefixIcon,
    this.labelText,
    this.suffixIcon,
    this.border,
    this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.readOnly = false,
    this.onTap,
    this.autovalidateMode,
    this.validator,
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
      maxLines: null,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      onTap: onTap,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onTapOutside: ((event) {
        FocusScope.of(context).unfocus();
      }),
    );
  }
}
