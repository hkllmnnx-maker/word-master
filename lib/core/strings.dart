/// مركز جميع النصوص العربية المستخدمة في التطبيق.
/// استخدام مكان واحد للنصوص يسهّل الصيانة والتعريب الكامل.
class AppStrings {
  AppStrings._();

  // عام
  static const appName = 'وورد ماستر';
  static const cancel = 'إلغاء';
  static const save = 'حفظ';
  static const create = 'إنشاء';
  static const close = 'إغلاق';
  static const delete = 'حذف';
  static const restore = 'استعادة';
  static const retry = 'إعادة المحاولة';
  static const seeAll = 'عرض الكل';
  static const apply = 'تطبيق';
  static const insert = 'إدراج';
  static const words = 'كلمة';
  static const characters = 'حرف';
  static const document = 'مستند';
  static const documents = 'مستندات';

  // التنقل السفلي
  static const navHome = 'الرئيسية';
  static const navDocs = 'المستندات';
  static const navCreate = 'إنشاء';
  static const navTemplates = 'القوالب';
  static const navSettings = 'الإعدادات';

  // الشاشة الرئيسية
  static const homeTitle = 'وورد ماستر';
  static const totalWords = 'إجمالي الكلمات';
  static const favorites = 'المفضلة';
  static const cloud = 'السحابة';
  static const synced = 'متزامن';
  static const continueWriting = 'متابعة الكتابة';
  static const recent = 'الأخيرة';
  static const allDocuments = 'جميع المستندات';
  static const quickNewDoc = 'مستند جديد';
  static const quickTemplates = 'القوالب';
  static const quickMyDocs = 'مستنداتي';
  static const quickSettings = 'الإعدادات';
  static const noDocsYet = 'لا توجد مستندات بعد';
  static const noDocsHint = 'اضغط على زر + لإنشاء\nأول مستند لك';
  static const createDocument = 'إنشاء مستند';
  static const searchDocuments = 'ابحث في المستندات…';
  static const noMatchingDocs = 'لا توجد مستندات مطابقة';

  // المحرر
  static const untitled = 'مستند بدون عنوان';
  static const tapToRename = 'اضغط لإعادة التسمية';
  static const startWriting = 'ابدأ بكتابة مستندك…';
  static const documentSaved = 'تم حفظ المستند';
  static const renameDoc = 'إعادة تسمية المستند';
  static const title = 'العنوان';
  static const fontFamily = 'نوع الخط';
  static const fontSize = 'حجم الخط';
  static const defaultLabel = 'افتراضي';
  static const statistics = 'الإحصائيات';
  static const docStatistics = 'إحصائيات المستند';
  static const findReplace = 'بحث واستبدال';
  static const find = 'بحث';
  static const replaceWith = 'استبدال بـ';
  static const replaceAll = 'استبدال الكل';
  static const replacedMatches = 'تم استبدال';
  static const noMatchesFound = 'لا توجد نتائج';
  static const export = 'تصدير';
  static const quickShare = 'مشاركة سريعة';
  static const clearFormatting = 'مسح التنسيق';
  static const saveNow = 'حفظ الآن';
  static const wordsLabel = 'الكلمات';
  static const charsNoSpaces = 'الأحرف (بدون مسافات)';
  static const charsWithSpaces = 'الأحرف (مع المسافات)';
  static const paragraphs = 'الفقرات';
  static const readingTime = 'وقت القراءة';
  static const minutes = 'دقيقة';
  static const insertLink = 'إدراج رابط';
  static const insertImageUrl = 'إدراج رابط صورة';
  static const imageLinkHint = 'https://… (رابط الصورة)';
  static const highlightColor = 'لون التظليل';
  static const textColor = 'لون النص';
  static const tableInserted = 'تم إدراج جدول';
  static const wordCount = 'عدد الكلمات';

  // أنواع الخطوط
  static const fontSansSerif = 'بلا زخرفة';
  static const fontSerif = 'مزخرف';
  static const fontMonospace = 'متساوي العرض';

  // شاشة المستندات
  static const myDocuments = 'مستنداتي';
  static const filterAll = 'الكل';
  static const filterRecent = 'الأخيرة';
  static const newFolder = 'مجلد جديد';
  static const folderName = 'اسم المجلد';
  static const noDocsFound = 'لا توجد مستندات';
  static const tryDifferentFilter = 'جرّب فلتراً مختلفاً أو أنشئ مستنداً جديداً';
  static const sortBy = 'الترتيب حسب';
  static const sortLastModified = 'آخر تعديل';
  static const sortDateCreated = 'تاريخ الإنشاء';
  static const sortName = 'الاسم (أ–ي)';
  static const sortWordCount = 'عدد الكلمات';

  // إجراءات المستند
  static const openEdit = 'فتح وتعديل';
  static const pinToTop = 'تثبيت في الأعلى';
  static const unpin = 'إلغاء التثبيت';
  static const addToFavorites = 'إضافة إلى المفضلة';
  static const removeFromFavorites = 'إزالة من المفضلة';
  static const rename = 'إعادة تسمية';
  static const moveToFolder = 'نقل إلى مجلد';
  static const colorTag = 'وسم لوني';
  static const versionHistory = 'سجل الإصدارات';
  static const duplicate = 'نسخ';
  static const documentDuplicated = 'تم نسخ المستند';
  static const moveToTrash = 'نقل إلى المهملات';
  static const movedToTrash = 'تم النقل إلى المهملات';
  static const noFolder = 'بدون مجلد';
  static const chooseColorTag = 'اختر وسماً لونياً';
  static const exportDocument = 'تصدير المستند';
  static const exportPdf = 'تصدير / طباعة كـ PDF';
  static const shareHtml = 'مشاركة كـ HTML';
  static const shareText = 'مشاركة كنص';
  static const pdfExportFailed = 'فشل تصدير PDF';

  // القوالب
  static const templates = 'القوالب';

  // المهملات
  static const trash = 'المهملات';
  static const empty = 'تفريغ';
  static const trashEmpty = 'المهملات فارغة';
  static const deletedDocsHere = 'ستظهر المستندات المحذوفة هنا';
  static const restored = 'تمت الاستعادة';
  static const deleteForever = 'حذف نهائي';
  static const cannotUndo = 'لا يمكن التراجع عن هذا الإجراء.';
  static const emptyTrash = 'تفريغ المهملات؟';
  static const emptyTrashMsg = 'سيتم حذف جميع المستندات الموجودة في المهملات نهائياً.';
  static const deletedAt = 'حُذف';

  // سجل الإصدارات
  static const noVersionsYet = 'لا توجد إصدارات بعد';
  static const versionsHint = 'يتم حفظ اللقطات تلقائياً أثناء التعديل. عُد لاحقاً لرؤية سجلك.';
  static const latest = 'الأحدث';
  static const view = 'عرض';
  static const restoreThisVersion = 'استعادة هذا الإصدار؟';
  static const restoreVersionMsg =
      'سيتم استبدال المحتوى الحالي بهذه اللقطة. مع الاحتفاظ بنسخة من الحالة الحالية في السجل.';
  static const versionRestored = 'تمت استعادة الإصدار';
  static const beforeRestore = 'قبل الاستعادة';
  static const autoSave = 'حفظ تلقائي';
  static const snapshot = 'لقطة';

  // الإعدادات
  static const settings = 'الإعدادات';
  static const appearance = 'المظهر';
  static const themeLight = 'فاتح';
  static const themeDark = 'داكن';
  static const themeSystem = 'حسب النظام';
  static const editor = 'المحرر';
  static const autoSaveSub = 'حفظ التغييرات تلقائياً';
  static const data = 'البيانات';
  static const statsSub = 'مستند';
  static const importTextFile = 'استيراد ملف نصي';
  static const importSub = 'إنشاء مستند من ملف .txt';
  static const importFailed = 'فشل الاستيراد';
  static const clearAllDocs = 'مسح جميع المستندات';
  static const clearAllSub = 'نقل كل شيء إلى المهملات';
  static const clearAllConfirm = 'مسح جميع المستندات؟';
  static const clearAllMsg =
      'سيؤدي هذا إلى نقل جميع مستنداتك إلى المهملات. يمكنك استعادتها لاحقاً.';
  static const moveAllToTrash = 'نقل الكل إلى المهملات';
  static const docsMovedToTrash = 'تم نقل المستندات إلى المهملات';
  static const about = 'حول';
  static const version = 'الإصدار 1.0.0';
  static const rateApp = 'قيّم التطبيق';
  static const rateSub = 'هل أعجبك وورد ماستر؟';
  static const rateThanks = 'شكراً لدعمك! ⭐';
  static const madeWith = 'صُنع بـ Flutter · وورد ماستر';
  static const yourName = 'اسمك';
  static const yourWritingStats = 'إحصائيات الكتابة';
  static const totalDocs = 'إجمالي المستندات';
  static const totalChars = 'إجمالي الأحرف';
  static const avgWordsPerDoc = 'متوسط الكلمات/مستند';
  static const inTrash = 'في المهملات';
  static const defaultUserName = 'مستخدم وورد ماستر';
  static const itemsCount = 'عنصر';

  // التواريخ النسبية
  static const justNow = 'الآن';
  static const minutesAgo = 'د';
  static const hoursAgo = 'س';
  static const yesterday = 'أمس';
  static const daysAgo = 'يوم';

  // وضع القراءة
  static const readMode = 'وضع القراءة';
  static const readerMode = 'القراءة';
  static const increaseFont = 'تكبير الخط';
  static const decreaseFont = 'تصغير الخط';
  static const emptyDocument = 'هذا المستند فارغ';

  // القفل والخصوصية
  static const lockDocument = 'قفل المستند';
  static const unlockDocument = 'إلغاء قفل المستند';
  static const locked = 'مقفل';
  static const setPin = 'تعيين رمز PIN';
  static const enterPin = 'أدخل رمز PIN';
  static const confirmPin = 'تأكيد رمز PIN';
  static const wrongPin = 'رمز PIN غير صحيح';
  static const pinMismatch = 'الرمزان غير متطابقين';
  static const pinTooShort = 'يجب أن يكون الرمز 4 أرقام على الأقل';
  static const documentLocked = 'تم قفل المستند';
  static const documentUnlocked = 'تم إلغاء قفل المستند';
  static const enterPinToOpen = 'أدخل الرمز لفتح المستند';
  static const lockHint = 'احمِ مستنداتك الخاصة برمز سري';
  static const unlock = 'فتح';

  // الوضع المركّز
  static const focusMode = 'الوضع المركّز';
  static const focusModeOn = 'تم تفعيل الوضع المركّز';
  static const exitFocus = 'الخروج من الوضع المركّز';

  // التصدير الإضافي
  static const shareMarkdown = 'مشاركة كـ Markdown';
  static const copyToClipboard = 'نسخ النص';
  static const copiedToClipboard = 'تم نسخ النص إلى الحافظة';

  // لوحة القيادة وأهداف الكتابة
  static const todayProgress = 'تقدّم اليوم';
  static const dailyGoal = 'الهدف اليومي';
  static const dailyGoalSub = 'عدد الكلمات المستهدف يومياً';
  static const wordsToday = 'كلمات اليوم';
  static const goalReached = 'تهانينا! حققت هدفك اليومي 🎉';
  static const keepWriting = 'استمر في الكتابة لتحقيق هدفك';
  static const setDailyGoal = 'تعيين الهدف اليومي';
  static const goalWords = 'عدد الكلمات';
  static const streak = 'أيام متتالية';
  static const dayStreak = 'يوم متتالٍ';

  // حول التطبيق
  static const aboutApp = 'حول التطبيق';
  static const appTagline = 'محرر مستندات احترافي بين يديك';
  static const featuresTitle = 'المميزات';
  static const feature1 = 'محرر نصوص غني بالتنسيقات';
  static const feature2 = 'قوالب جاهزة احترافية';
  static const feature3 = 'تصدير PDF و HTML و Markdown';
  static const feature4 = 'سجل إصدارات تلقائي';
  static const feature5 = 'قفل المستندات بكلمة سر';
  static const feature6 = 'وضع داكن وخطوط قابلة للتخصيص';
  static const developedWith = 'تم التطوير باستخدام Flutter';

  // الوسوم
  static const tags = 'الوسوم';
  static const addTag = 'إضافة وسم';
  static const manageTags = 'إدارة الوسوم';
  static const tagHint = 'اكتب وسماً واضغط إدخال';
  static const noTags = 'لا توجد وسوم بعد';
  static const filterByTag = 'تصفية حسب الوسم';
  static const tagsUpdated = 'تم تحديث الوسوم';

  // الأرشيف
  static const archive = 'الأرشيف';
  static const archived = 'مؤرشف';
  static const archiveDoc = 'أرشفة المستند';
  static const unarchiveDoc = 'إلغاء الأرشفة';
  static const documentArchived = 'تمت أرشفة المستند';
  static const documentUnarchived = 'تم إلغاء الأرشفة';
  static const noArchivedDocs = 'لا توجد مستندات مؤرشفة';
  static const archivedHint = 'المستندات المؤرشفة مخفية عن القائمة الرئيسية';

  // التحليلات
  static const insights = 'التحليلات';
  static const insightsTitle = 'تحليلات الكتابة';
  static const weeklyActivity = 'نشاط آخر 7 أيام';
  static const overview = 'نظرة عامة';
  static const totalWritingDays = 'أيام الكتابة';
  static const bestStreak = 'أطول سلسلة';
  static const avgWordsDay = 'متوسط الكلمات/يوم';
  static const docsByFolder = 'المستندات حسب المجلد';
  static const noActivityYet = 'ابدأ الكتابة لرؤية تحليلاتك هنا';
  static const wordsUnit = 'كلمة';
  static const day = 'يوم';

  // القوالب المخصصة
  static const saveAsTemplate = 'حفظ كقالب';
  static const myTemplates = 'قوالبي';
  static const templateSaved = 'تم حفظ القالب';
  static const templateName = 'اسم القالب';
  static const noCustomTemplates = 'لا توجد قوالب مخصصة';
  static const useTemplate = 'استخدام القالب';
  static const deleteTemplate = 'حذف القالب';

  // النسخ الاحتياطي
  static const backup = 'النسخ الاحتياطي';
  static const exportBackup = 'تصدير نسخة احتياطية';
  static const exportBackupSub = 'احفظ كل مستنداتك في ملف واحد';
  static const importBackup = 'استعادة نسخة احتياطية';
  static const importBackupSub = 'استرجع مستنداتك من ملف نسخة احتياطية';
  static const backupExported = 'تم تصدير النسخة الاحتياطية';
  static const backupRestored = 'تمت الاستعادة:';
  static const backupRestoredDocs = 'مستند';
  static const backupInvalid = 'ملف النسخة الاحتياطية غير صالح';
  static const restoreConfirm = 'استعادة المستندات';
  static const restoreMsg =
      'سيتم إضافة المستندات من الملف. المستندات الموجودة لن تتأثر. متابعة؟';
  static const restore2 = 'استعادة';

  // البحث في المحرر
  static const matchesFound = 'نتيجة';
  static const noMatches = 'لا توجد نتائج';

  // قفل التطبيق (App Lock)
  static const appLock = 'قفل التطبيق';
  static const appLockSub = 'حماية التطبيق برمز PIN عند الفتح';
  static const enableAppLock = 'تفعيل قفل التطبيق';
  static const disableAppLock = 'إيقاف قفل التطبيق';
  static const appLockEnabled = 'تم تفعيل قفل التطبيق';
  static const appLockDisabled = 'تم إيقاف قفل التطبيق';
  static const unlockApp = 'افتح القفل للمتابعة';
  static const changeAppPin = 'تغيير رمز القفل';
  static const security = 'الأمان والخصوصية';

  // تخصيص المظهر
  static const accentColor = 'لون التطبيق';
  static const accentColorSub = 'اختر اللون الأساسي للتطبيق';
  static const accentSaved = 'تم تغيير لون التطبيق';

  // استعراض الوسوم
  static const allTagsTitle = 'كل الوسوم';
  static const tagDocsTitle = 'مستندات الوسم';
  static const documentsCount = 'مستند';
  static const noTaggedDocs = 'لا توجد مستندات بهذا الوسم';

  // متوسط متقدم
  static const monthlyActivity = 'نشاط آخر 30 يوماً';
  static const productivityScore = 'مؤشر الإنتاجية';
  static const totalDocsLabel = 'إجمالي المستندات';
  static const totalWordsLabel = 'إجمالي الكلمات';

  // البحث داخل المحرر
  static const findInDoc = 'بحث في المستند';
  static const searchHint = 'اكتب كلمة للبحث...';
  static const nextMatch = 'التالي';
  static const prevMatch = 'السابق';
}
