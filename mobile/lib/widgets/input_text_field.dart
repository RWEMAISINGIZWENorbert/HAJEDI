import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:store_app_bloc/utils/thousands_formatter.dart';

class InputTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final bool? redaOnly;
  final bool? formatNumber;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;

  const InputTextField(
      {super.key,
      required this.labelText,
      required this.hintText,
      this.obscureText = false,
      this.redaOnly = false,
      this.formatNumber = false,
      this.controller,
      this.keyboardType,
      this.focusNode,
      this.onChanged,
      this.prefix});

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Focus(
      focusNode: widget.focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return MouseRegion(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: hasFocus
                      ? Colors.grey
                      : Theme.of(context).secondaryHeaderColor,
                  width: hasFocus ? 3.0 : 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  readOnly: widget.redaOnly ?? false,
                  focusNode: widget.focusNode,
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText && !_isPasswordVisible,
                  onChanged: widget.onChanged,
                  cursorColor: Theme.of(context).primaryColor,
                  inputFormatters: widget.formatNumber == true ? <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        // ThousandsFormatter(),
                     ] : null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    // labelText: labelText,
                    hintText: widget.hintText,
                    // hoverColor: colorScheme.primary.withOpacity(0.1),
                    prefixIcon: widget.prefix,
                    suffixIcon: widget.obscureText
                        ? IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context).hintColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
