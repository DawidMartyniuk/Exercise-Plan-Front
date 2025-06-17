import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final Color color;
  final double thickness;
  final double height;
  final double verticalMargin;

  const CustomDivider({
    super.key,
    this.indent = 26,
    this.endIndent = 26,
    this.color = Colors.black,
    this.thickness = 2,
    this.height = 1,
    this.verticalMargin = 16, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalMargin),
      child: Divider(
        color: color,
        thickness: thickness,
        height: height,
        indent: indent,
        endIndent: endIndent,
      ),
    );
  }
}