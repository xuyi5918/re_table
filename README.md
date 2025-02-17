A simple to use flutter table editing component


example:
EntityModel model = EntityModel(defaultWidth: 100);
model.addColumn("id", EntityColumn("id", type: DataType.isText));
model.addColumn("user_id", EntityColumn("user_id", type: DataType.isText));
model.addColumn("title", EntityColumn("title", type: DataType.isEnum, range: ["1", "2", "3", "4", "5", "6"]));
model.addColumn("set", EntityColumn("title", type: DataType.isSet, range: ["Key", "Value", "Name", "Changed", "5", "6"]));

model.addColumn("name", EntityColumn("name", type: DataType.isText));
model.addColumn("create_at", EntityColumn("create_at", type: DataType.isDateTime));
model.addColumn("update_at", EntityColumn("update_at", type: DataType.isDateTime));
model.addColumn("binary", EntityColumn("binary", type: DataType.isBinary));
model.addColumn("blob", EntityColumn("blob", type: DataType.isBlob));
for (var i = 0; i < 1000; i++) 
{
  Map<String, dynamic> data = {
    "id":1, 
    "title":"3", 
    "name": "name $i", 
    "create_at": "2019-05-08 14:37:06", 
    "update_at": "2019-05-08 14:37:06", 
    "user_id": i,
    "set": '1',
    "binary": "001",
    "blob": "2023年10月16日?·?本文将详细介绍 Flutter 中的 `Icon` 组件的用法， 图标库 的使用方法，以及如何自定义 图标。 创建一个包含所有自定义 图标 的文件夹，例如 icons。 在文件夹 icons 中创建一个文件，并添加以下内容：fonts:fonts:在文",

  };
  
  model.addData(data: data);
}

pageTableHeader = PageTableHeader(entityModel: model);
pageTableBody = PageTableBody(entityModel: model, controller: TextEditingController());

    
RelaTable
(
  rich: false,
  minHeight: 22, 
  space: 100,
  focusNode: FocusScopeNode(),
  pageHeader: pageTableHeader!, 
  pageBody: pageTableBody!,
  initialHorizontalScrollOffset: 0, 
  initialVerticalScrollOffset: 0,
  contextPaneMenuBuilder: (index, details) 
  {
    DropdownButtonMenu pane = contextmenu!.pane;
    
    contextmenu!.bubble.blow(
      context, 
      child: pane, 
      position: Offset(details.globalPosition.dx - 1.5, details.globalPosition.dy - 1.5),
      width: 200,
      height: pane.getHeight(pane.builders.lineCount, count: pane.builders.length) + 10,
    );
  },
  contextBodyMenuBuilder: (offset) 
  {
    

  },
  contextHeaderMenuBuilder:(index, details) 
  {
    
  },
);
