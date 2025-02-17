import 'package:flutter/material.dart';
import 'package:latest/utils/theme/accent_colour.dart';
import 'package:latest/widgets/data_display/data_table/entity/entity_model.dart';
import 'package:latest/widgets/data_display/data_table/entity/page_table_header.dart';


class T extends StatefulWidget 
{
  final String title;
  final String subtitle;
  final String datatype;

  final Color color;

  final Function(bool isDropload)? dropload;
  final Border border;


  const T({
    super.key, 
    required this.title, 
    required this.subtitle, 
    required this.datatype, 
    required this.color, 
    required this.dropload,
    required this.border,

  });

  @override
  State<T> createState() => _TState();
}

class _TState extends State<T> 
{
  bool _isHover = false;

  /// 构建下拉按钮
  /// @param key 按钮的key值
  /// @return 返回下拉按钮
  Widget _buildDroploadButton({required String key})
  {
    return MouseRegion
    (
      onEnter: (event)=> widget.dropload!(true),
      onExit: (event) => widget.dropload!(false),
      cursor: SystemMouseCursors.click,
      child: const Icon(Icons.arrow_drop_down, size: 18)
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return MouseRegion
    (
      onEnter:(event) => setState(() => _isHover = true),
      onExit: (event) => setState(() => _isHover = false),
      child: Container
      (
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
        decoration: BoxDecoration
        (
          color: widget.color,
          border: widget.border,
        ),
        width: double.infinity,
        child: Column
        (
          children: 
          [
            Row(
              children: [
                Expanded
                (
                  child: SizedBox
                  (
                    child:  Text
                    (
                      widget.title, 
                      style: Theme.of(context).textTheme.labelMedium, 
                      overflow: TextOverflow.ellipsis
                    )
                  )
                ),
                
                _isHover ? _buildDroploadButton(key: widget.title) : const SizedBox(width: 18, height: 18,),
              ]
            )
          ],
        )
      )
    );
  }
}

class TableHeader extends StatefulWidget 
{
  final PageTableHeader header;
  final double space;
  final ScrollController controller;
  final double minHeight;

  /// 构建上下文菜单
  final void Function(String key, TapUpDetails details) contextMenuBuilder;
  final Function(String key) onSelect;

  const TableHeader({
    super.key, 
    required this.header, 
    required this.space, 
    required this.controller, 
    required this.minHeight,
    required this.contextMenuBuilder,

    required this.onSelect,
  });

  @override
  State<TableHeader> createState() => _TableHeaderState();
}

class _TableHeaderState extends State<TableHeader> 
{
  bool isDropload = false; // 是否正在下拉菜单选择


  @override
  void initState() 
  {
    widget.header.addListener(_rebuild);
    super.initState();
  }

  void _rebuild() 
  {
    setState(() {});
  }

  /// 构建事件
  /// @param bool key
  /// @param Widget? child
  /// @return Widget
  Widget _buildEvents({required String key, Widget? child})
  {
    return GestureDetector
    (
      onSecondaryTapUp: (details) 
      {
        widget.contextMenuBuilder(key, details);
      },
      onTapDown: (details) 
      {
        if (isDropload) return;

        widget.header.entityModel.setKey(key);
        widget.onSelect(key);
        _rebuild();
      },
      child: child,
    );
  }
  /// 构建表头
  /// @return List<Widget>
  List<Widget> _buildCeils({
    required Color color,
    required Color highlight,
    required Color undertint
  }) 
  {
    List<Widget> ceils  = [];
    int length          = widget.header.entityModel.sortedColumns.length;
    List<String> keys   = widget.header.entityModel.sortedColumns;
    int index           = 0;
    String k         = widget.header.entityModel.key;
    
    for (int i = 0; i < length; i++) 
    {
      String key = keys[i];

      EntityColumn column = widget.header.entityModel.columns[key]!;

      Widget ceil = ReorderableDelayedDragStartListener
      (
        key: ValueKey("$i"), 
        index: index,
        child: _buildEvents
        (
          key: key, 
          child: SizedBox
          (
            width: widget.header.entityModel.getWidth(key: key),
            child: T
            (
              title: key, 
              subtitle: column.comment, 
              datatype: column.type, 
              color: key == k ? highlight : widget.header.entityModel.batchKeys.contains(key) ? undertint : color,
              dropload: (isDropload) {
                this.isDropload = isDropload;
              },
              border: Border
              (
                right: BorderSide
                (
                  width: 1, 
                  color: widget.header.entityModel.batchKeys.contains(key) ?  Colors.white : Theme.of(context).dividerTheme.color!
                )
              ),
            ),
          )
        ) 
      );

      index++;
      ceils.add(ceil);
    }


    return ceils;
  }

  Widget _buildRows()
  {
    /// 颜色
    Color colour = AccentColour.color;

    Color color = Theme.of(context).scaffoldBackgroundColor;
    Color highlight = Color.from
    (
      alpha: 0.5, 
      red: colour.r, 
      green: colour.g, 
      blue: colour.b
    );

    Color undertint = Color.from(
      alpha: 0.2, 
      red: colour.r, 
      green: colour.g, 
      blue: colour.b
    );

    


    return SizedBox
    (
      height: widget.minHeight,
      width: widget.header.entityModel.totalWidth - widget.header.freezedWidth,
      child: ReorderableListView
      (
        buildDefaultDragHandles: false,
        scrollDirection: Axis.horizontal,
        onReorder: (oldIndex, newIndex) 
        {

        },
        children: _buildCeils
        (
          color: color, 
          highlight: highlight, 
          undertint: undertint
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return SingleChildScrollView
    (
      scrollDirection: Axis.horizontal,
      controller: widget.controller,
      child: Container
      (
        padding: EdgeInsets.fromLTRB(0, 0, widget.space, 0),
        child:  _buildRows(),
      )
    );
  }
}