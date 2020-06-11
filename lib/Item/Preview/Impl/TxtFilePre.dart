
import 'dart:io';

import 'package:neofilemanager/Item/Preview/Impl/FilePreDecrator.dart';
import 'package:neofilemanager/Item/Preview/Impl/ProxyFilePre.dart';

class TxtFilePre extends FilePreDecrator{
  TxtFilePre(ProxyFilePre filePre) : super(filePre);
  // 读取txt内容
  String getContent(){
    File file=File(filePre.file.path);
    var content=file.readAsStringSync();
    print(content);
    return content;
  }
}