import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/OperationButtom/IOptButton.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';
import 'file:///D:/a-Projects/AndroidStudioProjects/FLUTTER/neo_file_manager/lib/OperationButtom/IOperateButtonBusiness.dart';

import '../Item/Common.dart';

class AddToOperationButton extends IOptButton {
  @override
  Color color = Colors.cyan;

  @override
  String titleText = '收藏';

  AddToOperationButton(BuildContext context, FileSystemEntity file, int type)
      : super(context, file, type);

//  AddToOperationButton(this.context, this.file, this.type, {this.parentDir, this.leftFiles, this.rightFiles});

  @override
  void fun(FileSystemEntity file, int type) {
    new Operation(leftFiles, rightFiles, context).addToFavorite(file, type);
  }
}
