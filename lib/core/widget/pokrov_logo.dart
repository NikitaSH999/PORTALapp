import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum PokrovLogoVariant {
  icon('assets/images/logo.svg'),
  withText('assets/images/logo_with_text.svg');

  const PokrovLogoVariant(this.assetName);

  final String assetName;
}

class PokrovLogo extends StatelessWidget {
  const PokrovLogo({
    super.key,
    this.variant = PokrovLogoVariant.icon,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  final PokrovLogoVariant variant;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      variant.assetName,
      width: width,
      height: height,
      fit: fit,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
