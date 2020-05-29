import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:neofilemanager/Item/Preview/FilePre.dart';
import 'package:neofilemanager/Item/Preview/Impl/ProxyFilePre.dart';
import 'package:neofilemanager/Item/Preview/Impl/TxtFilePre.dart';
import 'package:neofilemanager/OperationButtom/CutOperationButton.dart';
import 'package:neofilemanager/OperationButtom/DeleteOperationButton.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'Item/Common.dart';
import 'Item/Mode.dart';
import 'Item/widgetItem.dart';
import 'OperationButtom/AddToFavOperationButton.dart';
import 'OperationButtom/CopyOperationButton.dart';
import 'OperationButtom/RemoveFavOperationButton.dart';
import 'OperationButtom/RenameOperationButton.dart';

class MyHome extends StatefulWidget {
  MyHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHome> {
  ValueNotifier<bool> uiShouldChange = ValueNotifier<bool>(false);

  List<FileSystemEntity> leftFiles = []; //左列的文件
  List<FileSystemEntity> rightFiles = []; //右列的文件
  Mode mode = new Mode(false, false, null, null);
  int cardColor = 0x22ffffff;
  double iconHeight = 30.0;
  double iconWidth = 30.0;
  double fileFontSize = 9.0;
  double subTitleFontSize = 6.0;
  ScrollController controller = ScrollController();
  List<double> position = [];
  Common common = new Common();

  ///初始化: 拿到根路径 刷新目录
  @override
  void initState() {
    super.initState();
    mode.parentDir = Directory(common.sDCardDir); //获取根路径
    new Operation(leftFiles, rightFiles, context,
            uiShouldChange: uiShouldChange, mode: mode)
        .initPathFiles(common.sDCardDir, -2);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: uiShouldChange,
      builder: (BuildContext context, bool value, Widget child) {
        return WillPopScope(
          onWillPop: onWillPop,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text(
                mode.parentDir?.path == common.sDCardDir
                    ? 'SD card'
                    : p.basename(mode.parentDir.path),
              ),
              centerTitle: true,
              elevation: 0.0,
              //浮起来的高度
              leading: mode.parentDir?.path == common.sDCardDir
                  ? Container()
                  : IconButton(
                      icon: Icon(
                        Icons.arrow_left,
                      ),
                      onPressed: onWillPop,
                    ), //再标题前面显示的一个控件
            ),
            body: returnBody(),
            bottomNavigationBar: returnBottomBar(),
          ),
        );
      },
    );
  }

  Widget returnBody() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _fileListView(leftFiles, -1),
        ),
        Expanded(
          child: _fileListView(rightFiles, 1),
        ),
      ],
    );
  }

  Widget returnBottomBar() {
    return Container(
      color: Color(0x44000000),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: CupertinoButton(
              child: Icon(Icons.add),
              onPressed: () {
                moreAction(-1);
              },
            ),
          ),
          Expanded(
            child: CupertinoButton(
              child: Icon(Icons.home),
              onPressed: () {
                new Operation(leftFiles, rightFiles, context,
                        uiShouldChange: uiShouldChange, mode: mode)
                    .initPathFiles(common.sDCardDir, -2);
              },
            ),
          ),
          Expanded(
            child: CupertinoButton(
              child: Icon(Icons.favorite),
              onPressed: () {
                listFavorite();
              },
            ),
          ),
          Expanded(
            child: CupertinoButton(
              child: Icon(Icons.add),
              onPressed: () {
                moreAction(1);
              },
            ),
          ),
        ],
      ),
    );
  }

  ///用于导航返回拦截器的onWillPop
  Future<bool> onWillPop() async {
    if (mode.parentDir.parent.path != common.sDCardDir &&
        mode.parentDir.path != common.sDCardDir) {
      /// 如果不是根目录,就跳转到上层目录并刷新目录
//      initPathFiles(parentDir.path, 2);
      new Operation(leftFiles, rightFiles, context,
              uiShouldChange: uiShouldChange, mode: mode)
          .initPathFiles(mode.parentDir.path, 2);
    } else {
      ///否则退出
      ///https://blog.csdn.net/weixin_33979203/article/details/88019065
      ///Router: 路由 对屏幕界面的抽象 每一个页面都有相应的Page
      print('退出时parentDir为:' + mode.parentDir.path);
      SystemNavigator.pop();
    }
    return false;
  }

  Widget _fileListView(List<FileSystemEntity> files, int type) {
    if (files.length == 0)
      return Center(child: Text('The folder is empty'));
    else {
      return Scrollbar(
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            //控制列表的滚动的发生方式(再列表结束时退回列表,iOS中有类似效果)
            controller: controller,
            itemCount: files.length,
            itemBuilder: (BuildContext context, int index) {
              if (FileSystemEntity.isFileSync(files[index].path))
                return _buildFileItem(files[index], type);
              else
                return _buildFolderItem(files[index], type);
            }),
      );
    }
  }

  /// 创建文件的ListTile
  Widget _buildFileItem(FileSystemEntity file, int type) {
    //获取文件最后改动日期
    String modifiledTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());
    FilePre fileIcon;
    fileIcon = ProxyFilePre(
      common,
      file,
      p.extension(file.path),
      50,
      70,
    );

    ///InkWell: 水波纹效果
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12)),
        ),
        child: ListTile(
          leading: fileIcon,
          title: Text(file.path.substring(file.parent.path.length + 1),
              style: TextStyle(fontSize: fileFontSize)),

          ///从文件路径中截取文件名字 (file.parent.length+1-文件父目录长度)
          subtitle: Text(
            '$modifiledTime ${common.getFileSize(file.statSync().size)}',
            style: TextStyle(fontSize: subTitleFontSize),
          ), //时间和文件大小
        ),
      ),
      onTap: () {
        OpenFile.open(file.path);
      },
      onLongPress: () {
        Container fileIconPre;
        FilePre filePre = ProxyFilePre(
          common,
          file,
          p.extension(file.path),
          MediaQuery.of(context).size.width / 2 - 40,
          MediaQuery.of(context).size.width / 2 - 40,
        );
        if (p.extension(file.path) == '.txt') {
          filePre = TxtFilePre(filePre);
          fileIconPre=Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0x22ffffff),
              // border: new Border.all(width: 1, color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            width: MediaQuery.of(context).size.width / 2,
            child:ListView(children: <Widget>[Text((filePre as TxtFilePre).getContent())],),
          );
        } else {
          fileIconPre = Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: filePre,
            ),
          );
        }
        showModalBottomSheet(
            backgroundColor: Color(0x00000000),
            context: context,
            builder: (BuildContext context) {
              return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      type == -1
                          ? Container(
                              width: 0,
                            )
                          : fileIconPre,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: type == -1
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: <Widget>[
                          RenameOperationButton(context, file, type, leftFiles,
                                  rightFiles, uiShouldChange, mode)
                              .returnButton(),
                          CopyOperationButton(context, file, type, mode)
                              .returnButton(),
                          CutOperationButton(context, file, type, mode)
                              .returnButton(),
                          AddToOperationButton(context, file, type)
                              .returnButton(),
                          RemoveFavOperation(context, file, type)
                              .returnButton(),
                          DeleteOperationButton(context, file, type, leftFiles,
                                  rightFiles, mode, uiShouldChange)
                              .returnButton(),
                        ],
                      ),
                      type == -1
                          ? fileIconPre
                          : Container(
                              width: 0,
                            ),
                    ],
                  ));
            });
      },
    );
  }

  Widget _buildFolderItem(FileSystemEntity file, int type) {
    String modifiledTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());
    //InkWell: 水波纹效果

    return Card(
      color: Color(0xff222222),
      elevation: 15.0,
      margin: EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
//            color: Colors.black,
//            border:
//                Border(bottom: BorderSide(width: 0.5, color: Colors.white)),
              ),
          child: ListTile(
              leading: Image.asset(
                'assets/images/folder.png',
                height: iconHeight,
                width: iconWidth,
              ),
              title: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                        file.path.substring(file.parent.path.length + 1),
                        style: TextStyle(fontSize: fileFontSize)),
                  ),
                ],
              ),
              subtitle: Text(
                modifiledTime,
                style: TextStyle(fontSize: subTitleFontSize),
              ),
              trailing: Icon(
                Icons.arrow_right,
                size: 12.0,
              )

              ///trailing: 和leading相对,最后面
              ),
        ),
        onTap: () {
          new Operation(leftFiles, rightFiles, context,
                  uiShouldChange: uiShouldChange, mode: mode)
              .initPathFiles(file.path, type);
        },
        onLongPress: () {
          showModalBottomSheet(
              backgroundColor: Color(0x00000000),
              context: context,
              builder: (BuildContext context) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: type == -1
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: <Widget>[
                        new RenameOperationButton(context, file, type,
                                leftFiles, rightFiles, uiShouldChange, mode)
                            .returnButton(),
                        new AddToOperationButton(context, file, type)
                            .returnButton(),
                        new RemoveFavOperation(context, file, type)
                            .returnButton(),
                        new DeleteOperationButton(context, file, type,
                                leftFiles, rightFiles, mode, uiShouldChange)
                            .returnButton(),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  Widget returnFileOperateButton(int cardColor,
      Function(FileSystemEntity file) fun, FileSystemEntity file) {
    return Container(
      width: 170,
      child: Card(
        color: Color(cardColor),
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 20),
        child: InkWell(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text('收藏', style: TextStyle(color: Colors.cyan)),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            fun(file);
          },
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////

  //粘贴要复制的文件
  //左右两边的加号
  void moreAction(int side) {
    String destinationDir = '';
    if (side == -1) {
      destinationDir = mode.parentDir.parent.path;
    } else {
      destinationDir = mode.parentDir.path;
    }
    showModalBottomSheet(
        backgroundColor: Color(0x00000000),
        context: context,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: side == -1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: <Widget>[
                  mode.copyMode | mode.cutMode
                      ? Column(
                          children: <Widget>[
                            Container(
                              width: 170,
                              child: Card(
                                margin: EdgeInsets.only(
                                    left: 5, right: 5, bottom: 20),
                                child: InkWell(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text('粘贴',
                                          style: TextStyle(color: Colors.blue)),
                                    ),
                                  ),
                                  onTap: () {
                                    print('copyTempFile-->file_manager:' +
                                        mode.copyTempFile.path.toString());
                                    if (mode.copyTempFile.statSync().type ==
                                        FileSystemEntityType.file) {
                                      String path = mode.copyTempFile.path;
                                      File temp = mode.copyTempFile;
                                      print('剪切的文件 ' + temp.path);
                                      temp.copy(destinationDir +
                                          '/' +
                                          temp.path.substring(
                                              temp.parent.path.length + 1));
                                      mode.copyTempFile = null; //复制之后取消复制模式
                                      if (mode.cutMode) {
                                        temp = File(path);
                                        temp.delete();
                                        print('删除' + temp.path);
                                      }
                                      if (side == -1) {
//                                        initPathFiles(parentDir.path, -3);
                                        new Operation(
                                                leftFiles, rightFiles, context,
                                                uiShouldChange: uiShouldChange,
                                                mode: mode)
                                            .initPathFiles(
                                                mode.parentDir.path, -3);
                                      } else {
//                                        initPathFiles(parentDir.path, -3);
                                        new Operation(
                                                leftFiles, rightFiles, context,
                                                uiShouldChange: uiShouldChange,
                                                mode: mode)
                                            .initPathFiles(
                                                mode.parentDir.path, -3);
                                      }
                                      mode.copyMode = false;
                                      mode.cutMode = false;
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                            Container(
                              width: 170,
                              child: Card(
                                margin: EdgeInsets.only(
                                    left: 5, right: 5, bottom: 20),
                                child: InkWell(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text('取消',
                                          style: TextStyle(
                                              color: Colors.cyanAccent)),
                                    ),
                                  ),
                                  onTap: () {
                                    mode.copyMode = false;
                                    mode.copyTempFile = null; //取消复制模式
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            )
                          ],
                        )
                      : Container(
                          width: 0,
                        ),
                  WidgetItem().returnFileOperateButton(context, cardColor,
                      (file, type) => null, '新建文件', null, null)
                ],
              ),
            ),
          );
        });
  }

  //切换favorite
  void listFavorite() {
    setState(() {
      leftFiles.clear();
      rightFiles.clear();
      if (common.favoriteFileList != null) {
        for (var fileItem in common.favoriteFileList) {
          print(fileItem);
          leftFiles.add(new File(fileItem));
        }
      }
    });
  }
}
