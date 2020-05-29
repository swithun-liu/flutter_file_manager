import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:neofilemanager/Item/Common.dart';
import 'package:neofilemanager/Item/Preview/FilePre.dart';

class RealFilePre extends FilePre {
  Common common;
  FileSystemEntity file;
  String extension;
  double iconHeight = 30.0;
  double iconWidth = 30.0;
  double fileHeight = 50.0;
  double fileWidth = 70.0;

  RealFilePre(this.common, this.file, this.extension,this.fileHeight,this.fileWidth);

  Widget build(BuildContext context) {
    if (extension == '.png' || extension == '.jpg' || extension == '.jpeg'||extension=='.gif') {
      print('RealFilePre创建图片');
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(file,
            height: fileHeight, width: fileWidth, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      common.selectIcon(extension),
      height: iconHeight,
      width: iconWidth,
    );
  }
}
