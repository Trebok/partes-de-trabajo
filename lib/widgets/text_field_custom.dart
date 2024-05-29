import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
  final Widget? prefixIcon;
  final String? labelText;
  final Widget? suffixIcon;
  final InputBorder? border;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const TextFieldCustom({
    super.key,
    this.prefixIcon,
    this.labelText,
    this.suffixIcon,
    this.border,
    this.controller,
    this.focusNode,
    this.maxLines,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
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
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      onTapOutside: onTapOutside,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}
