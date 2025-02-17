import 'dart:math';

import 'package:flutter/material.dart';

class TableScrollLayout extends StatelessWidget 
{
  final ScrollController pageBodyHorizontalController; 
  final ScrollController pageBodyVerticalController;

  final double space; // 右边距

  final Widget child;
  final double minWidth; // 最小宽度

  const TableScrollLayout({
    super.key, 
    required this.child, 
    required this.space,
    required this.pageBodyHorizontalController, 
    required this.pageBodyVerticalController, 
    this.minWidth = 0
  });

  @override
  Widget build(BuildContext context) 
  {
    return Scrollbar
    (
      thumbVisibility: true,
      trackVisibility: true,
      controller: pageBodyVerticalController,
      notificationPredicate: (notification) => notification.depth == 1,

      key: const Key('vertical_scroll'),

      child: LayoutBuilder(builder:(context, constraints) 
      {
        double maxWidth = constraints.maxWidth;
        double maxHeight = constraints.maxHeight;
        
        return Scrollbar
        (
          key: const Key('horizontal_scroll'),
          thumbVisibility: true,
          trackVisibility: true,
          controller: pageBodyHorizontalController,
          child: SingleChildScrollView
          (
            controller: pageBodyHorizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox
            (
              width: max(maxWidth, minWidth + space),
              height: maxHeight,
              child: child
            ),
          ),
        );
      })
    );
  }
}