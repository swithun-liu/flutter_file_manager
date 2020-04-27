import 'dart:io';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/Item/Mode.dart';
import 'package:neofilemanager/OperationButtom/IOperateButton.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';

class CutOperationButton implements IOperateButton{
  @override
  int cardColor= 0x22ffffff;

  @override
  Color color=Colors.lightBlue;

  @override
  BuildContext context;

  @override
  FileSystemEntity file;

  @override
  List<FileSystemEntity> leftFiles;

  @override
  Directory parentDir;

  @override
  List<FileSystemEntity> rightFiles;

  @override
  String titleText='剪切2';

  @override
  int type;

  Mode mode;

  CutOperationButton(this.context,this.file,this.type,this.mode);

  @override
  void fun(FileSystemEntity file, int type) {
    new Operation(leftFiles, rightFiles, context,mode: mode).cutToDir(file, type);
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