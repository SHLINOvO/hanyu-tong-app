/// 文化知识数据模型（节气 + 节日）
class CultureModel {
  final String name;           // 名称（如：立春、春节）
  final String? date;          // 日期（仅节日有，如：正月初一）
  final String chinese;        // 中文释义
  final String en;             // 英语翻译
  final String ru;             // 俄语翻译
  final String tr;             // 土耳其语翻译
  final String fa;             // 波斯语翻译
  final String ar;             // 阿拉伯语翻译
  final String indonesian;     // 印尼语翻译
  final String vietnamese;     // 越南语翻译
  final String khmer;          // 高棉语翻译
  final bool isFestival;       // 是否为节日（区分节气和节日）

  const CultureModel({
    required this.name,
    this.date,
    required this.chinese,
    required this.en,
    required this.ru,
    required this.tr,
    required this.fa,
    required this.ar,
    required this.indonesian,
    required this.vietnamese,
    required this.khmer,
    this.isFestival = false,
  });

  /// 从 JSON Map 构造（节气）
  factory CultureModel.fromSolarTerm(Map<String, dynamic> json) {
    return CultureModel(
      name: json['name'] as String? ?? '',
      chinese: json['chinese'] as String? ?? '',
      en: json['en'] as String? ?? '',
      ru: json['ru'] as String? ?? '',
      tr: json['tr'] as String? ?? '',
      fa: json['fa'] as String? ?? '',
      ar: json['ar'] as String? ?? '',
      indonesian: json['id'] as String? ?? '',
      vietnamese: json['vi'] as String? ?? '',
      khmer: json['km'] as String? ?? '',
      isFestival: false,
    );
  }

  /// 从 JSON Map 构造（节日）
  factory CultureModel.fromFestival(Map<String, dynamic> json) {
    return CultureModel(
      name: json['name'] as String? ?? '',
      date: json['date'] as String?,
      chinese: json['chinese'] as String? ?? '',
      en: json['en'] as String? ?? '',
      ru: json['ru'] as String? ?? '',
      tr: json['tr'] as String? ?? '',
      fa: json['fa'] as String? ?? '',
      ar: json['ar'] as String? ?? '',
      indonesian: json['id'] as String? ?? '',
      vietnamese: json['vi'] as String? ?? '',
      khmer: json['km'] as String? ?? '',
      isFestival: true,
    );
  }

  /// 中文原文显示文本
  String get displayText {
    if (isFestival && date != null && date!.isNotEmpty) {
      return '$name（$date）';
    }
    return name;
  }

  /// 根据语言代码返回对应翻译
  String translationFor(String languageCode) {
    switch (languageCode) {
      case 'en':
        return en;
      case 'ru':
        return ru;
      case 'tr':
        return tr;
      case 'ar':
        return ar;
      case 'fa':
        return fa;
      case 'id':
        return indonesian;
      case 'vi':
        return vietnamese;
      case 'km':
        return khmer;
      default:
        return en;
    }
  }

  /// 作为唯一 ID
  String get id => isFestival ? 'festival_$name' : 'term_$name';
}
