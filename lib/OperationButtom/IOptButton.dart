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
  Mode mode;
  ValueNotifier<bool> uiShouldChange;

  IOptButton(this.context, this.file, this.type,
      {this.leftFiles, this.rightFiles, this.mode, this.uiShouldChange});

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
