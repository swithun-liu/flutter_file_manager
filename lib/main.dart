import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Item/Common.dart';
import 'file_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //future: Future<T>对象--Dart内置,有自己的队列策略(EventQueue)
  //async: 异步,不阻塞当前进程,来等待该线程处理完任务再执行其他任务
  //await: 等待,声明运算为延迟进行
  Future<void> getSDCardDir() async {
    //插件path_provider提供函数getExternalStorageDirectory
    //获取SD卡根路径  path_provider提供方法
//    Common().sDCardDir = (await getExternalStorageDirectory()).path;
    Common().sDCardDir = '/storage/emulated/0';
    Common().favoriteDir=(await getExternalStorageDirectory()).path;

    try{
      File favoriteTxt=File(Common().favoriteDir+'/favorite.txt');
      if(await favoriteTxt.exists()){
        Common().favoriteAll=favoriteTxt.readAsStringSync();
        print('main.dart : 读取favourite.txt');
        Common().favoriteFileList=Common().favoriteAll.split('\n');
      }else{
        favoriteTxt.create();
        print('main.dart : 创建favourite.txt');
      }
    }catch(err){
      print(err);
    }
  }

  //获取权限函数
  Future<void> getPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      }
      await getSDCardDir();
    } else if (Platform.isIOS) {
      await getSDCardDir();
    }
  }

  //获取权限
  Future.wait([initializeDateFormatting("zh_CN", null), getPermission()])
      .then((result) {
    print('main.dart : '+Common().sDCardDir);
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness:Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: Colors.black,
      ),
      home: MyHome(),
    );
  }
}

