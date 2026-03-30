// 应用本地化类
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Chinese Go',
      'selectNativeLanguage': 'What language do you use to learn Chinese?',
      'pleaseSelect': 'Please select your native language',
      'confirm': 'Confirm',
      'chooseNativeLanguage': 'Choose Native Language',
      'dailyGoalMinutes': 'Daily Goal (minutes)',
      'minutes': 'minutes',
      // 首页
      'home': 'Home',
      'learning': 'Learning',
      'profile': 'Profile',
      'todayLearningTime': 'Today Learning Time',
      'wordsMastered': 'Words Mastered',
      'sentencesMastered': 'Sentences Mastered',
      'advancedMastered': 'Advanced Mastered',
      'continueLearning': 'Continue Learning',
      'words': 'Words',
      'sentences': 'Sentences',
      'advanced': 'Advanced',
      'listening': 'Listening',
      'review': 'Review',
      'favorites': 'Favorites',
      // home_tab.dart中的文本
      'mastered': 'Mastered',
      'streakLabel': 'Day Streak',
      'totalDaysLabel': 'Total Days',
      'totalHoursLabel': 'Learning Hours',
      'wordsLabel': 'Words',
      'sentencesLabel': 'Sentences',
      'advancedLabel': 'Advanced',
      'unitDay': 'day',
      'unitDays': 'days',
      'unitHour': 'hour',
      'unitHours': 'hours',
      'unitItem': 'item',
      'unitItems': 'items',
      'myFavorites': 'My Favorites',
      // learn_tab.dart中的文本
      'beginnerLevel': 'Beginner',
      'elementaryLevel': 'Elementary',
      'intermediateLevel': 'Intermediate',
      'advancedLevelName': 'Advanced',
      'currentLevelLabel': 'Current Level',
      'wordsPractice': 'Words Practice',
      'sentencesPractice': 'Sentences Practice',
      'grammarLearning': 'Grammar Learning',
      'listeningPractice': 'Listening Practice',
      'advancedReading': 'Advanced Reading · Chinese Culture',
      'idioms': 'Idioms',
      'proverbs': 'Proverbs/Sayings',
      'poetry': 'Poetry',
      'culture': 'Cultural Knowledge',
      'auxiliaryMaterials': 'Auxiliary Learning Materials',
      'hskOutline': 'HSK Exam Outline',
      'hskMaterials': 'HSK Study Materials',
      'practiceNowLabel': 'Practice Now',
      // 学习页
      'learn': 'Learn',
      'currentLevel': 'Current Level',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advancedLevel': 'Advanced',
      'expert': 'Expert',
      'practiceNow': 'Practice Now',
      // 个人页
      'myProfile': 'My Profile',
      'learningStats': 'Learning Stats',
      'streak': 'Day Streak',
      'totalDays': 'Total Days',
      'totalHours': 'Total Hours',
      'settings': 'Settings',
      'language': 'Language',
      'dailyGoal': 'Daily Goal',
      'notifications': 'Notifications',
      'about': 'About',
      'logOut': 'Log Out',
      'editProfile': 'Edit Profile',
      // 新增的本地化键值
      // practice_page.dart
      'wordsPracticeTitle': 'Words Practice',
      'sentencesPracticeTitle': 'Sentences Practice',
      'tapMicToRead': 'Tap the microphone to read the Chinese above',
      'explainInNativeLanguage': 'Explain the meaning in your native language',
      'skip': 'Skip',
      'showAnswer': 'Show Answer',
      'pronunciationScore': 'Pronunciation Score 🎤',
      'toneAccuracy': 'Tone Accuracy',
      'soundAccuracy': 'Sound Accuracy',
      'nextStepExplain': 'Next Step: Explain Meaning →',
      'meaningScore': 'Meaning Score 💡',
      'literalMeaning': 'Literal Meaning',
      'extendedMeaning': 'Extended Meaning',
      'practicalMeaning': 'Practical Meaning',
      'masteredSuccess': '✅ You have mastered!',
      'continueBtn': 'Continue →',
      'tryAgain': '🔄 Try Again',
      'reRecord': 'Re-record',
      'meaningBelow': 'Explanation below',
      'meaningPlaceholder': '(Native language explanation, data not imported, temporarily blank)',
      'close': 'Close',
      'step1ReadChinese': 'Read Chinese',
      'step2Explain': 'Explain Meaning',
      // advanced_practice.dart
      'idioms': 'Idioms',
      'proverbs': 'Proverbs/Sayings',
      'poetry': 'Poetry',
      'culture': 'Cultural Knowledge',
      'chineseExplanation': 'Chinese Explanation',
      'dataNotLoaded': '(Data not loaded, temporarily blank)',
      // listening_practice.dart
      'listeningPracticeTitle': 'Listening Practice',
      'optionA': 'Option A',
      'optionB': 'Option B',
      'optionC': 'Option C',
      'optionD': 'Option D',
      'questionProgress': 'Question {current} of {total}',
      'tapToPlay': 'Tap to Play',
      'submit': 'Submit',
      // level_test.dart
      'whatsYourLevel': 'What is your Chinese level?',
      'selectBestOption': 'Select the option that best matches your current situation',
      'nextStep': 'Next Step',
      'levelBeginner': 'Beginner',
      'levelElementary': 'Elementary',
      'levelIntermediate': 'Intermediate',
      'levelAdvanced': 'Advanced',
      // goal_setting.dart
      'setLearningGoal': 'Set a learning goal',
      'dailyConsistency': 'Consistency brings visible progress',
      'startLearning': 'Start Learning',
      'goal5min': '5 min/day',
      'goal15min': '15 min/day',
      'goal30min': '30 min/day',
      'goal60min': '60 min/day',
      // profile_tab.dart
      'learnerName': 'Learner',
      'myAchievements': 'My Achievements',
      'learningProgress': 'Learning Progress',
      // favorites_page.dart
      'myFavorites': 'My Favorites',
      'noFavoritesYet': 'No favorites yet',
      // review_page.dart
      'reviewTitle': 'Review',
      'review': 'Review',
      'wordsReview': 'Words Review',
      'sentencesReview': 'Sentences Review',
      'advancedReview': 'Advanced Review',
      'idiomsProverbsPoetry': 'Idioms / Proverbs / Poetry',
      // empty_page.dart
      'comingSoon': 'Coming Soon',
      'featureInDevelopment': 'Feature is under development...',
    },
    'ru': {
      'appTitle': 'Chinese Go',
      'selectNativeLanguage': 'На каком языке вы изучаете китайский?',
      'pleaseSelect': 'Пожалуйста, выберите ваш родной язык',
      'confirm': 'Подтвердить',
      'chooseNativeLanguage': 'Выберите родной язык',
      'dailyGoalMinutes': 'Ежедневная цель (минуты)',
      'minutes': 'минут',
      'home': 'Главная',
      'learning': 'Обучение',
      'profile': 'Профиль',
      'todayLearningTime': 'Время обучения сегодня',
      'wordsMastered': 'Освоено слов',
      'sentencesMastered': 'Освоено предложений',
      'advancedMastered': 'Освоено продвинутых',
      'continueLearning': 'Продолжить обучение',
      'words': 'Слова',
      'sentences': 'Предложения',
      'advanced': 'Продвинутые',
      'listening': 'Аудирование',
      'review': 'Повторение',
      'favorites': 'Избранное',
      // home_tab.dart中的文本
      'mastered': 'Освоено',
      'streakLabel': 'Дней подряд',
      'totalDaysLabel': 'Всего дней',
      'totalHoursLabel': 'Часов обучения',
      'wordsLabel': 'Слова',
      'sentencesLabel': 'Предложения',
      'advancedLabel': 'Продвинутые',
      'unitDay': 'день',
      'unitDays': 'дней',
      'unitHour': 'час',
      'unitHours': 'часов',
      'unitItem': 'единица',
      'unitItems': 'единиц',
      'myFavorites': 'Мои избранные',
      'learn': 'Учить',
      'currentLevel': 'Текущий уровень',
      'beginner': 'Начинающий',
      'intermediate': 'Средний',
      'advancedLevel': 'Продвинутый',
      'expert': 'Эксперт',
      'practiceNow': 'Практиковать сейчас',
      'myProfile': 'Мой профиль',
     'learningStats': 'Статистика обучения',
      'streak': 'Дней подряд',
      'totalDays': 'Всего дней',
      'totalHours': 'Всего часов',
      'settings': 'Настройки',
      'language': 'Язык',
      'dailyGoal': 'Ежедневная цель',
      'notifications': 'Уведержения',
      'about': 'О приложении',
      'logOut': 'Выйти',
      'editProfile': 'Редактировать профиль',
      // learn_tab.dart中的文本
      'beginnerLevel': 'Начинающий',
      'elementaryLevel': 'Элементарный',
      'intermediateLevel': 'Средний',
      'advancedLevelName': 'Продвинутый',
      'currentLevelLabel': 'Текущий уровень',
      'wordsPractice': 'Практика слов',
      'sentencesPractice': 'Практика предложений',
      'grammarLearning': 'Изучение грамматики',
      'listeningPractice': 'Практика аудирования',
      'advancedReading': 'Продвинутое чтение · Китайская культура',
      'idioms': 'Идиомы',
      'proverbs': 'Поговорки/Пословицы',
      'poetry': 'Поэзия',
      'culture': 'Культурные знания',
      'auxiliaryMaterials': 'Вспомогательные учебные материалы',
      'hskOutline': 'Программа экзамена HSK',
      'hskMaterials': 'Учебные материалы HSK',
      'practiceNowLabel': 'Практиковать сейчас',
      // 新增的本地化键值
      // practice_page.dart
      'wordsPracticeTitle': 'Практика слов',
      'sentencesPracticeTitle': 'Практика предложений',
      'tapMicToRead': 'Нажмите на микрофон, чтобы прочитать китайский текст выше',
      'explainInNativeLanguage': 'Объясните значение на вашем родном языке',
      'skip': 'Пропустить',
      'showAnswer': 'Показать ответ',
      'pronunciationScore': 'Оценка произношения 🎤',
      'toneAccuracy': 'Точность тонов',
      'soundAccuracy': 'Точность звуков',
      'nextStepExplain': 'Следующий шаг: Объяснение значения →',
      'meaningScore': 'Оценка понимания 💡',
      'literalMeaning': 'Буквальное значение',
      'extendedMeaning': 'Расширенное значение',
      'practicalMeaning': 'Практическое значение',
      'masteredSuccess': '✅ Вы освоили!',
      'continueBtn': 'Продолжить →',
      'tryAgain': '🔄 Попробовать снова',
      'reRecord': 'Перезаписать',
      'meaningBelow': 'Объяснение ниже',
      'meaningPlaceholder': '(Объяснение на родном языке, данные не импортированы, временно пусто)',
      'close': 'Закрыть',
      'step1ReadChinese': 'Читайте китайский',
      'step2Explain': 'Объясните значение',
      // advanced_practice.dart
      'idioms': 'Идиомы',
      'proverbs': 'Поговорки/Пословицы',
      'poetry': 'Поэзия',
      'culture': 'Культурные знания',
      'chineseExplanation': 'Китайское объяснение',
      'dataNotLoaded': '(Данные не загружены, временно пусто)',
      // listening_practice.dart
      'listeningPracticeTitle': 'Практика аудирования',
      'optionA': 'Вариант A',
      'optionB': 'Вариант B',
      'optionC': 'Вариант C',
      'optionD': 'Вариант D',
      'questionProgress': 'Вопрос {current} из {total}',
      'tapToPlay': 'Нажмите для воспроизведения',
      'submit': 'Отправить',
      // level_test.dart
      'whatsYourLevel': 'Какой у вас уровень китайского?',
      'selectBestOption': 'Выберите вариант, который лучше всего соответствует вашей текущей ситуации',
      'nextStep': 'Следующий шаг',
      'levelBeginner': 'Начинающий',
      'levelElementary': 'Элементарный',
      'levelIntermediate': 'Средний',
      'levelAdvanced': 'Продвинутый',
      // goal_setting.dart
      'setLearningGoal': 'Установить цель обучения',
      'dailyConsistency': 'Последовательность приносит заметный прогресс',
      'startLearning': 'Начать обучение',
      'goal5min': '5 минут/день',
      'goal15min': '15 минут/день',
      'goal30min': '30 минут/день',
      'goal60min': '60 минут/день',
      // profile_tab.dart
      'learnerName': 'Обучающийся',
      'myAchievements': 'Мои достижения',
      'learningProgress': 'Прогресс обучения',
      // favorites_page.dart
      'myFavorites': 'Мои избранные',
      'noFavoritesYet': 'Пока нет избранных',
      // review_page.dart
      'reviewTitle': 'Обзор',
      'review': 'Обзор',
      'wordsReview': 'Обзор слов',
      'sentencesReview': 'Обзор предложений',
      'advancedReview': 'Обзор продвинутых',
      'idiomsProverbsPoetry': 'Идиомы / Пословицы / Поэзия',
      // empty_page.dart
      'comingSoon': 'Скоро будет',
      'featureInDevelopment': 'Функция находится в разработке...',
    },
    'fa': {
      'appTitle': 'چینی گو',
      'selectNativeLanguage': 'برای یادگیری چینی از کدام زبان استفاده می‌کنید؟',
      'pleaseSelect': 'لطفاً زبان مادری خود را انتخاب کنید',
      'confirm': 'تأیید',
      'chooseNativeLanguage': 'انتخاب زبان مادری',
      'dailyGoalMinutes': 'هدف روزانه (دقیقه)',
      'minutes': 'دقیقه',
      'home': 'خانه',
      'learning': 'یادگیری',
      'profile': 'پروفایل',
      'todayLearningTime': 'زمان یادگیری امروز',
      'wordsMastered': 'کلمات تسلط یافته',
      'sentencesMastered': 'جمله‌های تسلط یافته',
      'advancedMastered': 'پیشرفته تسلط یافته',
      'continueLearning': 'ادامه یادگیری',
      'words': 'کلمات',
      'sentences': 'جمله‌ها',
      'advanced': 'پیشرفته',
      'listening': 'شنیداری',
      'review': 'مرور',
      'favorites': 'موردعلاقه',
      // home_tab.dart中的文本
      'mastered': 'تسلط یافته',
      'streakLabel': 'روز متوالی',
      'totalDaysLabel': 'کل روزها',
      'totalHoursLabel': 'ساعت‌های یادگیری',
      'wordsLabel': 'کلمات',
      'sentencesLabel': 'جمله‌ها',
      'advancedLabel': 'پیشرفته',
      'unitDay': 'روز',
      'unitDays': 'روز',
      'unitHour': 'ساعت',
      'unitHours': 'ساعت',
      'unitItem': 'مورد',
      'unitItems': 'مورد',
      'myFavorites': 'موردعلاقه‌های من',
      'learn': 'یادگیری',
      'currentLevel': 'سطح فعلی',
      'beginner': 'مبتدی',
      'intermediate': 'متوسط',
      'advancedLevel': 'پیشرفته',
      'expert': 'متخصص',
      'practiceNow': 'تمرین الآن',
      'myProfile': 'پروفایل من',
      'learningStats': 'آمار یادگیری',
      'streak': 'روز متوالی',
      'totalDays': 'کل روزها',
      'totalHours': 'کل ساعت‌ها',
      'settings': 'تنظیمات',
      'language': 'زبان',
      'dailyGoal': 'هدف روزانه',
      'notifications': 'اعلان‌ها',
      'about': 'درباره',
      'logOut': 'خروج',
      'editProfile': 'ویرایش پروفایل',
      // learn_tab.dart中的文本
      'beginnerLevel': 'مبتدی',
      'elementaryLevel': 'ابتدایی',
      'intermediateLevel': 'متوسط',
      'advancedLevelName': 'پیشرفته',
      'currentLevelLabel': 'سطح فعلی',
      'wordsPractice': 'تمرین کلمات',
      'sentencesPractice': 'تمرین جملات',
      'grammarLearning': 'یادگیری دستور زبان',
      'listeningPractice': 'تمرین شنیداری',
      'advancedReading': 'خواندن پیشرفته · فرهنگ چینی',
      'idioms': 'اصطلاحات',
      'proverbs': 'ضرب‌المثل‌ها/گفتارها',
      'poetry': 'شعر',
      'culture': 'دانش فرهنگی',
      'auxiliaryMaterials': 'مواد کمک آموزشی',
      'hskOutline': 'طرح امتحان HSK',
      'hskMaterials': 'مواد مطالعه HSK',
      'practiceNowLabel': 'تمرین الآن',
      // practice_page.dart中的文本
      'wordsPracticeTitle': 'تمرین کلمات',
      'sentencesPracticeTitle': 'تمرین جملات',
      'tapMicToRead': 'برای خواندن متن چینی بالا روی میکروفون ضربه بزنید',
      'explainInNativeLanguage': 'معنی را به زبان مادری خود توضیح دهید',
      'skip': 'رد کردن',
      'showAnswer': 'نمایش پاسخ',
      'pronunciationScore': 'امتیاز تلفظ 🎤',
      'toneAccuracy': 'دقت تون',
      'soundAccuracy': 'دقت صدا',
      'nextStepExplain': 'مرحله بعد: توضیح معنی →',
      'meaningScore': 'امتیاز معنی 💡',
      'literalMeaning': 'معنی تحت‌اللفظی',
      'extendedMeaning': 'معنی گسترده',
      'practicalMeaning': 'معنی عملی',
      'masteredSuccess': '✅ شما تسلط یافته‌اید!',
      'continueBtn': 'ادامه →',
      'tryAgain': '🔄 دوباره امتحان کنید',
      'reRecord': 'ضبط مجدد',
      'meaningBelow': 'توضیح زیر',
      'meaningPlaceholder': '(توضیح به زبان مادری، داده وارد نشده، موقتا خالی)',
      'close': 'بستن',
      'step1ReadChinese': 'چینی بخوانید',
      'step2Explain': 'معنی را توضیح دهید',
      // advanced_practice.dart
      'chineseExplanation': 'توضیح چینی',
      'dataNotLoaded': '(داده بارگیری نشده، موقتا خالی)',
      // listening_practice.dart
      'listeningPracticeTitle': 'تمرین شنیداری',
      'optionA': 'گزینه الف',
      'optionB': 'گزینه ب',
      'optionC': 'گزینه ج',
      'optionD': 'گزینه د',
      'questionProgress': 'سوال {current} از {total}',
      'tapToPlay': 'برای پخش ضربه بزنید',
      'submit': 'ارسال',
      // level_test.dart
      'whatsYourLevel': 'سطح چینی شما چیست؟',
      'selectBestOption': 'گزینه‌ای را که با وضعیت فعلی شما بیشترین هماهنگی را دارد انتخاب کنید',
      'nextStep': 'مرحله بعد',
      'levelBeginner': 'مبتدی',
      'levelElementary': 'ابتدایی',
      'levelIntermediate': 'متوسط',
      'levelAdvanced': 'پیشرفته',
      // goal_setting.dart
      'setLearningGoal': 'تعیین هدف یادگیری',
      'dailyConsistency': 'ثبات روزانه پیشرفت قابل مشاهده به همراه دارد',
      'startLearning': 'شروع یادگیری',
      'goal5min': '۵ دقیقه/روز',
      'goal15min': '۱۵ دقیقه/روز',
      'goal30min': '۳۰ دقیقه/روز',
      'goal60min': '۶۰ دقیقه/روز',
      // profile_tab.dart
      'learnerName': 'یادگیرنده',
      'myAchievements': 'دستاوردهای من',
      'learningProgress': 'پیشرفت یادگیری',
      // favorites_page.dart
      'noFavoritesYet': 'هنوز موردعلاقه‌ای وجود ندارد',
      // review_page.dart
      'reviewTitle': 'مرور',
      'wordsReview': 'مرور کلمات',
      'sentencesReview': 'مرور جملات',
      'advancedReview': 'مرور پیشرفته',
      'idiomsProverbsPoetry': 'اصطلاحات / ضرب‌المثل‌ها / شعر',
      // empty_page.dart
      'comingSoon': 'به زودی',
      'featureInDevelopment': 'ویژگی در حال توسعه است...',
    },
    'ar': {
      'appTitle': 'تشين جو',
      'selectNativeLanguage': 'ما اللغة التي تستخدمها لتعلم الصينية؟',
      'pleaseSelect': 'يرجى اختيار لغتك الأم',
      'confirm': 'تأكيد',
      'chooseNativeLanguage': 'اختر اللغة الأم',
      'dailyGoalMinutes': 'الهدف اليومي (دقائق)',
      'minutes': 'دقيقة',
      'home': 'الرئيسية',
      'learning': 'التعلم',
      'profile': 'الملف الشخصي',
      'todayLearningTime': 'وقت التعلم اليوم',
      'wordsMastered': 'الكلمات المتقنة',
      'sentencesMastered': 'الجمل المتقنة',
      'advancedMastered': 'المتقدم المتقن',
      'continueLearning': 'متابعة التعلم',
      'words': 'الكلمات',
      'sentences': 'الجمل',
      'advanced': 'متقدم',
      'listening': 'الاستماع',
      'review': 'مراجعة',
      'favorites': 'المفضلة',
      // home_tab.dart中的文本
      'mastered': 'تم إتقانها',
      'streakLabel': 'أيام متتالية',
      'totalDaysLabel': 'إجمالي الأيام',
      'totalHoursLabel': 'ساعات التعلم',
      'wordsLabel': 'الكلمات',
      'sentencesLabel': 'الجمل',
      'advancedLabel': 'متقدم',
      'unitDay': 'يوم',
      'unitDays': 'أيام',
      'unitHour': 'ساعة',
      'unitHours': 'ساعات',
      'unitItem': 'عنصر',
      'unitItems': 'عناصر',
      'myFavorites': 'مفضلتي',
      'learn': 'تعلم',
      'currentLevel': 'المستوى الحالي',
      'beginner': 'مبتدئ',
      'intermediate': 'متوسط',
      'advancedLevel': 'متقدم',
      'expert': 'خبير',
      'practiceNow': 'تمرين الآن',
      'myProfile': 'ملفي الشخصي',
      'learningStats': 'إحصائيات التعلم',
      'streak': 'أيام متتالية',
      'totalDays': 'إجمالي الأيام',
      'totalHours': 'إجمالي الساعات',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'dailyGoal': 'الهدف اليومي',
      'notifications': 'الإشعارات',
      'about': 'حول',
      'logOut': 'تسجيل الخروج',
      'editProfile': 'تعديل الملف الشخصي',
      // learn_tab.dart中的文本
      'beginnerLevel': 'مبتدئ',
      'elementaryLevel': 'ابتدائي',
      'intermediateLevel': 'متوسط',
      'advancedLevelName': 'متقدم',
      'currentLevelLabel': 'المستوى الحالي',
      'wordsPractice': 'تدريب الكلمات',
      'sentencesPractice': 'تدريب الجمل',
      'grammarLearning': 'تعلم القواعد',
      'listeningPractice': 'تدريب الاستماع',
      'advancedReading': 'قراءة متقدمة · الثقافة الصينية',
      'idioms': 'أمثال',
      'proverbs': 'حكم / أقوال',
      'poetry': 'شعر',
      'culture': 'معرفة ثقافية',
      'auxiliaryMaterials': 'مواد تعليمية مساعدة',
      'hskOutline': 'مخطط امتحان HSK',
      'hskMaterials': 'مواد دراسة HSK',
      'practiceNowLabel': 'تدرب الآن',
      // practice_page.dart中的文本
      'wordsPracticeTitle': 'تدريب الكلمات',
      'sentencesPracticeTitle': 'تدريب الجمل',
      'tapMicToRead': 'اضغط على الميكروفون لقراءة النص الصيني أعلاه',
      'explainInNativeLanguage': 'اشرح المعنى بلغتك الأم',
      'skip': 'تخطي',
      'showAnswer': 'إظهار الإجابة',
      'pronunciationScore': 'نتيجة النطق 🎤',
      'toneAccuracy': 'دقة النغمة',
      'soundAccuracy': 'دقة الصوت',
      'nextStepExplain': 'الخطوة التالية: شرح المعنى →',
      'meaningScore': 'نتيجة المعنى 💡',
      'literalMeaning': 'المعنى الحرفي',
      'extendedMeaning': 'المعنى الموسع',
      'practicalMeaning': 'المعنى العملي',
      'masteredSuccess': '✅ لقد أتقنت!',
      'continueBtn': 'متابعة →',
      'tryAgain': '🔄 حاول مرة أخرى',
      'reRecord': 'إعادة التسجيل',
      'meaningBelow': 'الشرح أدناه',
      'meaningPlaceholder': '(شرح باللغة الأم، لم يتم استيراد البيانات، فارغ مؤقتاً)',
      'close': 'إغلاق',
      'step1ReadChinese': 'اقرأ الصينية',
      'step2Explain': 'اشرح المعنى',
      // advanced_practice.dart
      'chineseExplanation': 'شرح صيني',
      'dataNotLoaded': '(لم يتم تحميل البيانات، فارغ مؤقتاً)',
      // listening_practice.dart
      'listeningPracticeTitle': 'تدريب الاستماع',
      'optionA': 'الخيار أ',
      'optionB': 'الخيار ب',
      'optionC': 'الخيار ج',
      'optionD': 'الخيار د',
      'questionProgress': 'السؤال {current} من {total}',
      'tapToPlay': 'اضغط للعب',
      'submit': 'إرسال',
      // level_test.dart
      'whatsYourLevel': 'ما هو مستواك في اللغة الصينية؟',
      'selectBestOption': 'اختر الخيار الذي يناسب وضعك الحالي بشكل أفضل',
      'nextStep': 'الخطوة التالية',
      'levelBeginner': 'مبتدئ',
      'levelElementary': 'ابتدائي',
      'levelIntermediate': 'متوسط',
      'levelAdvanced': 'متقدم',
      // goal_setting.dart
      'setLearningGoal': 'تحديد هدف التعلم',
      'dailyConsistency': 'الانتظام اليومي يجلب تقدمًا ملحوظًا',
      'startLearning': 'ابدأ التعلم',
      'goal5min': '5 دقيقة/يوم',
      'goal15min': '15 دقيقة/يوم',
      'goal30min': '30 دقيقة/يوم',
      'goal60min': '60 دقيقة/يوم',
      // profile_tab.dart
      'learnerName': 'المتعلم',
      'myAchievements': 'إنجازاتي',
      'learningProgress': 'تقدم التعلم',
      // favorites_page.dart
      'noFavoritesYet': 'لا مفضلات حتى الآن',
      // review_page.dart
      'reviewTitle': 'مراجعة',
      'wordsReview': 'مراجعة الكلمات',
      'sentencesReview': 'مراجعة الجمل',
      'advancedReview': 'مراجعة متقدمة',
      'idiomsProverbsPoetry': 'أمثال / حكم / شعر',
      // empty_page.dart
      'comingSoon': 'قريباً',
      'featureInDevelopment': 'الميزة قيد التطوير...',
    },
    'tr': {
      'appTitle': 'Chinese Go',
      'selectNativeLanguage': 'Çince öğrenmek için hangi dili kullanıyorsunuz?',
      'pleaseSelect': 'Lütfen ana dilinizi seçin',
      'confirm': 'Onayla',
      'chooseNativeLanguage': 'Ana Dil Seç',
      'dailyGoalMinutes': 'Günlük Hedef (dakika)',
      'minutes': 'dakika',
      'home': 'Ana Sayfa',
      'learning': 'Öğrenme',
      'profile': 'Profil',
      'todayLearningTime': 'Bugünkü Öğrenme Süresi',
      'wordsMastered': 'Öğrenilen Kelimeler',
      'sentencesMastered': 'Öğrenilen Cümleler',
      'advancedMastered': 'Öğrenilen Gelişmiş',
      'continueLearning': 'Öğrenmeye Devam Et',
      'words': 'Kelimeler',
      'sentences': 'Cümleler',
      'advanced': 'Gelişmiş',
      'listening': 'Dinleme',
      'review': 'Gözden Geçirme',
      'favorites': 'Favoriler',
      // home_tab.dart中的文本
      'mastered': 'Öğrenilen',
      'streakLabel': 'Arka Arkaya Gün',
      'totalDaysLabel': 'Toplam Gün',
      'totalHoursLabel': 'Öğrenme Saatleri',
      'wordsLabel': 'Kelimeler',
      'sentencesLabel': 'Cümleler',
      'advancedLabel': 'Gelişmiş',
      'unitDay': 'gün',
      'unitDays': 'gün',
      'unitHour': 'saat',
      'unitHours': 'saat',
      'unitItem': 'öğe',
      'unitItems': 'öğe',
      'myFavorites': 'Favorilerim',
      'learn': 'Öğren',
      'currentLevel': 'Mevcut Seviye',
      'beginner': 'Başlangıç',
      'intermediate': 'Orta',
      'advancedLevel': 'İleri',
      'expert': 'Uzman',
      'practiceNow': 'Şimdi Pratik Yap',
      'myProfile': 'Profilim',
      'learningStats': 'Öğrenme İstatistikleri',
      'streak': 'Arka Arkaya Gün',
      'totalDays': 'Toplam Gün',
      'totalHours': 'Toplam Saat',
      'settings': 'Ayarlar',
      'language': 'Dil',
      'dailyGoal': 'Günlük Hedef',
      'notifications': 'Bildirimler',
      'about': 'Hakkında',
      'logOut': 'Çıkış Yap',
      'editProfile': 'Profili Düzenle',
      // learn_tab.dart中的文本
      'beginnerLevel': 'Başlangıç',
      'elementaryLevel': 'Temel',
      'intermediateLevel': 'Orta',
      'advancedLevelName': 'İleri',
      'currentLevelLabel': 'Mevcut Seviye',
      'wordsPractice': 'Kelime Pratiği',
      'sentencesPractice': 'Cümle Pratiği',
      'grammarLearning': 'Dilbilgisi Öğrenme',
      'listeningPractice': 'Dinleme Pratiği',
      'advancedReading': 'İleri Okuma · Çin Kültürü',
      'idioms': 'Deyimler',
      'proverbs': 'Atasözleri/Sözler',
      'poetry': 'Şiir',
      'culture': 'Kültürel Bilgi',
      'auxiliaryMaterials': 'Yardımcı Öğrenme Materyalleri',
      'hskOutline': 'HSK Sınav Programı',
      'hskMaterials': 'HSK Çalışma Materyalleri',
      'practiceNowLabel': 'Şimdi Pratik Yap',
      // 新增的本地化键值
      // practice_page.dart
      'wordsPracticeTitle': 'Kelime Pratiği',
      'sentencesPracticeTitle': 'Cümle Pratiği',
      'tapMicToRead': 'Yukarıdaki Çince metni okumak için mikrofon simgesine tıklayın',
      'explainInNativeLanguage': 'Anlamını ana dilinizde açıklayın',
      'skip': 'Atla',
      'showAnswer': 'Cevabı Göster',
      'pronunciationScore': 'Telaffuz Puanı 🎤',
      'toneAccuracy': 'Ton Doğruluğu',
      'soundAccuracy': 'Ses Doğruluğu',
      'nextStepExplain': 'Sonraki Adım: Anlamı Açıkla →',
      'meaningScore': 'Anlama Puanı 💡',
      'literalMeaning': 'Kelime Anlamı',
      'extendedMeaning': 'Genişletilmiş Anlam',
      'practicalMeaning': 'Pratik Anlam',
      'masteredSuccess': '✅ Öğrendin!',
      'continueBtn': 'Devam Et →',
      'tryAgain': '🔄 Tekrar Deneyin',
      'reRecord': 'Tekrar Kaydet',
      'meaningBelow': 'Açıklama Aşağıda',
      'meaningPlaceholder': '(Ana dil açıklaması, veri yüklenmedi, geçici olarak boş)',
      'close': 'Kapat',
      'step1ReadChinese': 'Çince Okuyun',
      'step2Explain': 'Anlamı Açıklayın',
      // advanced_practice.dart
      'idioms': 'Deyimler',
      'proverbs': 'Atasözleri/Sözler',
      'poetry': 'Şiir',
      'culture': 'Kültürel Bilgi',
      'chineseExplanation': 'Çince Açıklama',
      'dataNotLoaded': '(Veri yüklenmedi, geçici olarak boş)',
      // listening_practice.dart
      'listeningPracticeTitle': 'Dinleme Pratiği',
      'optionA': 'Seçenek A',
      'optionB': 'Seçenek B',
      'optionC': 'Seçenek C',
      'optionD': 'Seçenek D',
      'questionProgress': 'Soru {current} / {total}',
      'tapToPlay': 'Oynatmak İçin Tıklayın',
      'submit': 'Gönder',
      // level_test.dart
      'whatsYourLevel': 'Çince seviyeniz nedir?',
      'selectBestOption': 'Mevcut durumunuza en uygun seçeneği seçin',
      'nextStep': 'Sonraki Adım',
      'levelBeginner': 'Başlangıç',
      'levelElementary': 'Temel',
      'levelIntermediate': 'Orta',
      'levelAdvanced': 'İleri',
      // goal_setting.dart
      'setLearningGoal': 'Bir öğrenme hedefi belirleyin',
      'dailyConsistency': 'Düzenlilik görünür ilerleme getirir',
      'startLearning': 'Öğrenmeye Başla',
      'goal5min': '5 dakika/gün',
      'goal15min': '15 dakika/gün',
      'goal30min': '30 dakika/gün',
      'goal60min': '60 dakika/gün',
      // profile_tab.dart
      'learnerName': 'Öğrenen',
      'myAchievements': 'Başarılarım',
      'learningProgress': 'Öğrenme İlerlemesi',
      // favorites_page.dart
      'myFavorites': 'Favorilerim',
      'noFavoritesYet': 'Henüz favori yok',
      // review_page.dart
      'review': 'Gözden Geçirme',
      'wordsReview': 'Kelime Gözden Geçirme',
      'sentencesReview': 'Cümle Gözden Geçirme',
      'advancedReview': 'İleri Gözden Geçirme',
      // empty_page.dart
      'comingSoon': 'Yakında',
      'featureInDevelopment': 'Özellik geliştirme aşamasında...',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]?['appTitle'] ?? 'Chinese Go';
  String get selectNativeLanguage => _localizedValues[locale.languageCode]?['selectNativeLanguage'] ?? 'What language do you use to learn Chinese?';
  String get pleaseSelect => _localizedValues[locale.languageCode]?['pleaseSelect'] ?? 'Please select your native language';
  String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
  String get chooseNativeLanguage => _localizedValues[locale.languageCode]?['chooseNativeLanguage'] ?? 'Choose Native Language';
  String get dailyGoalMinutes => _localizedValues[locale.languageCode]?['dailyGoalMinutes'] ?? 'Daily Goal (minutes)';
  String get minutes => _localizedValues[locale.languageCode]?['minutes'] ?? 'minutes';
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get learning => _localizedValues[locale.languageCode]?['learning'] ?? 'Learning';
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get todayLearningTime => _localizedValues[locale.languageCode]?['todayLearningTime'] ?? 'Today Learning Time';
  String get wordsMastered => _localizedValues[locale.languageCode]?['wordsMastered'] ?? 'Words Mastered';
  String get sentencesMastered => _localizedValues[locale.languageCode]?['sentencesMastered'] ?? 'Sentences Mastered';
  String get advancedMastered => _localizedValues[locale.languageCode]?['advancedMastered'] ?? 'Advanced Mastered';
  String get continueLearning => _localizedValues[locale.languageCode]?['continueLearning'] ?? 'Continue Learning';
  String get words => _localizedValues[locale.languageCode]?['words'] ?? 'Words';
  String get sentences => _localizedValues[locale.languageCode]?['sentences'] ?? 'Sentences';
  String get advanced => _localizedValues[locale.languageCode]?['advanced'] ?? 'Advanced';
  String get listening => _localizedValues[locale.languageCode]?['listening'] ?? 'Listening';
  String get review => _localizedValues[locale.languageCode]?['review'] ?? 'Review';
  String get favorites => _localizedValues[locale.languageCode]?['favorites'] ?? 'Favorites';
  String get learn => _localizedValues[locale.languageCode]?['learn'] ?? 'Learn';
  String get currentLevel => _localizedValues[locale.languageCode]?['currentLevel'] ?? 'Current Level';
  String get beginner => _localizedValues[locale.languageCode]?['beginner'] ?? 'Beginner';
  String get intermediate => _localizedValues[locale.languageCode]?['intermediate'] ?? 'Intermediate';
  String get advancedLevel => _localizedValues[locale.languageCode]?['advancedLevel'] ?? 'Advanced';
  String get expert => _localizedValues[locale.languageCode]?['expert'] ?? 'Expert';
  String get practiceNow => _localizedValues[locale.languageCode]?['practiceNow'] ?? 'Practice Now';
  String get myProfile => _localizedValues[locale.languageCode]?['myProfile'] ?? 'My Profile';
  String get learningStats => _localizedValues[locale.languageCode]?['learningStats'] ?? 'Learning Stats';
  String get streak => _localizedValues[locale.languageCode]?['streak'] ?? 'Day Streak';
  String get totalDays => _localizedValues[locale.languageCode]?['totalDays'] ?? 'Total Days';
  String get totalHours => _localizedValues[locale.languageCode]?['totalHours'] ?? 'Total Hours';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get dailyGoal => _localizedValues[locale.languageCode]?['dailyGoal'] ?? 'Daily Goal';
  String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Notifications';
  String get about => _localizedValues[locale.languageCode]?['about'] ?? 'About';
  String get logOut => _localizedValues[locale.languageCode]?['logOut'] ?? 'Log Out';
  String get editProfile => _localizedValues[locale.languageCode]?['editProfile'] ?? 'Edit Profile';
  
  // home_tab.dart中的文本
  String get mastered => _localizedValues[locale.languageCode]?['mastered'] ?? 'Mastered';
  String get streakLabel => _localizedValues[locale.languageCode]?['streakLabel'] ?? 'Day Streak';
  String get totalDaysLabel => _localizedValues[locale.languageCode]?['totalDaysLabel'] ?? 'Total Days';
  String get totalHoursLabel => _localizedValues[locale.languageCode]?['totalHoursLabel'] ?? 'Learning Hours';
  String get wordsLabel => _localizedValues[locale.languageCode]?['wordsLabel'] ?? 'Words';
  String get sentencesLabel => _localizedValues[locale.languageCode]?['sentencesLabel'] ?? 'Sentences';
  String get advancedLabel => _localizedValues[locale.languageCode]?['advancedLabel'] ?? 'Advanced';
  String get myFavorites => _localizedValues[locale.languageCode]?['myFavorites'] ?? 'My Favorites';
  
  // 单位文本
  String get unitDay => _localizedValues[locale.languageCode]?['unitDay'] ?? 'day';
  String get unitDays => _localizedValues[locale.languageCode]?['unitDays'] ?? 'days';
  String get unitHour => _localizedValues[locale.languageCode]?['unitHour'] ?? 'hour';
  String get unitHours => _localizedValues[locale.languageCode]?['unitHours'] ?? 'hours';
  String get unitItem => _localizedValues[locale.languageCode]?['unitItem'] ?? 'item';
  String get unitItems => _localizedValues[locale.languageCode]?['unitItems'] ?? 'items';
  
  // learn_tab.dart中的文本
  String get beginnerLevel => _localizedValues[locale.languageCode]?['beginnerLevel'] ?? 'Beginner';
  String get elementaryLevel => _localizedValues[locale.languageCode]?['elementaryLevel'] ?? 'Elementary';
  String get intermediateLevel => _localizedValues[locale.languageCode]?['intermediateLevel'] ?? 'Intermediate';
  String get advancedLevelName => _localizedValues[locale.languageCode]?['advancedLevelName'] ?? 'Advanced';
  String get currentLevelLabel => _localizedValues[locale.languageCode]?['currentLevelLabel'] ?? 'Current Level';
  String get wordsPractice => _localizedValues[locale.languageCode]?['wordsPractice'] ?? 'Words Practice';
  String get sentencesPractice => _localizedValues[locale.languageCode]?['sentencesPractice'] ?? 'Sentences Practice';
  String get grammarLearning => _localizedValues[locale.languageCode]?['grammarLearning'] ?? 'Grammar Learning';
  String get listeningPractice => _localizedValues[locale.languageCode]?['listeningPractice'] ?? 'Listening Practice';
  String get advancedReading => _localizedValues[locale.languageCode]?['advancedReading'] ?? 'Advanced Reading · Chinese Culture';
  String get idioms => _localizedValues[locale.languageCode]?['idioms'] ?? 'Idioms';
  String get proverbs => _localizedValues[locale.languageCode]?['proverbs'] ?? 'Proverbs/Sayings';
  String get poetry => _localizedValues[locale.languageCode]?['poetry'] ?? 'Poetry';
  String get culture => _localizedValues[locale.languageCode]?['culture'] ?? 'Cultural Knowledge';
  String get auxiliaryMaterials => _localizedValues[locale.languageCode]?['auxiliaryMaterials'] ?? 'Auxiliary Learning Materials';
  String get hskOutline => _localizedValues[locale.languageCode]?['hskOutline'] ?? 'HSK Exam Outline';
  String get hskMaterials => _localizedValues[locale.languageCode]?['hskMaterials'] ?? 'HSK Study Materials';
  String get practiceNowLabel => _localizedValues[locale.languageCode]?['practiceNowLabel'] ?? 'Practice Now';

  // practice_page.dart中的文本
  String get wordsPracticeTitle => _localizedValues[locale.languageCode]?['wordsPracticeTitle'] ?? 'Words Practice';
  String get sentencesPracticeTitle => _localizedValues[locale.languageCode]?['sentencesPracticeTitle'] ?? 'Sentences Practice';
  String get tapMicToRead => _localizedValues[locale.languageCode]?['tapMicToRead'] ?? 'Tap the microphone to read the Chinese above';
  String get explainInNativeLanguage => _localizedValues[locale.languageCode]?['explainInNativeLanguage'] ?? 'Explain the meaning in your native language';
  String get skip => _localizedValues[locale.languageCode]?['skip'] ?? 'Skip';
  String get showAnswer => _localizedValues[locale.languageCode]?['showAnswer'] ?? 'Show Answer';
  String get pronunciationScore => _localizedValues[locale.languageCode]?['pronunciationScore'] ?? 'Pronunciation Score 🎤';
  String get toneAccuracy => _localizedValues[locale.languageCode]?['toneAccuracy'] ?? 'Tone Accuracy';
  String get soundAccuracy => _localizedValues[locale.languageCode]?['soundAccuracy'] ?? 'Sound Accuracy';
  String get nextStepExplain => _localizedValues[locale.languageCode]?['nextStepExplain'] ?? 'Next Step: Explain Meaning →';
  String get meaningScore => _localizedValues[locale.languageCode]?['meaningScore'] ?? 'Meaning Score 💡';
  String get literalMeaning => _localizedValues[locale.languageCode]?['literalMeaning'] ?? 'Literal Meaning';
  String get extendedMeaning => _localizedValues[locale.languageCode]?['extendedMeaning'] ?? 'Extended Meaning';
  String get practicalMeaning => _localizedValues[locale.languageCode]?['practicalMeaning'] ?? 'Practical Meaning';
  String get masteredSuccess => _localizedValues[locale.languageCode]?['masteredSuccess'] ?? '✅ You have mastered!';
  String get continueBtn => _localizedValues[locale.languageCode]?['continueBtn'] ?? 'Continue →';
  String get tryAgain => _localizedValues[locale.languageCode]?['tryAgain'] ?? '🔄 Try Again';
  String get reRecord => _localizedValues[locale.languageCode]?['reRecord'] ?? 'Re-record';
  String get meaningBelow => _localizedValues[locale.languageCode]?['meaningBelow'] ?? 'Explanation below';
  String get meaningPlaceholder => _localizedValues[locale.languageCode]?['meaningPlaceholder'] ?? '(Native language explanation, data not imported, temporarily blank)';
  String get close => _localizedValues[locale.languageCode]?['close'] ?? 'Close';
  String get step1ReadChinese => _localizedValues[locale.languageCode]?['step1ReadChinese'] ?? 'Read Chinese';
  String get step2Explain => _localizedValues[locale.languageCode]?['step2Explain'] ?? 'Explain Meaning';

  // review_page.dart中的文本
  String get reviewTitle => _localizedValues[locale.languageCode]?['reviewTitle'] ?? 'Review';
  String get wordsReview => _localizedValues[locale.languageCode]?['wordsReview'] ?? 'Words Review';
  String get sentencesReview => _localizedValues[locale.languageCode]?['sentencesReview'] ?? 'Sentences Review';
  String get advancedReview => _localizedValues[locale.languageCode]?['advancedReview'] ?? 'Advanced Review';
  String get idiomsProverbsPoetry => _localizedValues[locale.languageCode]?['idiomsProverbsPoetry'] ?? 'Idioms / Proverbs / Poetry';

  // listening_practice.dart中的文本
  String get listeningPracticeTitle => _localizedValues[locale.languageCode]?['listeningPracticeTitle'] ?? 'Listening Practice';
  String get questionProgress => _localizedValues[locale.languageCode]?['questionProgress'] ?? 'Question {current} of {total}';
  String get tapToPlay => _localizedValues[locale.languageCode]?['tapToPlay'] ?? 'Tap to Play';
  String get submit => _localizedValues[locale.languageCode]?['submit'] ?? 'Submit';
  String get optionA => _localizedValues[locale.languageCode]?['optionA'] ?? 'Option A';
  String get optionB => _localizedValues[locale.languageCode]?['optionB'] ?? 'Option B';
  String get optionC => _localizedValues[locale.languageCode]?['optionC'] ?? 'Option C';
  String get optionD => _localizedValues[locale.languageCode]?['optionD'] ?? 'Option D';

  // advanced_practice.dart中的文本
  String get chineseExplanation => _localizedValues[locale.languageCode]?['chineseExplanation'] ?? 'Chinese Explanation';
  String get dataNotLoaded => _localizedValues[locale.languageCode]?['dataNotLoaded'] ?? '(Data not loaded, temporarily blank)';

  // favorites_page.dart中的文本
  String get myFavoritesTitle => _localizedValues[locale.languageCode]?['myFavorites'] ?? 'My Favorites';
  String get noFavoritesYet => _localizedValues[locale.languageCode]?['noFavoritesYet'] ?? 'No favorites yet';

  // profile_tab.dart中的文本
  String get learnerName => _localizedValues[locale.languageCode]?['learnerName'] ?? 'Learner';
  String get myAchievements => _localizedValues[locale.languageCode]?['myAchievements'] ?? 'My Achievements';
  String get learningProgress => _localizedValues[locale.languageCode]?['learningProgress'] ?? 'Learning Progress';

  // level_test.dart中的文本
  String get whatsYourLevel => _localizedValues[locale.languageCode]?['whatsYourLevel'] ?? 'What is your Chinese level?';
  String get selectBestOption => _localizedValues[locale.languageCode]?['selectBestOption'] ?? 'Select the option that best matches your current situation';
  String get nextStep => _localizedValues[locale.languageCode]?['nextStep'] ?? 'Next Step';
  String get levelBeginner => _localizedValues[locale.languageCode]?['levelBeginner'] ?? 'Beginner';
  String get levelElementary => _localizedValues[locale.languageCode]?['levelElementary'] ?? 'Elementary';
  String get levelIntermediate => _localizedValues[locale.languageCode]?['levelIntermediate'] ?? 'Intermediate';
  String get levelAdvanced => _localizedValues[locale.languageCode]?['levelAdvanced'] ?? 'Advanced';

  // goal_setting.dart中的文本
  String get setLearningGoal => _localizedValues[locale.languageCode]?['setLearningGoal'] ?? 'Set a learning goal';
  String get dailyConsistency => _localizedValues[locale.languageCode]?['dailyConsistency'] ?? 'Consistency brings visible progress';
  String get startLearning => _localizedValues[locale.languageCode]?['startLearning'] ?? 'Start Learning';
  String get goal5min => _localizedValues[locale.languageCode]?['goal5min'] ?? '5 min/day';
  String get goal15min => _localizedValues[locale.languageCode]?['goal15min'] ?? '15 min/day';
  String get goal30min => _localizedValues[locale.languageCode]?['goal30min'] ?? '30 min/day';
  String get goal60min => _localizedValues[locale.languageCode]?['goal60min'] ?? '60 min/day';

  // 动态文本方法
  String minutesText(int count) => '$count ${_localizedValues[locale.languageCode]?['minutes'] ?? 'minutes'}';
  
  // 带单位的动态文本
  String dayText(int count) => '$count ${count == 1 ? unitDay : unitDays}';
  String hourText(int count) => '$count ${count == 1 ? unitHour : unitHours}';
  String itemText(int count) => '$count ${count == 1 ? unitItem : unitItems}';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'fa', 'ar', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}