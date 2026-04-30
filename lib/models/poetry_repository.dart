import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'poetry_model.dart';

/// 诗词数据仓库
class PoetryRepository {
  /// 加载诗词列表
  static Future<List<PoetryModel>> loadPoetry() async {
    // Web 平台 assets 路径需要双重嵌套，原生平台只需单层
    final basePath = kIsWeb ? 'assets/assets/poetry/' : 'assets/poetry/';
    final jsonString = await rootBundle.loadString('${basePath}poetry.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => PoetryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
