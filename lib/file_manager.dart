import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

import 'Common.dart';

class MyHome extends StatefulWidget {
  MyHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHome> {
  List<FileSystemEntity> leftFiles = []; //左列的文件
  List<FileSystemEntity> rightFiles = []; //右列的文件

  int _selectedIndex=-1;
  double iconHight = 40.0;
  double iconWidth = 40.0;
  double fileFontSize = 10.0;
  double subTitleFontSize = 8.0;
  Directory parentDir; //父目录
  ScrollController controller = ScrollController();
  List<double> position = [];

  ///初始化: 拿到根路径 刷新目录
  @override
  void initState() {
    super.initState();
    parentDir = Directory(Common().sDCardDir); //获取根路径
    initPathFiles(Common().sDCardDir, -2); //刷新左列目录
  }

  ///用于导航返回拦截器的onWillPop
  Future<bool> onWillPop() async {
    if (parentDir.parent.path != Common().sDCardDir) {
      /// 如果不是根目录,就跳转到上层目录并刷新目录
      initPathFiles(parentDir.path, 2);
    } else {
      ///否则退出
      ///https://blog.csdn.net/weixin_33979203/article/details/88019065
      ///Router: 路由 对屏幕界面的抽象 每一个页面都有相应的Page
      print('退出时parentDir为:' + parentDir.path);
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            parentDir?.path == Common().sDCardDir
                ? 'SD card'
                : p.basename(parentDir.path),
          ),
          centerTitle: true,
          elevation: 5.0,
          //浮起来的高度
          leading: parentDir?.path == Common().sDCardDir
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                  ),
                  onPressed: onWillPop,
                ), //再标题前面显示的一个控件
        ),
        body: Row(
          children: <Widget>[
            Expanded(
              child: _fileListView(leftFiles, -1),
            ),
            Expanded(
              child: _fileListView(rightFiles, 1),
            )
          ],
        ),
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: Colors.black,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.star),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu),
            )
          ],
          currentIndex:_selectedIndex,
          onTap: (int a){
            setState(() {
              _selectedIndex = a;
            });
            print('按了'+a.toString());
          },
        ),
      ),
    );
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

    ///InkWell: 水波纹效果
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border:
              Border(bottom: BorderSide(width: 0.5,color: Colors.black12)),
        ),
        child: ListTile(
          leading: Image.asset(
            Common().selectIcon(p.extension(file.path)),
            height: 40.0,
            width: 40.0,
          ),
          title: Text(file.path.substring(file.parent.path.length + 1),
              style: TextStyle(fontSize: fileFontSize)),
          ///从文件路径中截取文件名字 (file.parent.length+1-文件父目录长度)
          subtitle: Text(
            '$modifiledTime ${Common().getFileSize(file.statSync().size)}',
            style: TextStyle(fontSize: subTitleFontSize),
          ), //时间和文件大小
        ),
      ),
      onTap: () {
        OpenFile.open(file.path);
      },
      onLongPress: () {
        showModalBottomSheet(
            backgroundColor: Color(0x00000000),
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: type == -1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 170,
                    child: Card(
                      margin: EdgeInsets.only(
                          left: 5, right: 5, top: 20, bottom: 20),
                      child: InkWell(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('重命名',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ),
                        onTap: () {
                          renameFile(file, type);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 170,
                    child: Card(
                      margin: EdgeInsets.only(left: 5, right: 5,bottom: 20),
                      child: InkWell(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('收藏',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ),
                        onTap: () {
                          addToFavorite(file);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 170,
                    child: Card(
                      margin: EdgeInsets.only(left: 5, right: 5,bottom: 50),
                      child: InkWell(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('删除',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ),
                        onTap: () {
                          deleteFile(file, type);
                        },
                      ),
                    ),
                  )
                ],
              );
            });
      },
    );
  }

  Widget _buildFolderItem(FileSystemEntity file, int type) {
    String modifiledTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());
    //InkWell: 水波纹效果
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border:
              Border(bottom: BorderSide(width: 0.5,color: Colors.black12)),
        ),
        child: ListTile(
          leading: Image.asset(
            'assets/images/folder.png',
            height: 40.0,
            width: 40.0,
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(file.path.substring(file.parent.path.length + 1),
                    style: TextStyle(fontSize: fileFontSize)),
              ),
            ],
          ),
          subtitle: Text(
            modifiledTime,
            style: TextStyle(fontSize: subTitleFontSize),
          ),
          trailing: Icon(Icons.chevron_right),

          ///trailing: 和leading相对,最后面
        ),
      ),
      onTap: () {
        initPathFiles(file.path, type);
      },
      onLongPress: () {
        showModalBottomSheet(
            backgroundColor: Color(0x00000000),
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: type == -1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 170,
                    child: Card(
                      margin: EdgeInsets.only(
                          left: 5, right: 5, top: 20, bottom: 20),
                      child: InkWell(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('重命名',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ),
                        onTap: () {
                          renameFile(file, type);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 170,
                    child: Card(
                      margin: EdgeInsets.only(left: 5, right: 5,bottom: 20),
                      child: InkWell(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('收藏',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ),
                        onTap: () {
                          addToFavorite(file);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 170,
                    child: Card(
                      margin: EdgeInsets.only(left: 5, right: 5, bottom: 50),
                      child: InkWell(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('删除',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ),
                        onTap: () {
                          deleteFile(file, type);
                        },
                      ),
                    ),
                  )
                ],
              );
            });
      },
    );
  }

  //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////

  void addToFavorite(FileSystemEntity file){
    try{
      File favoriteTxt=File(Common().favoriteDir+'/favorite.txt');
      print('最开始'+Common().favoriteAll);
      Common().favoriteAll=Common().favoriteAll+'\n'+file.path.toString();
      Common().favoriteFileList.add(file.path.toString());
      favoriteTxt.writeAsStringSync(Common().favoriteAll);
      print('收藏'+file.path);
    }catch(err){
      print('错误信息'+err.toString());
    }
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context){
          return CupertinoAlertDialog(
            title: Text('添加成功'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('确定'),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
          Navigator.pop(context);
        }
    );
  }
//  删除文件
  void deleteFile(FileSystemEntity file, int type) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('重命名'),
            content: Text('删除后不可恢复'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  '取消',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  '确定',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  if (file.statSync().type == FileSystemEntityType.directory) {
                    Directory directory = Directory(file.path);
                    directory.deleteSync(recursive: true);
                  } else if (file.statSync().type ==
                      FileSystemEntityType.file) {
                    file.deleteSync();
                  }
                  if (type == -1) {
                    initPathFiles(file.path, -3);
                  } else {
                    initPathFiles(file.parent.path, type);
                  }
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

//重命名文件
  void renameFile(FileSystemEntity file, int type) {
    TextEditingController _controller = TextEditingController();

    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CupertinoAlertDialog(
                title: Text('重命名'),
                content: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '请输入新名称',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(width: 0.3)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(width: 0.5)),
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                  ),
                ),
                actions: <Widget>[
                  CupertinoButton(
                    child: Text(
                      '取消',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Text(
                      '确认',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () async {
                      String newName = _controller.text;
                      if (newName.trim().length == 0) {
                        Fluttertoast.showToast(
                            msg: '名字不能为空', gravity: ToastGravity.BOTTOM);
                        return;
                      }
                      String newPath = "";
                      if (file.statSync().type == FileSystemEntityType.file) {
                        newPath = file.parent.path +
                            '/' +
                            newName +
                            p.extension(file.path);
                      } else {
                        newPath = file.parent.path + '/' + newName;
                      }
                      file.renameSync(newPath);
                      if (type == -1) {
                        initPathFiles(newPath, -3);
                      } else {
                        initPathFiles(file.parent.path, type);
                      }
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  ///用传来的路径刷新该目录下的文件.文件夹
  void initPathFiles(String path, int type) {
    try {
      //可变的Widget可以使用setState()函数--重新绘制试图--调用build方法--绘制不一样的地方
      setState(() {
        parentDir = Directory(path);
        print('parentDir 更改为' + parentDir.path);
        if (type == -1) {
          //点击左列
          //刷新右列表
          sortFile(parentDir, -1);
        } else if (type == 1) {
          //点击右列
          //往右走 先刷右列表 再刷左列表
          sortFile(parentDir, -1);
          sortFile(parentDir.parent, 1);
        } else if (type == -2) {
          //初始化
          sortFile(parentDir, 1);
        } else if (type == 2) {
          //返回时
          sortFile(parentDir.parent, -1);
          sortFile(parentDir.parent.parent, 1);
          parentDir = parentDir.parent;
        } else if (type == -3) {
          //左列重命名文件夹
          sortFile(parentDir.parent, 1);
          sortFile(parentDir, -1);
        }
      });
    } catch (e) {
      print(e);
      print("Directory does not exist");
    }
  }

  ///目录排序
  void sortFile(Directory parentDir, int type) {
    List<FileSystemEntity> _Files = [];
    List<FileSystemEntity> _Folders = [];
    //parenDire--路径
    //Directory.listSync 会列出当前目录下所有的文件和文件夹
    for (var v in parentDir.listSync()) {
      //去除.开头的文件/文件夹
      if (p.basename(v.path).substring(0, 1) == '.') {
        continue;
      }
      if (FileSystemEntity.isFileSync(v.path))
        _Files.add(v);
      else
        _Folders.add(v);
    }
    _Files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    _Folders.sort(
        (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    if (type == -1) {
      //刷新右列
      rightFiles.clear();
      rightFiles.addAll(_Folders);
      rightFiles.addAll(_Files);
    } else {
      //刷新左列
      leftFiles.clear();
      leftFiles.addAll(_Folders);
      leftFiles.addAll(_Files);
    }
  }

  //目录跳转
  void jumpToPosition(bool isEnter) async {
    if (isEnter) {
      controller.jumpTo(0.0);
    } else {
      try {
        await Future.delayed(Duration(milliseconds: 1));
        // "?" 的作用: 标示对象可以是 null
        controller?.jumpTo(position[position.length - 1]);
      } catch (e) {
        position.removeLast();
      }
    }
  }
}
