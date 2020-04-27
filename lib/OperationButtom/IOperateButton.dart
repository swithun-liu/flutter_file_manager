import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class IOperateButton{

  int cardColor;
  String titleText;
  Color color;
  FileSystemEntity file;
  int type;
  BuildContext context;
  Directory parentDir; //父目录
  List<FileSystemEntity> leftFiles = []; //左列的文件
  List<FileSystemEntity> rightFiles = []; //右列的文件


  Widget returnButton();//返回bytton
  void fun(FileSystemEntity file,int type);//onTap的函数
}
