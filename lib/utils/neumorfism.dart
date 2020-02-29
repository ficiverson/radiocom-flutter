import 'package:cuacfm/utils/radiocom_colors.dart';
import 'package:flutter/material.dart';

import 'custom_image.dart';

Color mC = Colors.grey.shade100;
Color mCL = Colors.white;
Color mCD = Colors.black.withOpacity(0.075);
Color mCC = Colors.lightGreenAccent.withOpacity(0.65);
Color fCD = Colors.grey.shade700;
Color fCL = Colors.grey;

BoxDecoration nMbox = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: mC,
    boxShadow: [
      BoxShadow(
        color: mCD,
        offset: Offset(10, 10),
        blurRadius: 10,
      ),
      BoxShadow(
        color: mCL,
        offset: Offset(-10, -10),
        blurRadius: 10,
      ),
    ]);

BoxDecoration nMboxInvert = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: mCD,
    boxShadow: [
      BoxShadow(
          color: mCL, offset: Offset(3, 3), blurRadius: 3, spreadRadius: -3),
    ]);

BoxDecoration nMboxInvertActive = nMboxInvert.copyWith(color: mCC);

BoxDecoration nMbtn = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: mC,
    boxShadow: [
      BoxShadow(
        color: mCD,
        offset: Offset(2, 2),
        blurRadius: 2,
      )
    ]);

class NMVIew extends StatelessWidget {
  final Widget child;
  final bool isFullScreen;
  const NMVIew({this.child, this.isFullScreen = false});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isFullScreen ? 0 : 25),
            color: mC,
            boxShadow: [
              BoxShadow(
                color: mCD,
                offset: Offset(2, 2),
                blurRadius: 2,
              ),
              BoxShadow(
                color: isFullScreen ? RadiocomColors.transparent : mCL,
                offset: Offset(-2, -2),
                blurRadius: 2,
              ),
            ]),
        child: child);
  }
}

class NMButton extends StatelessWidget {
  final bool down;
  final IconData icon;
  const NMButton({this.down, this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: down ? nMboxInvert : nMbox,
      child: Icon(
        icon,
        color: down ? RadiocomColors.yellow : fCL,
      ),
    );
  }
}

class NMCardVertical extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final String image;
  final bool imageOverLay;
  final String subtitle;
  const NMCardVertical(
      {this.active,
      this.icon,
      this.label,
      this.image,
      this.subtitle,
      this.imageOverLay = false});
  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    List<Widget> elements = [];
    Widget imageContent =
        CustomImage(resPath: image, fit: BoxFit.fitHeight, radius: 15.0);
    if (imageOverLay) {
      imageContent = Stack(fit: StackFit.passthrough, children: <Widget>[
        ShaderMask(
            shaderCallback: (Rect bounds) {
              return RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: <Color>[RadiocomColors.yellow, RadiocomColors.orange],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child:CustomImage(resPath: image, fit: BoxFit.fitHeight, radius: 15.0)),
         Center(child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: RadiocomColors.fontWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 24),
            )),
      ]);
    }
    elements.add(Container(
        foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: RadiocomColors.transparent),
        decoration: nMbox,
        width: imageOverLay ? 260.0 : 170.0,
        height: imageOverLay ? 180.0 : 170.0,
        child: imageContent));
    if (!imageOverLay) {
      elements.add(SizedBox(width: 15, height: 10.0));
      elements.add(Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: TextStyle(
            color: RadiocomColors.font,
            fontWeight: FontWeight.w700,
            fontSize: 15),
      ));
      elements.add(Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: TextStyle(
            color: RadiocomColors.font,
            fontWeight: FontWeight.w400,
            fontSize: 14),
      ));
      elements.add(Spacer());
    }
    return Container(
      height: imageOverLay ? 200.0 : 250.0,
      width: imageOverLay ? 260.0 :queryData.size.width * 0.42,
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: elements),
    );
  }
}

class NMCardHorizontal extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final String image;
  final double size;
  final VoidCallback onElementClicked;
  const NMCardHorizontal(
      {this.active, this.icon, this.label, this.image, this.size,this.onElementClicked});
  @override
  Widget build(BuildContext context) {
    _onElementClicked() {
      if(onElementClicked !=null){
        onElementClicked();
      }
    }
    Widget iconCard = Icon(icon, color: RadiocomColors.yellow, size: 40.0);
    if (image != null) {
      iconCard = new Container(
          width: 60.0,
          height: 60.0,
          child:
              CustomImage(resPath: image, fit: BoxFit.fitHeight, radius: 15.0));
    }
    return GestureDetector(child: Container(
      height: size == null ? 80.0 : size,
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: nMbox,
      child: Row(
        children: <Widget>[
          iconCard,
          SizedBox(width: 15),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: size == null
                  ? TextStyle(
                  color: RadiocomColors.font,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)
                  : TextStyle(
                  wordSpacing: 3.0,
                  color: RadiocomColors.font,
                  fontWeight: FontWeight.w700,
                  fontSize: 20)),
          Spacer(),
          image != null
              ? Icon(Icons.keyboard_arrow_right,
              color: RadiocomColors.yellow, size: 40.0)
              : Spacer(),
        ],
      ),
    ),onTap: (){
      _onElementClicked();
    });
  }
}
