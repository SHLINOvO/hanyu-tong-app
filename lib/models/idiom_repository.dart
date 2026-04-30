import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'idiom_model.dart';

/// 成语数据仓库
class IdiomRepository {
  /// 加载成语列表
  static Future<List<IdiomModel>> loadIdioms() async {
    // Web 平台 assets 路径需要双重嵌套，原生平台只需单层
    final basePath = kIsWeb ? 'assets/assets/idioms/' : 'assets/idioms/';
    final jsonString = await rootBundle.loadString('${basePath}idioms.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => IdiomModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
