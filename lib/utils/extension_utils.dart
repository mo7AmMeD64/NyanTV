import 'package:anymex/controllers/source/source_controller.dart';
import 'package:nyantv/stubs/extension_stubs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension ExtensionCarousel on Future<List<DMedia>> {}

extension ItemTypeExts on ItemType {
  bool get isAnime => this == ItemType.anime;

  List<Source> get extensions => sourceController.installedExtensions;
}

extension NavigatorExts on Widget {
  void go({BuildContext? context}) => Navigator.of(context ?? Get.context!)
      .push(MaterialPageRoute(builder: (context) => this));
}