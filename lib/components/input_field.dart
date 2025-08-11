import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

typedef OnValidation = dynamic Function(String? text);

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}

bool isValidEmail(String? email) {
  if (email == null || email.isEmpty) return false;
  return RegExp(r'^[A-Za-z0-9._%+-]*[A-Za-z]+[A-Za-z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
}


bool isValidPassword(String? password) {
  if (password == null || password.isEmpty) return false;
  return RegExp(r'^(?=.*[A-Za-z])(?=.*[!@#$%^&*(),.?":{}|<>]).+$').hasMatch(password);
}

bool isValidName(String? name) {
  if (name == null || name.isEmpty) return false;
  return RegExp(r"^[A-Z][a-zA-Z]+$").hasMatch(name);
}
class CommonTextField extends StatelessWidget {
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final String? hintText;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool? obscureText;
  final OnValidation? validator;
  final Function(String?)? onChange;
  final Function(String?)? onFieldSubmitted;
  final Function()? onEditingComplete;
  final Function()? onTap;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int? maxLine;
  final int? maxLength;
  final bool readOnly;
  final bool? enable;
  final Color? bgColor;
  final Color? cColor;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextAlign? textAlign;
  final TextStyle? style;

  const CommonTextField({
    super.key,
    this.enable,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.bgColor,
    this.cColor,
    this.maxLength,
    this.onTap,
    this.hintText = "",
    this.focusNode,
    this.onEditingComplete,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.validator,
    this.onChange,
    this.inputFormatters,
    this.textInputAction,
    this.keyboardType,
    this.maxLine,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: style ?? const TextStyle().normal14w500.textColor(AppColor.black12Color),
      autofillHints: autofillHints,
      autocorrect: true,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      onTap: onTap,
      onEditingComplete: () {},
      maxLength: maxLength,
      textAlign: textAlign ?? TextAlign.center,
      cursorColor: cColor ?? AppColor.black12Color,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      inputFormatters: inputFormatters,
      focusNode: focusNode ?? FocusNode(),
      textCapitalization: textCapitalization,
      obscureText: obscureText!,
      maxLines: maxLine ?? 1,

      textInputAction: textInputAction ?? TextInputAction.next,
      keyboardType: keyboardType ?? TextInputType.name,
      onChanged: (val) {
        if (onChange != null) {
          onChange!(val);
        }
      },
      validator: (val) {
        if (validator != null) {
          return validator!(val);
        } else {
          return null;
        }
      },
      enabled: enable ?? true,
      decoration: InputDecoration(
        errorMaxLines: 2,
        fillColor: bgColor ?? AppColor.greyF6Color,
        filled: true,
        counterText: "",
        // isDense: true,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColor.redColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColor.redColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColor.greyF6Color,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColor.black12Color,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorStyle: const TextStyle().normal15w500.textColor(AppColor.redColor),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle().normal14w500.textColor(AppColor.grey6EColor),
        suffixIconConstraints: const BoxConstraints(
          minHeight: 24,
          maxHeight: 24,
          maxWidth: 46,
          minWidth: 46,
        ),
      ),
    );
  }
}

class NoSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.contains(' ')) {
      return oldValue;
    }
    return newValue;
  }
}

class CapitalizedTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String capitalizedText = newValue.text[0].toUpperCase() + newValue.text.substring(1);

    return newValue.copyWith(
      text: capitalizedText,
      selection: TextSelection.collapsed(offset: capitalizedText.length),
    );
  }
}
