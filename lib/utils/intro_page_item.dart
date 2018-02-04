import 'package:cuacfm/utils/RadiocomColors.dart';
import 'package:cuacfm/utils/data.dart';
import 'package:cuacfm/utils/page_transformer.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class IntroPageItem extends StatelessWidget {
  IntroPageItem({
    @required this.item,
    @required this.pageVisibility,
  });

  final IntroItem item;
  final PageVisibility pageVisibility;

  @override
  Widget build(BuildContext context) {
    final image = new Image.network(
      item.imageUrl,
      fit: BoxFit.cover,
      alignment: new FractionalOffset(
        0.5 + (pageVisibility.pagePosition / 3),
        0.5,
      ),
    );

    final imageOverlayGradient = new DecoratedBox(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: FractionalOffset.bottomCenter,
          end: FractionalOffset.topCenter,
          colors: [
            const Color(0x00FFFFFF),
            const Color(0x33FFFFFF),
          ],
        ),
      ),
    );

    return new Container(color: RadiocomColors.white,child: new Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 8.0,
      ),
      child: new Material(
        elevation: 4.0,
        child: new Stack(
          fit: StackFit.expand,
          children: [
            image,
            imageOverlayGradient,
          ],
        ),
      ),
    ));
  }
}