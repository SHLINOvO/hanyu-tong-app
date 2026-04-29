/// 诗词数据模型
class PoetryModel {
  final String title;          // 诗题
  final String author;         // 作者
  final String dynasty;        // 朝代
  final String content;        // 诗词原文
  final String chineseMeaning; // 中文释义
  final String english;        // 英语翻译
  final String russian;        // 俄语翻译
  final String turkish;        // 土耳其语翻译
  final String arabic;         // 阿拉伯语翻译
  final String persian;        // 波斯语翻译
  final String indonesian;     // 印尼语翻译
  final String vietnamese;     // 越南语翻译
  final String khmer;         // 高棉语翻译

  const PoetryModel({
    required this.title,
    required this.author,
    required this.dynasty,
    required this.content,
    required this.chineseMeaning,
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
  factory PoetryModel.fromJson(Map<String, dynamic> json) {
    // "title" "author" "dynasty" "content" 合并为中文原文显示
    final title = json['title'] as String? ?? '';
    final author = json['author'] as String? ?? '';
    final dynasty = json['dynasty'] as String? ?? '';
    final content = json['content'] as String? ?? '';
    final chineseMeaning = json['chinese_meaning'] as String? ?? '';

    // translations 嵌套对象
    final translations = json['translations'] as Map<String, dynamic>? ?? {};
    final english = translations['en'] as String? ?? '';
    final russian = translations['ru'] as String? ?? '';
    final turkish = translations['tr'] as String? ?? '';
    final arabic = translations['ar'] as String? ?? '';
    final persian = translations['fa'] as String? ?? '';
    final indonesian = translations['id'] as String? ?? '';
    final vietnamese = translations['vi'] as String? ?? '';
    final khmer = translations['km'] as String? ?? '';

    return PoetryModel(
      title: title,
      author: author,
      dynasty: dynasty,
      content: content,
      chineseMeaning: chineseMeaning,
      english: english,
      russian: russian,
      turkish: turkish,
      arabic: arabic,
      persian: persian,
      indonesian: indonesian,
      vietnamese: vietnamese,
      khmer: khmer,
    );
  }

  /// 中文原文显示文本（标题 + 朝代·作者 + 内容）
  String get displayText {
    final header = '《$title》\n$dynasty · $author\n';
    return '$header$content';
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

  /// 作为收藏 ID（使用诗题，前缀避免与其他类型 ID 冲突）
  String get id => 'poem:$title';
}
