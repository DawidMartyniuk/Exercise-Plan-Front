import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final Color color;
  final double thickness;
  final double height;
  final double verticalMargin;
  final double dashWidth;
  final double dashSpace;

  const CustomDivider({
    super.key,
    this.indent = 26,
    this.endIndent = 26,
    this.color = Colors.black,
    this.thickness = 2,
    this.height = 1,
    this.verticalMargin = 16,
    this.dashWidth = 8,
    this.dashSpace = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalMargin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - indent - endIndent;
          final dashCount = (width / (dashWidth + dashSpace)).floor();
          return Row(
            children: [
              SizedBox(width: indent),
              ...List.generate(dashCount, (index) {
                return Container(
                  width: dashWidth,
                  height: thickness,
                  color: color,
                  margin: EdgeInsets.only(
                    right: index == dashCount - 1 ? 0 : dashSpace,
                  ),
                );
              }),
              SizedBox(width: endIndent),
            ],
          );
        },
      ),
    );
  }
}