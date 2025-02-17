import 'package:flutter/material.dart';
import 'package:latest/utils/theme/accent_colour.dart';
import 'package:latest/utils/theme/theme_colour.dart';
import 'package:latest/widgets/data_display/data_table/entity/entity_model.dart';
import 'package:latest/widgets/data_display/data_table/entity/keyboard.dart';
import 'package:latest/widgets/data_display/data_table/entity/page_table_body.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_cell_mixin.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_edit.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_scroll_layout.dart';

class RichTableBody extends StatefulWidget with TableCellMixin 
{
  final PageTableBody body;
  final double space;
  final bool isMultiple; ///是否可以多选
  final TableEdit? tableEdit;
  final double? minHeight; ///最小高度
  final bool isZebra; // zebra mode or not

  final int zebraCount;   // zebra mode count

  final Keyboard keyboard;



  final ScrollController pageBodyHorizontalController; 
  final ScrollController pageBodyVerticalController;

  final void Function(int index, String? key) onSelect;

  const RichTableBody({
    super.key, 
    this.isZebra = true,
    required this.keyboard,
    required this.onSelect,
    required this.zebraCount,
    required this.body,
    required this.minHeight, 
    required this.space,
    required this.isMultiple, 
    required this.tableEdit, 
    required this.pageBodyHorizontalController, 
    required this.pageBodyVerticalController
  });

  @override
  State<RichTableBody> createState() => _RichTableBodyState();

  /// Reedit the cell.
  /// @param String key The key of the cell.
  /// @param List<String> range The range of the cell.
  /// @return [void] Void.
  @override
  void reedit({required String key, List<String> range = const []}) async
  {
    // TODO: implement reedit
  }
}

class _RichTableBodyState extends State<RichTableBody> 
{

  /// Rebuild the widget.
  void _rebuild() => setState(() {});

  BorderSide? side;
  
  bool isEditArea  = false;
  bool isClickSelection = false; // 是否在选择区域

  /// 单元格事件
  /// @param [Widget child] The child of the cell.
  Widget buildEvents({required int index, required Widget child, bool isPos = true, required String key})
  {
    return MouseRegion
    (
      onEnter: (event) 
      {
        isEditArea = true;
      },

      onExit: (event) {
        isEditArea = false;
      },

      child: GestureDetector
      (
        onTapUp: (details) 
        {
          if(!widget.keyboard.isShift && !widget.keyboard.isCtrl)
          {
            widget.body.setEditValues(isEdit: true); // is edit values
          }
        },
        onTapDown: (details) 
        {
          isClickSelection = false;

          /// If the edit mode is active, do not allow to select cells.
          if(widget.body.editMode && isPos)
          {
            return;
          }

          /// Set the selection mode.
          widget.body.setSelectionMode(selectionMode: true, isClickSelection: false);

          /// Initialization of the ceils
          widget.body.setInitializationCeils(dx: details.localPosition.dx, dy: details.localPosition.dy);

          /// Set the position of the cell.
          widget.body.entityModel.setPosition(index: index, key: key).then((value) async
          {
            if(value) 
            {
              bool mode = widget.keyboard.isShift || widget.keyboard.isCtrl ? false : true;

              widget.reedit(key: key, range: widget.body.entityModel.columns[key]?.range ?? []);

              widget.onSelect(index, key);

              /// Set the edit mode.
              widget.body.setEditMode(mode: mode);

              if(mode == false)
              {
                /// 批量选择模式
                isClickSelection = await widget.body.selectionBatch(isShift: widget.keyboard.isShift);
              }
            }
          });
        },
        onSecondaryTapDown: (details)
        {
          if(widget.body.editMode && isPos)
          {
            return;
          }

          /// Set the selection mode.
          if(widget.body.editMode && !isPos)
          {
            widget.body.setEditMode(mode: false);
          }

          /// Initialization of the ceils
          widget.body.setInitializationCeils(dx: details.localPosition.dx, dy: details.localPosition.dy);

          
          /// Set the position of the cell.
          widget.body.entityModel.setPosition(index: index, key: key).then((value) 
          {
            if(value) 
            {
              /// Set the edit mode.
              widget.reedit(key: key);
              
              /// If you press the secondary mouse button, clear the selection.
              bool isRange = widget.body.hasRange(key: key, index: index) || widget.body.selectedKey == key;
              if(!isRange) 
              {
                widget.body.clearAway();
              }


              widget.onSelect(index, key);
              _rebuild();
            }
          });
        },
        child: child,
      )
    );
  }


  /// 初始化边框样式
  /// @param [List<String> keys] The keys of the cell.
  /// @param [TextStyle? style] The style of the cell.
  /// @return [void] Void.
  List<Widget> buildCell(Map<String, dynamic> data, {
    required Color zebraColor, 
    required int index, 
    List<String> keys = const [], 
    TextStyle? style,

    required Color positionColor,
    required Color radiusColor,
    bool isSelectedRows = false,
    required Color lineColor
  })
  {
    List<Widget> cells = [];
    String selectedKey = widget.body.selectedKey;

    
    for (int i = 0; i < keys.length; i++) 
    {
      String key  = keys[i];
      String text = "${data[key]}";


      bool hasRange = widget.body.hasRange(key: key, index: index) || selectedKey == key;
      bool hasPosition = widget.body.entityModel.position(index: index, key: key);

      Container cell = Container
      (
        padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
        alignment: Alignment.centerLeft,
        width: widget.body.entityModel.getWidth(key: key),
        decoration: BoxDecoration
        (
          color: hasPosition ? positionColor : hasRange ? radiusColor : isSelectedRows ? lineColor : zebraColor,
          border: Border
          (
            bottom: hasRange ? side!.copyWith(color: Color(ThemeColour.color(context))) : side!,
            right: hasRange ? side!.copyWith(color: Color(ThemeColour.color(context))) : side!
          )
        ),

        child: Text(text, style: hasPosition ? style?.copyWith(color: Colors.white) : style),
      );


      cells.add(buildEvents(
        index: index,
        key: key,
        isPos: hasPosition,
        child: cell
      ));
    }

    return cells;
  }



  @override
  Widget build(BuildContext context) 
  {
    Color zebraColor    = Color(ThemeColour.zebraStripe(context));

    int   length        = widget.body.entityModel.length;
     /// 获取表头的字段信息
    Map<String, EntityColumn> entity  = widget.body.entityModel.columns;
    List<String> keys                 = entity.keys.toList();

    /// 边框颜色
    side = BorderSide(width: 0.8, color: Theme.of(context).dividerTheme.color!);

    /// 单元格文字样式信息
    TextStyle? cellsTextStyle  = Theme.of(context).textTheme.labelMedium;


    /// table color theme
    Color color           = AccentColour.color;

    Color? lineColor      = Color.from(alpha: 0.19, red: color.r, green: color.g, blue: color.b);
    Color? positionColor  = Color.from(alpha: 0.8, red: color.r, green: color.g, blue: color.b);
    Color? radiusColor    = Color.from(alpha: 0.5, red: color.r, green: color.g, blue: color.b);

    return TableScrollLayout
    (
      space: widget.space, 
      pageBodyHorizontalController: widget.pageBodyHorizontalController, 
      pageBodyVerticalController: widget.pageBodyVerticalController,
      minWidth: widget.body.entityModel.totalWidth - widget.body.freezedWidth,
      child: ListView.builder
      (
        controller: widget.pageBodyVerticalController,
        itemCount: length,
        itemBuilder:(context, index) 
        {
          return SizedBox
          (
            height: widget.minHeight,
            child: Row
            (
              children: buildCell
              (
                widget.body.entityModel.data[index], 
                zebraColor: index % widget.zebraCount == 0 ? zebraColor : Colors.transparent, 
                index: index, 
                keys: keys, 
                style: cellsTextStyle,
                isSelectedRows: widget.body.entityModel.index == index,
                positionColor: positionColor,
                radiusColor: radiusColor,
                lineColor: lineColor,
              ),
            ),
          );
        },
      )
    );
  }
}