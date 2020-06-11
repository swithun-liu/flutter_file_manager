import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neofilemanager/Item/Mode.dart';
import 'package:neofilemanager/OperationButtom/IOperateButtonBusiness.dart';

abstract class IOptButton implements IOptButtonBusiness {
  int cardColor = 0x22ffffff;
  FileSystemEntity file;
  int type;
  BuildContext context;
  Directory parentDir; //父目录
  List<FileSystemEntity> leftFiles = []; //左列的文件
  List<FileSystemEntity> rightFiles = []; //右列的文件
  Mode mode; // 接收传递过来的状态,用与判断执行何种操作
  ValueNotifier<bool> uiShouldChange; // 用来判断是否需要对UI重新刷新

  IOptButton(this.context, this.file, this.type,
      {this.leftFiles, this.rightFiles, this.mode, this.uiShouldChange});

  // 构建按钮的模板, 只有触发的方法不同
  Widget returnButton() {
    return Container(
      width: 170,
      child: Card(
        elevation: 0,
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
