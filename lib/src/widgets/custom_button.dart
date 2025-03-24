import 'package:voyager/src/widgets/button_loading.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
    this.buttonText,
    this.nextPage,
    this.direction,
    this.bgColor,
    this.textColor,
    this.borderColor,
    this.prefixIcon,
    this.assetName = '',
    this.onPressed,
    this.isLoading = false,
  });
  final String? buttonText;
  final AxisDirection? direction;
  final Widget? nextPage;
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? prefixIcon;
  final String assetName;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 45,
            child: isLoading == false
                ? ElevatedButton(
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
                    child: Text(
                      buttonText ?? '',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ButtonLoading(bgColor: bgColor, textColor: textColor)));
  }
}
