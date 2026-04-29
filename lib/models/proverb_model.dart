/// 谚语数据模型
class ProverbModel {
  final String sentence;    // 中文谚语
  final String pinyin;      // 拼音
  final String explanation; // 中文释义
  final String english;     // 英语翻译
  final String russian;     // 俄语翻译
  final String turkish;     // 土耳其语翻译
  final String arabic;      // 阿拉伯语翻译
  final String persian;     // 波斯语翻译
  final String indonesian;   // 印尼语翻译
  final String vietnamese;   // 越南语翻译
  final String khmer;        // 高棉语翻译

  const ProverbModel({
    required this.sentence,
    required this.pinyin,
    required this.explanation,
    required this.english,
    required this.russian,
    required this.turkish,
    required this.arabic,
    required this.persian,
    required this.indonesian,
    required this.vietnamese,
    required this.khmer,
  });

  /// 从 JSON Map 构造
  factory ProverbModel.fromJson(Map<String, dynamic> json) {
    return ProverbModel(
      sentence: json['sentence'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      english: json['en'] as String? ?? '',
      russian: json['ru'] as String? ?? '',
      turkish: json['tr'] as String? ?? '',
      arabic: json['ar'] as String? ?? '',
      persian: json['fa'] as String? ?? '',
      indonesian: json['id'] as String? ?? '',
      vietnamese: json['vi'] as String? ?? '',
      khmer: json['km'] as String? ?? '',
    );
  }

  /// 根据语言代码返回对应翻译
  String translationFor(String languageCode) {
    switch (languageCode) {
      case 'en':
        return english;
      case 'ru':
        return russian;
      case 'tr':
        return turkish;
      case 'ar':
        return arabic;
      case 'fa':
        return persian;
      case 'id':
        return indonesian;
      case 'vi':
        return vietnamese;
      case 'km':
        return khmer;
      default:
        return english;
    }
  }

  /// 作为收藏 ID（使用谚语文本本身，前缀避免与词语 ID 冲突）
  String get id => 'proverb:$sentence';
}
