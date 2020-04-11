import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetItem {
  factory WidgetItem() => _getInstance();

  static WidgetItem _instance;

  static WidgetItem _getInstance() {
    if (_instance == null) {
      _instance = WidgetItem._internal();
    }
    return _instance;
  }

  WidgetItem._internal();

  Widget returnFileOperateButton(BuildContext context, int cardColor,
      Function(FileSystemEntity file,int type) fun,String titleText,FileSystemEntity file,int type) {
    Color color;
    switch(titleText){
      case '删除':
        color=Colors.blueGrey;
        break;
      case '重命名':
        color=Colors.blue;
        break;
      case '复制':
        color=Colors.blueAccent;
        break;
      case '剪切':
        color=Colors.lightBlue;
        break;
      case '收藏':
        color=Colors.cyan;
        break;
      case '取消收藏':
        color=Colors.cyanAccent;
        break;
    }
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
            fun(file,type);
          },
        ),
      ),
    );
  }
}
