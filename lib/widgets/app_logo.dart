import 'package:flutter/material.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';
import '../widgets/eddie_logo.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withText;

  const AppLogo({
    Key? key,
    this.size = 32.0,
    this.withText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EddieLogo(
      size: size,
      withText: withText,
    );
  }
} 