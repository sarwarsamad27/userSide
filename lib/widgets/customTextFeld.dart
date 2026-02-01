import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:user_side/resources/appColor.dart';

class CustomTextField extends StatefulWidget {
  final String? headerText;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final double? height;
  final bool? readOnly;

  /// ✅ validation
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final AutovalidateMode autovalidateMode;

  const CustomTextField({
    super.key,
    this.headerText,
    this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.readOnly,
    this.height,
    this.validator,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.readOnly == true) {
      _focusNode = AlwaysDisabledFocusNode();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return FormField<String>(
      initialValue: controller?.text ?? "",
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (state) {
        final hasError = state.errorText != null && state.errorText!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.headerText ?? '').isNotEmpty) ...[
              Text(
                widget.headerText ?? '',
                style: TextStyle(
                  color: AppColor.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 6.h),
            ],

            /// ✅ Field Container
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: hasError ? Colors.red : AppColor.primaryColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                focusNode: _focusNode,
                readOnly: widget.readOnly ?? false,
                controller: controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.isPassword ? obscure : false,
                expands: widget.height != null,
                maxLines: widget.height != null ? null : 1,
                minLines: widget.height != null ? null : 1,
                style: TextStyle(
                  color: AppColor.textPrimaryColor,
                  fontSize: 15.sp,
                ),
                onChanged: (v) {
                  state.didChange(v); // ✅ update form state
                  widget.onChanged?.call(v);
                },
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColor.textSecondaryColor.withOpacity(0.7),
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,

                  prefixIcon: widget.prefixIcon != null
                      ? Icon(widget.prefixIcon, color: AppColor.primaryColor)
                      : null,

                  suffixIcon: widget.isPassword
                      ? IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColor.primaryColor,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            /// ✅ Error text OUTSIDE the container
            if (hasError) ...[
              SizedBox(height: 6.h),
              Text(
                state.errorText!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                  height: 1.2,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
