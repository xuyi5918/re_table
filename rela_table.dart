import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latest/widgets/data_display/data_table/entity/page_table_body.dart';
import 'package:latest/widgets/data_display/data_table/entity/page_table_header.dart';
import 'package:latest/widgets/data_display/data_table/entity/table_prefix.dart';
import 'package:latest/widgets/data_display/data_table/widget/rich_table_body.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_body.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_cell_mixin.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_edit.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_element.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_header.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_layout.dart';
import 'package:latest/widgets/data_display/data_table/widget/table_pane.dart';
import 'package:latest/widgets/data_display/data_table/entity/keyboard.dart';
import 'package:latest/widgets/layout/bubble.dart';
import 'package:sync_scroll_controller/sync_scroll_controller.dart';

class RelaTable extends StatefulWidget 
{
  final double minHeight;
  final double space;
  final PageTableBody pageBody;
  final PageTableHeader pageHeader;

  final double initialHorizontalScrollOffset;
  final double initialVerticalScrollOffset;
  final FocusScopeNode focusNode;

  final void Function(Offset offset) contextBodyMenuBuilder; // context body Menu Builder
  final void Function(String key, TapUpDetails details) contextHeaderMenuBuilder; // context header Menu Builder

  final void Function(int index, TapUpDetails details) contextPaneMenuBuilder; // context pane Menu Builder

  final TablePrefix prefix; // table prefix

  final bool rich; /// rich table body
  

  const RelaTable({
    super.key,
    this.rich = false,
    required this.focusNode,
    required this.minHeight, 
    required this.prefix,
    required this.space,
    required this.pageBody, 
    required this.pageHeader,
    required this.initialHorizontalScrollOffset, 
    required this.initialVerticalScrollOffset,
    required this.contextBodyMenuBuilder,
    required this.contextHeaderMenuBuilder,
    required this.contextPaneMenuBuilder
  });

  @override
  State<RelaTable> createState() => _RelaTableState();
}

class _RelaTableState extends State<RelaTable> 
{
  late final SyncScrollControllerGroup horizontalControllers;
  late final SyncScrollControllerGroup verticalControllers;

  late final ScrollController pageHeaderHorizontalController;
  late final ScrollController pageBodyHorizontalController;

  late final ScrollController pageBodyVerticalController;
  late final ScrollController pageFreezeVerticalController;
  late final ScrollController paneVerticalController;

  /// keyboard
  Keyboard keyboard = Keyboard();

  TableCellMixin? body;
  TablePane? pane;

  TableEdit? tableEdit;

  Bubble bubble             = Bubble(); // bubble
  TableElement tableElement = TableElement(); // table element


  @override
  void dispose() 
  {
    pageBodyHorizontalController.dispose();
    pageHeaderHorizontalController.dispose();
    pageBodyVerticalController.dispose();
    pageFreezeVerticalController.dispose();
    paneVerticalController.dispose();

    bubble.dispose(); // dispose bubble
    pane?.dispose(); // dispose pane

    super.dispose();
  }

  @override
  void initState() 
  {
    horizontalControllers = SyncScrollControllerGroup(
      initialScrollOffset: widget.initialHorizontalScrollOffset,
    );
    
    verticalControllers = SyncScrollControllerGroup(
      initialScrollOffset: widget.initialVerticalScrollOffset,
    );

    pageBodyHorizontalController    = horizontalControllers.addAndGet();
    pageHeaderHorizontalController  = horizontalControllers.addAndGet();
    pageBodyVerticalController      = verticalControllers.addAndGet();


    pageFreezeVerticalController    = verticalControllers.addAndGet();
    paneVerticalController          = verticalControllers.addAndGet();

    // Trigger on roll
    pageBodyVerticalController.addListener((){
      if(bubble.isEntry)
      {
        bubble.close(); // close bubble
      }
    });

    /// Initialization of the ceils edits box
    tableEdit = TableEdit
    (
      controller: widget.pageBody.controller, 
      tableWidgetValue: TableWidgetValue(),
      onSetValue: (value) 
      {
        widget.pageBody.entityModel.setValue(value); 
      },
      onTapOutside:(event) 
      {
      },
      builder:(controller, details, cellsPos, width, type, range)
      {
        Widget element = tableElement.createElement(
          element: type, 
          value: controller.text, 
          range: range, 
          offset: cellsPos,
          width: width,
          onChanged: (value) 
          {
            controller.text = value;
          },

          onFinish:() => bubble.close() // close bubble,
        );

        double blowWidth = tableElement.width;
        bubble.blow
        (
          context, 
          position: Offset(cellsPos.dx - 1, cellsPos.dy + widget.minHeight - 2), 
          width: blowWidth,
          height: tableElement.height,
          child: SizedBox
          (
            width: blowWidth,
            child: TapRegion
            (
              onTapOutside: (event) => bubble.close(),
              child: element
            )
          )
        );
      },
      dispose: () 
      {
        widget.pageBody.setEditValues(isEdit: false);
      },
    );

    super.initState();
  }

  /// keyboard down event
  /// @param int keycode
  /// @return void
  void keyDownEvent({required LogicalKeyboardKey keycode})
  {
    switch (keycode) 
    {
      case LogicalKeyboardKey.arrowDown:
        if(!keyboard.isShift && (widget.pageBody.entityModel.batchKeys.isNotEmpty || widget.pageBody.entityModel.batchValues.isNotEmpty))
        {
          widget.pageBody.clearAway();
        }else if(keyboard.isShift)
        {
          widget.pageBody.entityModel.popupIndex(locationId: widget.pageBody.index, up: true);
        }

        bool next = widget.pageBody.entityModel.next();
        if(next)
        {
          widget.pageBody.setEditMode(mode: false);

          body?.reedit(key: widget.pageBody.entityModel.key, 
            range: widget.pageHeader.entityModel.columns[widget.pageBody.entityModel.key]?.range ?? []);

          pane?.rebuild(next);
          widget.pageBody.rebuild();
          widget.pageHeader.rebuild();
        }
      break;

      case LogicalKeyboardKey.arrowUp:
        if(!keyboard.isShift && (widget.pageBody.entityModel.batchKeys.isNotEmpty || widget.pageBody.entityModel.batchValues.isNotEmpty))
        {
          widget.pageBody.clearAway();
        }else if(keyboard.isShift)
        {
          widget.pageBody.entityModel.popupIndex(locationId: widget.pageBody.index ?? 0, up: false);
        }

        bool prev = widget.pageBody.entityModel.prev();
        if(prev)
        {
          widget.pageBody.setEditMode(mode: false);

          pane?.rebuild(prev);
          body?.reedit(key: widget.pageBody.entityModel.key, range: widget.pageHeader.entityModel.columns[widget.pageBody.entityModel.key]?.range ?? []);
          widget.pageBody.rebuild();
          widget.pageHeader.rebuild();
        }
      break;

      case LogicalKeyboardKey.arrowLeft:
        if(!widget.pageBody.editMode)
        {
          /// prev key
          widget.pageHeader.entityModel.prevKey().then((prevKey)
          {
            if(prevKey)
            {
              widget.pageBody.setEditMode(mode: false);

              if(keyboard.isShift)
              {
                widget.pageHeader.entityModel.popupKey(key: widget.pageBody.key, right: false);
                
              }else if(widget.pageBody.entityModel.batchKeys.isNotEmpty || widget.pageBody.entityModel.batchValues.isNotEmpty)
              {
                widget.pageBody.clearAway();
              }
              
              body?.reedit(key: widget.pageBody.entityModel.key, range: widget.pageHeader.entityModel.columns[widget.pageBody.entityModel.key]?.range ?? []);

              widget.pageHeader.rebuild();
              widget.pageBody.rebuild();
            }
          });
        }
      
      break;

      case LogicalKeyboardKey.arrowRight:
        if(!widget.pageBody.editMode)
        {
          /// next key
          widget.pageHeader.entityModel.nextKey().then((nextKey)
          {
            if(nextKey)
            {
              widget.pageBody.setEditMode(mode: false);

              if(keyboard.isShift)
              {
                widget.pageHeader.entityModel.popupKey(key: widget.pageBody.key, right: true);
              }else if(widget.pageBody.entityModel.batchKeys.isNotEmpty || widget.pageBody.entityModel.batchValues.isNotEmpty)
              {
                widget.pageBody.clearAway();
              }
              
              body?.reedit(key: widget.pageBody.entityModel.key, range: widget.pageHeader.entityModel.columns[widget.pageBody.entityModel.key]?.range ?? []);


              widget.pageHeader.rebuild();
              widget.pageBody.rebuild();
            }
          });
        }
      break;

      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        keyboard.setShift(true);
        widget.pageBody.saveTempPos(  // save temp index id
          index: widget.pageBody.entityModel.index, 
          key: widget.pageHeader.entityModel.key
        );
        
      break;

      case LogicalKeyboardKey.controlLeft:
      case LogicalKeyboardKey.controlRight:
        keyboard.setCtrl(true);
      break;

      case LogicalKeyboardKey.enter:
        widget.pageBody.setEditMode(mode: !widget.pageBody.editMode);
        if(widget.pageBody.editMode)
        {
          body?.reedit(key: widget.pageBody.entityModel.key, range: widget.pageHeader.entityModel.columns[widget.pageBody.entityModel.key]?.range ?? []);
        }

        widget.pageBody.rebuild();
      break;
    }

  }

  /// keyboard up event
  /// @param int keycode
  /// @return void
  void keyUpEvent({required LogicalKeyboardKey keycode})
  {
    switch (keycode) 
    {
      case LogicalKeyboardKey.arrowDown:
        if(keyboard.isShift)
        {
        }

        
      break;

      case LogicalKeyboardKey.arrowUp:
        if(keyboard.isShift)
        {

        }
      break;

      case LogicalKeyboardKey.arrowLeft:
        if(keyboard.isShift)
        {

        }
      break;

      case LogicalKeyboardKey.arrowRight:
        if(keyboard.isShift)
        {

        }
      break;

      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        keyboard.setShift(false);
        widget.pageBody.saveTempPos(index: -1, key: "");
      break;

      case LogicalKeyboardKey.controlLeft:
      case LogicalKeyboardKey.controlRight:
        keyboard.setCtrl(false);
      break;
    }
  }

  /// rich table body
  /// @return Widget
  TableCellMixin? tableBody()
  {
    TableCellMixin? child;

    if(!widget.rich)
    {
      child = TableBody
      (
        body: widget.pageBody, 
        tableEdit: tableEdit,
        keyboard: keyboard,
        prefix: widget.prefix, // prefix
        contextMenuBuilder: widget.contextBodyMenuBuilder,

        onSelect: (index, key) async
        {
          pane?.rebuild(index == widget.pageBody.entityModel.index);

          widget.pageHeader.rebuild();
        },
        onReset: () async 
        {
          widget.pageHeader.entityModel.setBatchKeys([]);
          widget.pageHeader.rebuild();
        },
        onDragSelectionEnd: (int index) async
        {
          pane?.rebuild(index == widget.pageBody.entityModel.index);

          widget.pageHeader.rebuild();
        },
        space: widget.space,
        minHeight: widget.minHeight, 
        zebraCount: 5, 
        pageBodyHorizontalController:   pageBodyHorizontalController, 
        pageBodyVerticalController:     pageBodyVerticalController, 
        pageFreezedVerticalController:  pageFreezeVerticalController
      );

    }else
    {
      child = RichTableBody
      (
        body: widget.pageBody, 
        isMultiple: true,
        keyboard: keyboard,
        tableEdit: tableEdit,
        minHeight: widget.minHeight, 
        space: widget.space,
        zebraCount: 5,
        pageBodyHorizontalController:   pageBodyHorizontalController, 
        pageBodyVerticalController:     pageBodyVerticalController,

        
        onSelect: (index, key) 
        {
          pane?.rebuild(index == widget.pageBody.entityModel.index);
          widget.pageHeader.rebuild();
        },
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) 
  {
    /// table pane
    pane = TablePane
    (
      icon: Icons.arrow_right, 
      size: 15, 
      taking:(index) => index == widget.pageBody.entityModel.index,

      controller: paneVerticalController,
      itemCount: widget.pageBody.entityModel.length, 
      minHeight: widget.minHeight, 
      onSelect:(index) async
      {
        bool setIndex = widget.pageBody.entityModel.setIndex(index);
        if(setIndex)
        {
          widget.pageBody.clearAway();
          widget.pageBody.setEditMode(mode: false);
          
          widget.pageBody.rebuild();
          widget.pageHeader.rebuild();
        }

        return setIndex;
      }, 
      contextMenuBuilder: widget.contextPaneMenuBuilder
    );

    /// table body
    body = tableBody();
    

    /// table header
    TableHeader tableHeader = TableHeader
    (
      minHeight:  22,
      space:      widget.space,
      header:     widget.pageHeader,
      controller: pageHeaderHorizontalController,
      onSelect: (key) 
      {
        widget.pageBody.clearAway();
        widget.pageBody.setSelectedKey(key: key);
        widget.pageBody.setEditMode(mode: false);

        widget.pageBody.rebuild();
      },
      contextMenuBuilder: widget.contextHeaderMenuBuilder
    );


    return FocusScope
    (
      autofocus: true,
      node: widget.focusNode,
      onKeyEvent: (node, event) 
      {
        if(event is KeyDownEvent)
        {
          keyDownEvent(keycode: event.logicalKey);
        }else if(event is KeyUpEvent)
        {
          keyUpEvent(keycode: event.logicalKey);
        }

        return KeyEventResult.ignored;
      },
      child: TableLayout
      (
        pageHeader  : tableHeader, 
        pageBody    : body as Widget, 
        tablePane   : pane!,
        minHeight   : 22,
      )
    );
  }
}