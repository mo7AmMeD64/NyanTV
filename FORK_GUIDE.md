# دليل Fork وتعديل NyanTV

## 📌 الملخص

هذا المشروع هو **Fork معدّل من NyanTV** مضاف إليه دعم Witcher API الخاص ومحذوف منه نظام الامتدادات الخارجية.

---

## 🔀 خطوات عمل Fork في GitHub

### 1. اذهب إلى صفحة المستودع الأصلي:
```
https://github.com/NyanTV/NyanTV
```

### 2. اضغط زر **Fork** في الزاوية اليمنى العليا

### 3. اختر حسابك (أو منظمتك) وأنشئ الـ Fork

### 4. استنسخ Fork الخاص بك:
```bash
git clone https://github.com/<اسمك>/NyanTV.git
cd NyanTV
```

### 5. أضف الملفات الجديدة المرفقة في هذا المجلد:
```bash
# انسخ الملفات الجديدة فقط
cp -r lib/controllers/witcher/ <مسار-مستودعك>/lib/controllers/
cp -r lib/screens/witcher/     <مسار-مستودعك>/lib/screens/
cp -r lib/stubs/               <مسار-مستودعك>/lib/stubs/
```

### 6. طبّق التعديلات على الملفات الموجودة (راجع قسم التغييرات أدناه)

### 7. ارفع التغييرات:
```bash
git add .
git commit -m "feat: integrate Witcher API, remove extensions system"
git push origin main
```

---

## 📂 الملفات الجديدة (مضافة)

| الملف | الوصف |
|-------|-------|
| `lib/controllers/witcher/witcher_api.dart` | كنترولر API - جلب البيانات من witcher |
| `lib/screens/witcher/witcher_home.dart` | الصفحة الرئيسية بالأنمي |
| `lib/screens/witcher/witcher_details.dart` | صفحة تفاصيل الأنمي + الحلقات |
| `lib/screens/witcher/witcher_player.dart` | مشغّل الفيديو مع اختيار السيرفر |
| `lib/screens/witcher/witcher_search.dart` | البحث عن الأنمي |
| `lib/stubs/extension_stubs.dart` | Stubs لضمان الـ compile بدون dartotsu |

---

## ✏️ التعديلات على الملفات الموجودة

### `lib/main.dart`
```
- import 'screens/extensions/ExtensionScreen.dart'       ← احذف
+ import 'screens/witcher/witcher_home.dart'             ← أضف
+ import 'screens/witcher/witcher_search.dart'           ← أضف

// في _buildRoute و _buildRouteFresh:
- 4 => ExtensionScreen(disableGlow: true)               ← استبدل
+ 4 => WitcherHome()                                    ← بهذا

// في _Sidebar النافبار:
- label: "Extensions" (icon: Icons.extension_*)         ← استبدل
+ label: "مشاهدة"    (icon: Icons.live_tv_*)            ← بهذا
```

### `pubspec.yaml`
```yaml
# احذف هذه الأسطر بالكامل:
  dartotsu_extension_bridge:
    git:
      url: https://github.com/aayush2622/DartotsuExtensionBridge.git
      ref: 5d81115
```

### جميع الملفات الأخرى
في كل ملف `.dart` يحتوي على:
```dart
import 'package:dartotsu_extension_bridge/...';
```
**احذف هذا السطر** (الكود يستخدم stubs بدلاً منه).

---

## 🏗️ هيكل API المستخدم

```
GET https://1we323-witcher.hf.space/api/main?page=1
    → { hits: [{id, name, poster, type}] }

GET https://1we323-witcher.hf.space/api/search?q=<query>
    → [{ id, name, poster, type }]

GET https://firestore.googleapis.com/v1/projects/animewitcher-1c66d/databases/(default)/documents/anime_list/<animeId>/episodes?pageSize=100
    → { documents: [{name: ".../episodes/<epId>"}], nextPageToken? }

GET https://1we323-witcher.hf.space/api/servers_resolved?anime=<id>&ep=<epId>
    → { servers: [{name, url, proxy_url?, quality?, lang?, playable}] }
```

---

## 🚀 البناء

```bash
flutter pub get
flutter build apk --release
```

---

## 📝 ملاحظة على الترخيص

NyanTV مرخص تحت **MIT License** مما يسمح بعمل Fork وتعديله.
يجب الإبقاء على ملف `LICENSE.md` الأصلي في مشروعك.
