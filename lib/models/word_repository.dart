import 'dart:convert';
import 'package:flutter/services.dart';
import 'word_model.dart';

/// 词语数据仓库
class WordRepository {
  /// 根据难度加载词语列表
  /// level: 'beginner' | 'elementary' | 'intermediate' | 'advanced'
  static Future<List<WordModel>> loadWords(String level) async {
    final fileName = _levelToFileName(level);
    final jsonString = await rootBundle.loadString('assets/assets/words/$fileName');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((item) => WordModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 难度 → JSON 文件名映射
  static String _levelToFileName(String level) {
    switch (level) {
      case 'beginner':
        return 'hsk1_2.json';
      case 'elementary':
        return 'hsk3_4.json';
      case 'intermediate':
        return 'hsk5_6.json';
      case 'advanced':
        return 'hsk7_9.json';
      default:
        return 'hsk1_2.json';
    }
  }
}
