import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'culture_model.dart';

/// 文化知识数据仓库
class CultureRepository {
  /// 加载文化知识列表（节气 + 节日）
  static Future<List<CultureModel>> loadCulture() async {
    // Web 平台 assets 路径需要双重嵌套，原生平台只需单层
    final basePath = kIsWeb ? 'assets/assets/culture/' : 'assets/culture/';
    final jsonString = await rootBundle.loadString('${basePath}culture.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    final List<dynamic> solarTerms = data['solar_terms'] as List<dynamic>? ?? [];
    final List<dynamic> festivals = data['festivals'] as List<dynamic>? ?? [];

    final List<CultureModel> result = [];

    // 先加载节气
    for (final item in solarTerms) {
      result.add(CultureModel.fromSolarTerm(item as Map<String, dynamic>));
    }

    // 再加载节日
    for (final item in festivals) {
      result.add(CultureModel.fromFestival(item as Map<String, dynamic>));
    }

    return result;
  }
}
