import 'dart:convert';
import 'package:flutter/services.dart';
import 'idiom_model.dart';

/// 成语数据仓库
class IdiomRepository {
  /// 加载成语列表
  static Future<List<IdiomModel>> loadIdioms() async {
    final jsonString = await rootBundle.loadString('assets/assets/idioms/idioms.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => IdiomModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
