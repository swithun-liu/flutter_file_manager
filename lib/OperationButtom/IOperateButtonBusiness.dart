import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class IOptButtonBusiness {
  String titleText;
  Color color;

  Widget returnButton(); //返回bytton
  void fun(FileSystemEntity file, int type); //onTap的函数
}
