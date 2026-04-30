
import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:injector/injector.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CustomImage extends StatefulWidget {
  CustomImage(
      {this.resPath,
      this.fit,
      this.width, this.height,
      required this.radius, this.background = true,
      this.backgroundColor,
      this.alignment = Alignment.center});

  final String? resPath;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final double radius;
  final bool background;
  final Color? backgroundColor;
  final Alignment alignment;
  @override
  State<StatefulWidget> createState() => CustomImageState();
}

class CustomImageState extends State<CustomImage> {
  late RadiocomColorsConract _colors;
  @override
  Widget build(BuildContext context) {
    _colors = Injector.appInstance.get<RadiocomColorsConract>();
    var customImage;
    final isDefaultRadioco = widget.resPath != null &&
        widget.resPath!.contains("default-programme-photo");
    if (widget.resPath == null) {
      customImage = new Icon(Icons.warning);
    } else if (isDefaultRadioco) {
      customImage = Image.asset(
        "assets/graphics/default_programme_cover.png",
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        alignment: widget.alignment,
      );
    } else if (widget.resPath!.contains("http")) {
      customImage = new CachedNetworkImage(
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          imageUrl: widget.resPath!,
          alignment: widget.alignment,
          placeholder: (context, url) => JumpingDotsProgressIndicator(
                numberOfDots: 3,
                color: _colors.white,
                fontSize: 20.0,
                dotSpacing: 5.0
              ),
          errorWidget: (context, url, error) => new Icon(Icons.error));
    } else if (widget.resPath!.isNotEmpty) {
      customImage = Image.asset(
        widget.resPath!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        alignment: widget.alignment,
      );
    } else {
      customImage = new Icon(Icons.warning);
    }
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: widget.backgroundColor ?? (widget.background?_colors.blackgradient65:_colors.transparent)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: customImage));
  }
}
