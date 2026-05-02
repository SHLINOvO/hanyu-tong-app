import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'poetry_model.dart';

/// 诗词数据仓库
class PoetryRepository {
  /// 加载诗词列表（从多个分片文件加载并合并）
  static Future<List<PoetryModel>> loadPoetry() async {
    // Web 平台 assets 路径需要双重嵌套，原生平台只需单层
    final basePath = kIsWeb ? 'assets/assets/poetry/' : 'assets/poetry/';
    const fileNames = ['poetry_1.json', 'poetry_2.json'];

    final List<PoetryModel> allPoems = [];
    for (final name in fileNames) {
      final jsonString = await rootBundle.loadString('$basePath$name');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      allPoems.addAll(
        jsonList
            .map((item) => PoetryModel.fromJson(item as Map<String, dynamic>)),
      );
    }
    return allPoems;
  }
}
