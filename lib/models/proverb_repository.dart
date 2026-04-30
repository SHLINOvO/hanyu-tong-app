import 'dart:convert';
import 'package:flutter/services.dart';
import 'proverb_model.dart';

/// 谚语数据仓库
class ProverbRepository {
  /// 加载谚语列表
  static Future<List<ProverbModel>> loadProverbs() async {
    final jsonString = await rootBundle.loadString('assets/assets/proverb_saying/proverb_saying.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => ProverbModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
