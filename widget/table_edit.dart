import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latest/generated/l10n.dart';
import 'package:latest/utils/theme/theme_colour.dart';
import 'package:latest/widgets/navigation/dropdown_button_menu.dart';



class TableWidgetValue
{
  IconData? icon;
  double width = 0;
  String type = "";
  List<String> range = [];
}

class TableEdit extends StatefulWidget 
{
  final IconData? icon;
  final String? text;
  final int? maxLines;
  final String? restorationId;


  final TextEditingController? controller;
  final Function()? onTap;

  final Function(String value)? onSetValue;
  final Function(PointerDownEvent event)? onTapOutside;
  final Function(TextEditingController controller, TapUpDetails details, Offset cellsPos, 
    double width, String type, List<String> range)? builder; // 操作部件构建器
  
  final Function(bool status)? onOpenMenu; // 打開右键菜单時回调函数

  final Function()? dispose; // 控件销毁时回调函数

  final bool autoText;

  final TableWidgetValue? tableWidgetValue;

  const TableEdit({
    super.key,
    this.restorationId,
    this.text, 
    this.controller, 
    this.icon, 
    this.maxLines = 1,
    this.onSetValue, 
    this.onTapOutside,
    this.onTap,
    this.builder, 
    this.onOpenMenu, 
    this.autoText = false, 
    this.tableWidgetValue,
    this.dispose
  });

  TextEditingController? get edit => controller;



  /// 动态设置编辑器内容
  void setWidget({IconData? icon, required String type, required double width, required List<String> range})
  {
    if(tableWidgetValue != null)
    {
      tableWidgetValue!.icon = icon;
      tableWidgetValue!.type = type;
      tableWidgetValue!.width = width;
      tableWidgetValue!.range = range;
    }
  }


  @override
  State<TableEdit> createState() => _TableEditState();
}

class _TableEditState extends State<TableEdit>
{
  TextEditingController? controller = TextEditingController();

  bool isContextMenuRangeStatus     = false; // 是否处于右键菜单操作范围状态
  bool isWidgetBtnRangeStatus       = false; // 是否处于部件按钮操作范围状态
  OverlayEntry? entry;
  FocusNode focusNode               = FocusNode();
  
  void delete()
  {
    if(entry != null)
    {
      entry?.remove();
      entry = null;
    }
  }
  @override
  void dispose() 
  {
    if(widget.dispose != null)
    {
      widget.dispose!();
    }

    focusNode.dispose();
    delete();
    entry?.dispose();
    super.dispose();
  }

  @override
  void initState() 
  {
    /// 初始化编辑器控制器
    if(widget.controller != null)
    {
      controller = widget.controller;
    }

    if(widget.autoText)
    {
      controller!.text = widget.text!;
    }

    super.initState();
  }

  /// 构建编辑器菜單
  /// [context] 上下文
  /// [EditableTextState] 编辑器状态
  /// return 编辑器菜單控件
  Widget _buildEditMenu(BuildContext context, EditableTextState editableTextState)
  {
    DropdownButtonMenu child = DropdownButtonMenu(builders: _buildDropdownButtonMenu(), width: 180, size: const Size(70, 23), onTapOutside: (event) 
    {
      editableTextState.hideToolbar();
    });


    const double kToolbarScreenPadding  = 0;
    final double paddingAbove           = MediaQuery.paddingOf(context).top + kToolbarScreenPadding;
    final Offset localAdjustment        = Offset(kToolbarScreenPadding, paddingAbove);

    return Padding
    (
      padding: EdgeInsets.fromLTRB(
        kToolbarScreenPadding,
        paddingAbove,
        kToolbarScreenPadding,
        kToolbarScreenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: DesktopTextSelectionToolbarLayoutDelegate(
          anchor: editableTextState.contextMenuAnchors.primaryAnchor - localAdjustment,
        ),
        child:SizedBox
        (
          width: 180,
          child: Material(
            child: child,
          ),
        ) ,
      ),
    );
  }

  /// 显示右键菜单
  DropdownButtonMenuBuilders _buildDropdownButtonMenu()
  {
    final DropdownButtonMenuBuilders builder = DropdownButtonMenuBuilders();

    builder.news("revoke", S.current.revoke, () // 撤销
    {
      if(controller!.text.isNotEmpty){
        Clipboard.setData(ClipboardData(text: controller!.text));
      }
    }, enable: true, keyboard: "Ctrl + Z");


    builder.news("select_all", S.current.selectAll, () // 全选
    {
      if(controller!.text.isNotEmpty)
      {
        final int length = controller?.text.length ?? 0;
        controller?.selection = TextSelection(
          baseOffset: 0, 
          extentOffset: length, 
          isDirectional: true
        );
      }
    }, enable: controller?.text.isNotEmpty ?? false, linear: true, keyboard: "Ctrl + A");


    builder.news("cut", S.current.cut, () // 剪切
    {

      if(controller!.text.isNotEmpty)
      {
        Clipboard.setData(ClipboardData(text: controller!.text));
        controller!.text = "";
      }
    }, enable: controller?.selection.baseOffset != controller?.selection.extentOffset, keyboard: "Ctrl + X");

    builder.news("copy", S.current.copy, () // 复制
    {
      if(controller!.text.isNotEmpty){
        Clipboard.setData(ClipboardData(text: controller!.text));
      }
    }, enable: true, keyboard: "Ctrl + C");

    builder.news("paste", S.current.paste, () // 粘贴
    {
      Clipboard.getData('text/plain').then((value)
      {
        if(value != null && value.text != null)
        {
          String text = "";

          int start = controller!.selection.baseOffset;
          int end   = controller!.selection.extentOffset;

          text = controller!.text.replaceRange(start, end, value.text ?? '');
          controller!.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: value.text!.length + start));
        }
      });
    }, enable: true, keyboard: "Ctrl + V");

    builder.news("delete", S.current.delete, () // 删除
    {
      if(controller!.text.isNotEmpty)
      {
        controller!.text = "";
      }
    }, enable: controller?.text.isNotEmpty ?? false, linear: true);


    return builder;
  }

  /// 构建文本编辑框控件
  /// return 文本编辑框控件
  Widget _buildTextField()
  {
    return TextField
    (
      autofocus: true,
      controller: controller,
      style: Theme.of(context).textTheme.labelMedium,
      cursorWidth: 1.5,
      decoration: const InputDecoration
      (
        errorBorder: InputBorder.none,
        focusedBorder:InputBorder.none,
        focusedErrorBorder:InputBorder.none,
        disabledBorder:InputBorder.none,
        enabledBorder:InputBorder.none,
        contentPadding: EdgeInsets.all(0),
        isDense: true,
      ),
      contextMenuBuilder: _buildEditMenu,
      onSubmitted: (value) 
      {
        widget.onSetValue!(value); // 更新文本
      },
      
      onTapOutside:(event) 
      {
        if(!isContextMenuRangeStatus && !isWidgetBtnRangeStatus)
        {
          if(widget.onTapOutside != null)
          {
            widget.onTapOutside!(event);
          }
        }

        if(widget.onSetValue != null)
        {
          widget.onSetValue!(controller!.text); // 更新文本
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    
    return Container
    (
      height: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row
      (
        children: 
        [
          Expanded(child: _buildTextField()),
          
          widget.tableWidgetValue!.icon != null ? TableOptions
          (
            icon: widget.tableWidgetValue == null ? widget.icon : widget.tableWidgetValue!.icon, 
            onHover: (hover) 
            {
              isWidgetBtnRangeStatus = hover;
            },
            onTapUp:(details) 
            {
              if(widget.builder != null)
              {
                // get cells position
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset offset = renderBox.localToGlobal(Offset.zero);
                
                widget.builder!(controller!, details, offset, widget.tableWidgetValue!.width, widget.tableWidgetValue!.type, widget.tableWidgetValue!.range);
              }
            },
          ) :const SizedBox()
        ],
      )
    );
  }
}

class TableOptions extends StatefulWidget 
{
  final IconData? icon;
  final Function(bool hover)? onHover;
  final Function(TapUpDetails details)? onTapUp;
  
  const TableOptions({super.key, required this.icon, required this.onHover, required this.onTapUp});

  @override
  State<TableOptions> createState() => _TableOptionsState();
}

class _TableOptionsState extends State<TableOptions> 
{
  bool isHover = false;

  @override
  Widget build(BuildContext context) 
  {
    Color iconColor = isHover ? Color(ThemeColour.reverseColor(context)) : Theme.of(context).iconTheme.color!;

    return MouseRegion
    (
      onEnter:(event) 
      {
        setState(() {
          isHover = true;
          widget.onHover!(isHover);
        });
      },
      onExit: (event)
      {
        setState(() {
          isHover = false;
          widget.onHover!(isHover);
        });
      },
      
      child: GestureDetector
      (
        onTapUp:(details) => widget.onTapUp!(details),
        child: Container
        (
          width: 18,
          height: double.infinity,
          margin: const EdgeInsets.all(0.8),
          decoration: BoxDecoration
          (
            color: Theme.of(context).appBarTheme.backgroundColor,
            border: Border.all(color: isHover ? Color(ThemeColour.reverseColor(context)) : Theme.of(context).dividerColor, width: 0.3),
            borderRadius: BorderRadius.circular(2)
          ),
          child: Icon(widget.icon, size: 15, color: iconColor)
        )
      )
    );
  }
}