import 'package:flutter/material.dart';

/// Lets a [Column] with [Spacer]s fill the screen when it fits and scroll
/// when it does not (small phones, large text).
class FillScroll extends StatelessWidget {
  const FillScroll({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                constraints.maxHeight -
                (padding?.resolve(Directionality.of(context)).vertical ?? 0),
          ),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}
