import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'proverb_model.dart';

/// 谚语数据仓库
class ProverbRepository {
  /// 加载谚语列表
  static Future<List<ProverbModel>> loadProverbs() async {
    // Web 平台 assets 路径需要双重嵌套，原生平台只需单层
    final basePath = kIsWeb ? 'assets/assets/proverb_saying/' : 'assets/proverb_saying/';
    final jsonString = await rootBundle.loadString('${basePath}proverb_saying.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => ProverbModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
