import 'dart:io';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';
import 'file:///D:/a-Projects/AndroidStudioProjects/FLUTTER/neo_file_manager/lib/OperationButtom/IOperateButton.dart';

import '../Item/Common.dart';

class RemoveFavOperation implements IOperateButton{
  @override
  int cardColor = 0x22ffffff;

  @override
  Color color=Colors.cyanAccent;

  @override
  BuildContext context;

  @override
  FileSystemEntity file;

  @override
  String titleText='取消收藏2';

  @override
  int type;

  @override
  Directory parentDir; //父目录
  @override
  List<FileSystemEntity> leftFiles = []; //左列的文件
  @override
  List<FileSystemEntity> rightFiles = []; //右列的文件

  RemoveFavOperation(this.context, this.file, this.type,{this.parentDir,this.leftFiles,this.rightFiles});

  @override
  void fun(FileSystemEntity file, int type) {
    new Operation(leftFiles, rightFiles, context).removeFavorite(file, type);
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