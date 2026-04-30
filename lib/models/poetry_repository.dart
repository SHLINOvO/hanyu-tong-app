import 'dart:convert';
import 'package:flutter/services.dart';
import 'poetry_model.dart';

/// 诗词数据仓库
class PoetryRepository {
  /// 加载诗词列表
  static Future<List<PoetryModel>> loadPoetry() async {
    final jsonString = await rootBundle.loadString('assets/assets/poetry/poetry.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => PoetryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
