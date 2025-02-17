import 'package:flutter/material.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_pane.dart';

class TableLayout extends StatelessWidget 
{
  final Widget pageHeader;  // 表头
  final Widget pageBody;    // 表体

  final TablePane tablePane;    // 表格部件
  final double    minHeight;    // 高度
  
  const TableLayout({
    super.key, 
    required this.pageHeader, 
    required this.pageBody,
    required this.tablePane,

    required this.minHeight
  });

  

  /// get header 内容
  /// @return Widget
  Widget _pageHeader(BuildContext context)
  {
    return Container
    (
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration
      (
        border: Border(bottom: BorderSide(width: 1, color: Theme.of(context).dividerTheme.color!))
      ),
      child: Row
      (
        children: 
        [
          Container
          (
            alignment: Alignment.centerLeft,
            width: 15,
            height: minHeight,
            decoration: BoxDecoration
            (
              border: Border(right: BorderSide(color: Theme.of(context).dividerTheme.color!, width: 1.5))
            ),
            child: const SizedBox(),
          ),
          Expanded(child: pageHeader)
        ]
      ),
    );
  }

  /// 获取 body 内容
  /// @return Widget
  Widget _pageBody(BuildContext context)
  {
    return Row(children: 
    [
      Container
      (
        width: 15,
        decoration: BoxDecoration
        (
          border: Border(right: BorderSide(color: Theme.of(context).dividerTheme.color!, width: 1.5))
        ),
        child: tablePane,
      ),

      Expanded(child: pageBody)
    ]);
  }


  @override
  Widget build(BuildContext context) 
  {
    return SizedBox
    (
      child: Column
      (
        children: 
        [
          /// 表头
         _pageHeader(context),

          /// 表体
          Expanded
          (
            child: _pageBody(context)
          )
        ],
      ),
    );
  }
}