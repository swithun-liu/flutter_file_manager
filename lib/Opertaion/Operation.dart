import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as p;

import '../Item/Common.dart';
import '../Item/Mode.dart';

class Operation {
//  Directory parentDir; //父目录
  List<FileSystemEntity> leftFiles = []; //左列的文件
  List<FileSystemEntity> rightFiles = []; //右列的文件
  BuildContext context;
  ValueNotifier<bool> uiShouldChange;
  Mode mode;

  Operation(
      this.leftFiles, this.rightFiles, this.context,{ this.uiShouldChange,this.mode});

  //重命名文件
  void renameFile(FileSystemEntity file, int type) {
    TextEditingController _controller = TextEditingController();
    if (context == null) {
      print('context为null2');
    }

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

  //用传来的路径刷新该目录下的文件.文件夹
  void initPathFiles(String path, int type) {
    try {
      //可变的Widget可以使用setState()函数--重新绘制试图--调用build方法--绘制不一样的地方
      //-1: 右列-->父目录下  (点了左边列表,刷新右边列表,parentDir时左边的)
      // 1: 右列-->父目录下  (点了右列的文件夹的情况,parenDir换成了右边的)
      //    左列-->父目录同级
      //-2: 左列-->当前父目录下 (初始化时,用sdcard刷线左列)
      // 2: 右列-->父目录同级   (按了返回键)
      //    左列-->父目录的父目录同级
      //-3: 左列-->父目录同级  (原地刷新)
      //    右列-->父目录下
      mode.parentDir = Directory(path);
      print('parentDir 更改为' + mode.parentDir.path);
      if (type == -1) {
        //点击左列
        //刷新右列表
        sortFile(mode.parentDir, -1);
      } else if (type == 1) {
        //点击右列
        //往右走 先刷右列表 再刷左列表
        sortFile(mode.parentDir, -1);
        sortFile(mode.parentDir.parent, 1);
      } else if (type == -2) {
        //初始化
        sortFile(mode.parentDir, 1);
      } else if (type == 2) {
        //返回时
        sortFile(mode.parentDir.parent, -1);
        sortFile(mode.parentDir.parent.parent, 1);
        mode.parentDir = mode.parentDir.parent;
      } else if (type == -3) {
        //左列重命名文件夹
        sortFile(mode.parentDir.parent, 1);
        sortFile(mode.parentDir, -1);
      }
    } catch (e) {
      print(e);
      print("Directory does not exist");
    }
    changeUI();
  }

  void changeUI(){
    if(uiShouldChange==null){
      print('uiShouldChange is null');
    }
    if(uiShouldChange.value){
      uiShouldChange.value=false;
    }else{
      uiShouldChange.value = true;
    }
  }

  //目录排序
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
    changeUI();
  }

  //文件是否在favorite中
  bool isInFavorite(String filePath) {
    bool flag = false;
    for (var fileItem in Common().favoriteFileList) {
      if (fileItem == filePath) {
        flag = true;
      }
    }
    return flag;
  }

  //将更新后的喜爱条目写回文件
  void writeIntoLocal() {
    String temp = '';
    int i = 0;
    for (var item in Common().favoriteFileList) {
      print('写入' + item);
      if (i == 0) {
        temp = item.toString();
      } else {
        temp = temp + '\n' + item.toString();
      }
      i++;
    }
    Common().favoriteAll = temp;
    try {
      File favoriteTxt = File(Common().favoriteDir + '/favorite.txt');
      favoriteTxt.writeAsStringSync(Common().favoriteAll);
    } catch (err) {
      print('错误信息' + err.toString());
    }
  }

  void copyToDir(FileSystemEntity file, int type) {
    mode.cutMode = false;
    mode.copyMode = true;
    mode.copyTempFile = file;
  }
  //剪切文件到
  void cutToDir(FileSystemEntity file, int type) {
    mode.copyMode = false;
    mode.cutMode = true;
    mode.copyTempFile = file;
  }
  //从favorite中移除
  void removeFavorite(FileSystemEntity file, int type) {
    bool flag = isInFavorite(file.path);
      if (flag) {
        //如果要取消收藏的文件在favorite条目中存在
        int i = 0;
        //从Common中的喜爱条目中删除它
        for (var item in Common().favoriteFileList) {
          print(i.toString() + '  ' + item.toString());
          if (item.toString() == file.path) {
            Common().favoriteFileList.removeAt(i);
            break;
          }
          i++;
        }
        //将更新后的喜爱条目写回文件
        writeIntoLocal();
        changeUI();
      }
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(flag ? '已取消收藏' : '取消收藏失败'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('确定'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
          Navigator.pop(context);
        });
  }
  //删除文件
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
                  String temp = file.parent.path;
                  if (file.statSync().type == FileSystemEntityType.directory) {
                    Directory directory = Directory(file.path);
                    directory.deleteSync(recursive: true);
                  } else if (file.statSync().type ==
                      FileSystemEntityType.file) {
                    file.deleteSync();
                  }
                  //TODO
                  if (type == -1) {
                    //删除了左边的文件
                      sortFile(Directory(temp), 1);
                  } else if (type == 1) {
                    //删除了右边的文件
                    initPathFiles(mode.parentDir.path, -1);
                  }
                  changeUI();
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}
