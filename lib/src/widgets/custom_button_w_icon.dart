import 'package:voyager/src/widgets/button_loading.dart';
import 'package:flutter/material.dart';

class DefaultIconButton extends StatelessWidget {
  const DefaultIconButton({
    super.key,
    this.image,
    this.buttonText,
    this.direction,
    this.bgColor,
    this.textColor,
    this.borderColor,
    this.prefixIcon,
    this.onPressed,
    this.isLoading = false,
  });

  final String? image, buttonText;
  final AxisDirection? direction;
  final Color? bgColor, textColor, borderColor;
  final IconData? prefixIcon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(
              color: borderColor!,
              width: 1,
            ),
          ),
        ),
        icon: isLoading
            ? const SizedBox()
            : (image!.isNotEmpty
                ? Image(
                    image: AssetImage(image!),
                    width: 24,
                    height: 24,
                  )
                : (prefixIcon != null ? Icon(prefixIcon) : const SizedBox())),
        label: isLoading
            ? ButtonLoading(bgColor: bgColor, textColor: textColor)
            : Text(
                buttonText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
      ),
    );
  }
}
