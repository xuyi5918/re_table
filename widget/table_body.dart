import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latest/utils/theme/accent_colour.dart';
import 'package:latest/utils/theme/theme_colour.dart';
import 'package:latest/widgets/data_display/data_table/entity/data_format.dart';
import 'package:latest/widgets/data_display/data_table/entity/entity_model.dart';
import 'package:latest/widgets/data_display/data_table/entity/keyboard.dart';
import 'package:latest/widgets/data_display/data_table/entity/page_table_body.dart';
import 'package:latest/widgets/data_display/data_table/entity/table_prefix.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_cell_mixin.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_edit.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_scroll_layout.dart';
import 'package:latest/widgets/data_display/data_table/entity/data_type.dart';

// ignore: must_be_immutable
class TableBody extends StatefulWidget with TableCellMixin
{
  final PageTableBody body;

  final TableEdit? tableEdit;

  final Keyboard keyboard;

  /// page body controller
  final ScrollController pageBodyHorizontalController; 
  final ScrollController pageBodyVerticalController;

  /// freezed controller
  final ScrollController pageFreezedVerticalController;
  final int zebraCount;   // zebra mode count

  final double space;

  final double minHeight; // min height of the table rows

  final Function(int index, String key) onSelect; // select event
  final Function() onReset; // reset event

  final Function(int index) onDragSelectionEnd;
  final Function(Offset offset) contextMenuBuilder;

  final TablePrefix prefix; // prefix of the table

  final bool isZebra; // zebra mode or not



  TableBody({
    super.key, 
    this.isZebra = true,

    required this.prefix,
    required this.tableEdit,
    required this.contextMenuBuilder,
    required this.keyboard,
    required this.body,
    required this.minHeight,
    required this.space,
    required this.zebraCount, // zebra mode or not
    required this.onSelect,
    required this.onDragSelectionEnd,
    required this.onReset,
    required this.pageBodyHorizontalController, 
    required this.pageBodyVerticalController,

    required this.pageFreezedVerticalController,
  });


  /// Icon of the ceils
  Map<String, IconData?> icon = {

    DataType.isEnum : Icons.keyboard_arrow_down_sharp, 
    DataType.isDate : Icons.date_range_rounded, 
    DataType.isTimer: Icons.timer_outlined,
    DataType.isDateTime : Icons.date_range_outlined, 
    DataType.isSet      : Icons.list_alt_outlined,

  };



  /// Reedit the cell.
  /// @param String key The key of the cell.
  /// @param List<String> range The range of the cell.
  /// @return [void] Void.
  @override
  void reedit({required String key, List<String> range = const []}) async
  {
    tableEdit?.edit?.text = "${body.entityModel.value}";
    
    String type = body.entityModel.columns[key]?.type ?? '';
    double width = body.entityModel.getWidth(key: key);

    tableEdit?.setWidget(icon: icon[type], type: type, width: width, range: range);
  }

  @override
  State<TableBody> createState() => _TableBodyState();
  
}

class _TableBodyState extends State<TableBody> 
{
  int buttons = 0;

  @override
  void initState() 
  {
    widget.body.addListener(_rebuild);
    super.initState();
  }

  @override
  void dispose() 
  {
    widget.body.removeListener(_rebuild);
    super.dispose();
  }

  /// Rebuild the widget when something changes.
  void _rebuild() 
  {
    setState(() {});
  }

  /// Build the cell widget.
  /// @param int type 1: edit mode, 2: error mode defaults: normal mode.
  /// @param String text The content of the cell.
  /// @param TextStyle? style The text style of the cell.
  /// @return [Widget] The cell widget.
  Widget? _buildEdits(int type, {required String text, required TextStyle? style, required String dataType})
  {
    switch(type) 
    {
      case 1:
        return widget.tableEdit;
      case 2:
        return Text(text, style: style);
      default:
        DataFormat format = DataFormat(text: text, format: dataType, prefix: widget.prefix.getPrefix(dataType)); // format the text.
        return Text(format.getValue, style: style, overflow: TextOverflow.ellipsis);
    }
  }

  bool isEditArea  = false;
  bool isClickSelection = false; // 是否在选择区域


  /// Build cell events
  /// @param int index .
  /// @param String key.
  /// @param Widget child.
  /// @return [Widget] The cell widget.
  Widget _buildEvents({required bool isPos, required int index, required String key, required Widget child})
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

  /// Build the cells of each row.
  /// [data] The data of the row.
  /// @return [List<Widget>] The list of the cells.
  List<Widget> _buildCeils(Map<String, dynamic> data, {
    int index = 0,

    bool isZebra = false, 
    Color? color, 
    bool isSelectedRows = false,
    Color? accentColor,
    Color? lineColor,
    Color? positionColor,
    Color? radiusColor,

    List<String> keys = const [],

  }) {
    List<Widget> ceils                = [];
    Map<String, EntityColumn> entity  = widget.body.entityModel.columns;
   

    BorderSide side         = BorderSide(width: 0.8, color: Theme.of(context).dividerTheme.color!);
    
    TextStyle? labelMedium  = Theme.of(context).textTheme.labelMedium;

    String selectedKey      = widget.body.selectedKey;

   

    /// Build the cells.
    for(int i = 0; i < keys.length; i++)
    {
      String key  = keys[i];
      String text = "${data[key]}";

      if(widget.body.entityModel.freeze.contains(key) || !entity.containsKey(key))
      {
        continue;
      }

      /// 验证该单元格是否在选中区域
      bool hasRange = widget.body.hasRange(key: key, index: index) || selectedKey == key;

      /// pos ceils 
      bool hasPosition = widget.body.entityModel.position(index: index, key: key);

      EntityColumn column = entity[key]!;
      

      Widget ceil = Container
      (
        padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration
        (
          color: hasPosition ? positionColor : hasRange ? radiusColor : isSelectedRows ? lineColor : color,
          border: Border
          (
            bottom: hasRange ? side.copyWith(color: Color(ThemeColour.color(context))) : side,
            right: hasRange ? side.copyWith(color: Color(ThemeColour.color(context))) : side
          )
        ),
        width: widget.body.entityModel.getWidth(key: key),

        child: _buildEdits
        (
          hasPosition && widget.body.editMode ? 1 : 3, 
          text: text, 
          style: hasPosition ? labelMedium?.copyWith(color: Colors.white) : labelMedium,
          dataType: column.type
        ),
      );


      /// 点击事件
      ceil = _buildEvents(isPos: hasPosition ,index: index, key: key, child: ceil);

      ceils.add(ceil);
    }

    return ceils;
  }

  /// Build the cell widget.
  /// [index] The index of the cell.
  Widget _buildRows(int index, Color color, 
  {
    bool isFreeze = false,
    
    Color? accentColor,
    Color? lineColor,
    Color? positionColor,
    Color? radiusColor,
    
    List<String> keys = const [],
  }) 
  {

    Color zebraColor = index % widget.zebraCount == 0 ? color : Colors.transparent;
    bool selected = widget.body.entityModel.index == index;

    List<Widget> ceils = _buildCeils(
      widget.body.entityModel.data[index],

      index: index,

      isZebra: widget.isZebra, 
      color: zebraColor, 
      isSelectedRows: selected,
      
      accentColor: accentColor,
      lineColor: lineColor,
      positionColor: positionColor,
      radiusColor: radiusColor,
      keys: keys
    );


    return SizedBox
    (
      height: widget.minHeight,
      child: Row(children: ceils),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    int   length        = widget.body.entityModel.length;
    Color zebraColor    = Color(ThemeColour.zebraStripe(context));

    List<Widget> pages  = []; // The list of pages.


    /// table color theme
    Color color           = AccentColour.color;

    Color? lineColor      = Color.from(alpha: 0.19, red: color.r, green: color.g, blue: color.b);
    Color? positionColor  = Color.from(alpha: 0.8, red: color.r, green: color.g, blue: color.b);
    Color? radiusColor    = Color.from(alpha: 0.5, red: color.r, green: color.g, blue: color.b);

    /// 获取表头的字段信息
    Map<String, EntityColumn> entity  = widget.body.entityModel.columns;
    List<String> keys                 = entity.keys.toList();

    /// If the table is frozen, build a column for the frozen area.
    if(widget.body.entityModel.isFreezeNotEmpty)
    {
      Widget ret = Container
      (
        width: widget.body.freezedWidth,
        decoration: BoxDecoration
        (
          border: Border(right: BorderSide(width: 1, color: Theme.of(context).dividerTheme.color ?? Colors.transparent))
        ),

        child: ListView.builder
        (
          controller: widget.pageFreezedVerticalController,
          itemCount: length,
          itemBuilder:(context, index) 
          {
            return _buildRows(index, zebraColor, 
              isFreeze: true, accentColor: color, lineColor: lineColor, positionColor: positionColor, radiusColor: radiusColor, keys: keys);
          },
        ),
      );

      pages.add(ret);
    }

    /// If the table data is not null, build a column for the body.
    if(length > 0)
    {
      Widget ret = TableScrollLayout
      (
        pageBodyHorizontalController: widget.pageBodyHorizontalController, 
        pageBodyVerticalController: widget.pageBodyVerticalController,
        minWidth: widget.body.entityModel.totalWidth - widget.body.freezedWidth,
        space: widget.space,
        child: Listener
        (
          onPointerDown: (event) 
          {
            bool isPassdown = (!widget.keyboard.isCtrl && !widget.keyboard.isShift);


            /// If you press the mouse, the selection mode is set to true.
            if(!isEditArea)
            {
              if(widget.body.editMode)
              {
                widget.body.setEditMode(mode: false);
              }

              widget.onReset(); /// Reset the selection.
            }

            

            /// If you press the mouse, the selection mode is set to true.
            if(event.buttons == kPrimaryMouseButton && isPassdown)
            {
              widget.body.clearAway();
            }

            if(event.buttons == kSecondaryMouseButton && !isEditArea)
            {
              widget.body.clearAway();
            }


            buttons = event.buttons;

            _rebuild();
          },

          
          onPointerUp: (event) 
          {
            if(!widget.body.editMode && !isEditArea && buttons == kSecondaryMouseButton)
            {
              widget.contextMenuBuilder(event.position); 
            }

            if(widget.body.isSelectionMode) // Execute if drag selection mode is enabled
            {
              widget.onDragSelectionEnd(widget.body.entityModel.index);

              /// If you release the mouse, the selection mode is set to false.
              widget.body.setSelectionMode(selectionMode: false, isClickSelection: isClickSelection);
            }
            _rebuild();
          },
          onPointerMove: (event) 
          {
            if(widget.body.isEditValues || widget.keyboard.isShift)
            {
              return;
            }
            
            if(event.buttons == kPrimaryMouseButton && widget.body.isSelectionMode)
            {
              widget.body.setEditMode(mode: false);

              widget.body.selection(x: event.localDelta.dx, y: event.localDelta.dy, height: widget.minHeight);
              widget.body.rebuild();
            }
          },

          child: ListView.builder
          (
            controller: widget.pageBodyVerticalController,
            itemCount: length,
            itemBuilder:(context, index) 
            {
              return _buildRows(
                index, 
                zebraColor, 
                isFreeze: false, 
                accentColor: color, 
                lineColor: lineColor, 
                positionColor: positionColor, 
                radiusColor: radiusColor, 
                keys: keys
              );
            },
          ),
        )
      );
      
      pages.add(Expanded(child: ret));
    }


    return Row(children: pages);
  }
}