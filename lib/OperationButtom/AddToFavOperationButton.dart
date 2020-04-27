import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'file:///D:/a-Projects/AndroidStudioProjects/FLUTTER/neo_file_manager/lib/OperationButtom/IOperateButton.dart';

import '../Item/Common.dart';

class AddToOperationButton implements IOperateButton {
  @override
  int cardColor = 0x22ffffff;

  @override
  Color color = Colors.cyan;

  @override
  String titleText = '收藏2';

  @override
  FileSystemEntity file;

  @override
  int type;

  @override
  BuildContext context;
  @override
  Directory parentDir; //父目录
  @override
  List<FileSystemEntity> leftFiles = []; //左列的文件
  @override
  List<FileSystemEntity> rightFiles = []; //右列的文件

  AddToOperationButton(this.context, this.file, this.type,
      {this.parentDir, this.leftFiles, this.rightFiles});

  @override
  void fun(FileSystemEntity file, int type) {
    //添加到favorite
    bool flag = isInFavorite(file.path);
    if (!flag) {
      try {
        File favoriteTxt = File(Common().favoriteDir + '/favorite.txt');
        favoriteTxt.copy(Common().sDCardDir + '/1/test.txt');
        if (Common().favoriteAll.length > 0) {
          Common().favoriteAll =
              Common().favoriteAll + '\n' + file.path.toString();
        } else {
          Common().favoriteAll = Common().favoriteAll + file.path.toString();
        }
        Common().favoriteFileList.add(file.path.toString());
        favoriteTxt.writeAsStringSync(Common().favoriteAll);
        print('收藏' + file.path);
      } catch (err) {
        print('错误信息' + err.toString());
      }
    }
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(flag ? '条目已存在' : '添加成功'),
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

  @override
  Widget returnButton() {
    return Container(
      width: 170,
      child: Card(
        color: Color(cardColor),
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 20),
        child: InkWell(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(titleText, style: TextStyle(color: color)),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            fun(file, type);
          },
        ),
      ),
    );
  }
}
