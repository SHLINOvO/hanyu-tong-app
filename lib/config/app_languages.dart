// App 支持的语言配置
// 定义5种目标语言的完整信息
library;

import 'package:flutter/material.dart';

class AppLanguage {
  final String code;
  final String englishName;
  final String nativeName;
  final String country;
  final String flag;
  final bool isRTL;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.country,
    required this.flag,
    required this.isRTL,
  });

  Locale get locale => Locale(code);
}

// 支持的5种语言列表
const List<AppLanguage> supportedLanguages = [
  AppLanguage(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    country: 'United States',
    flag: '🇺🇸',
    isRTL: false,
  ),
  AppLanguage(
    code: 'ru',
    englishName: 'Russian',
    nativeName: 'Русский',
    country: 'Russia',
    flag: '🇷🇺',
    isRTL: false,
  ),
  AppLanguage(
    code: 'fa',
    englishName: 'Persian',
    nativeName: 'فارسی',
    country: 'Iran',
    flag: '🇮🇷',
    isRTL: true,
  ),
  AppLanguage(
    code: 'ar',
    englishName: 'Arabic',
    nativeName: 'العربية',
    country: 'Saudi Arabia',
    flag: '🇸🇦',
    isRTL: true,
  ),
  AppLanguage(
    code: 'tr',
    englishName: 'Turkish',
    nativeName: 'Türkçe',
    country: 'Turkey',
    flag: '🇹🇷',
    isRTL: false,
  ),
  AppLanguage(
    code: 'id',
    englishName: 'Indonesian',
    nativeName: 'Bahasa Indonesia',
    country: 'Indonesia',
    flag: '🇮🇩',
    isRTL: false,
  ),
  AppLanguage(
    code: 'vi',
    englishName: 'Vietnamese',
    nativeName: 'Tiếng Việt',
    country: 'Vietnam',
    flag: '🇻🇳',
    isRTL: false,
  ),
  AppLanguage(
    code: 'km',
    englishName: 'Khmer',
    nativeName: 'ភាសាខ្មែរ',
    country: 'Cambodia',
    flag: '🇰🇭',
    isRTL: false,
  ),
];

// 语言代码到语言对象的映射
final Map<String, AppLanguage> languageMap = {
  for (var lang in supportedLanguages) lang.code: lang,
};

// 获取语言信息
AppLanguage? getLanguage(String code) {
  return languageMap[code];
}

// 检查是否为支持的语种
bool isLanguageSupported(String code) {
  return languageMap.containsKey(code);
}

// 获取默认语言（英语）
AppLanguage get defaultLanguage => languageMap['en']!;

// 获取所有支持的 Locale
List<Locale> get supportedLocales {
  return supportedLanguages.map((lang) => lang.locale).toList();
}

// RTL语言代码列表
const Set<String> rtlLanguageCodes = {'fa', 'ar'};

// 检查是否为RTL语言
bool isRTL(String languageCode) {
  return rtlLanguageCodes.contains(languageCode);
}

// 获取文字方向
TextDirection getTextDirection(String languageCode) {
  return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
}