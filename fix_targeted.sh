#!/bin/bash
# fix_targeted.sh
cd ~/NyanTV

echo "=== 1. إصلاح bottom_sheet.dart - BoottomSheetItem و show ==="
python3 << 'PYEOF'
with open('lib/screens/anime/watch/controls/widgets/bottom_sheet.dart', 'r') as f:
    content = f.read()

# أضف import للـ stubs في البداية إن لم يكن موجوداً
if 'extension_stubs' not in content:
    content = "import 'package:nyantv/stubs/extension_stubs.dart';\n" + content

# أضف class BottomSheetItem stub بعد أول import
stub = """
// Stub for BottomSheetItem
class BottomSheetItem {
  final String title;
  final dynamic icon;
  final VoidCallback? onTap;
  const BottomSheetItem({required this.title, this.icon, this.onTap});
}
"""

# أضف الـ stub قبل أول class
import re
content = re.sub(r'(class DynamicBottomSheet)', stub + r'\1', content, count=1)

with open('lib/screens/anime/watch/controls/widgets/bottom_sheet.dart', 'w') as f:
    f.write(content)
print("✓ bottom_sheet.dart - BottomSheetItem stub added")
PYEOF

echo ""
echo "=== 2. إصلاح episode_list_builder.dart - Video ==="
python3 << 'PYEOF'
with open('lib/screens/anime/widgets/episode_list_builder.dart', 'r') as f:
    content = f.read()

# استبدل List<dynamic> التي تحولت خطأ من List<Video>
# والـ Video( calls
import re

# نعيد List<Video> لكن نستخدم الـ Video من Hive
# نضيف import لـ video.dart من Hive
if "models/Offline/Hive/video.dart" not in content:
    content = "import 'package:nyantv/models/Offline/Hive/video.dart';\n" + content

# نعيد Video type
content = content.replace('List<dynamic>', 'List<Video>')

# إصلاح Video({ تعارض مع stub - نحذف stub Video ونستخدم Hive Video
with open('lib/screens/anime/widgets/episode_list_builder.dart', 'w') as f:
    f.write(content)
print("✓ episode_list_builder.dart")
PYEOF

echo ""
echo "=== 3. إصلاح player_controller.dart - تعليق كتلة getVideoLinks ==="
python3 << 'PYEOF'
with open('lib/screens/anime/watch/controller/player_controller.dart', 'r') as f:
    lines = f.readlines()

# نبحث عن السطور المشكلة (796-810) ونعلقها
new_lines = []
skip_block = False
i = 0
while i < len(lines):
    line = lines[i]
    # تعليق PlayerBottomSheets و data في السياق الخاطئ
    if 'PlayerBottomSheets.showLoader()' in line or 'PlayerBottomSheets.hideLoader()' in line:
        new_lines.append('      // STUB: ' + line.lstrip())
    elif '// STUB:' in line and 'final data' in lines[i] if i < len(lines) else False:
        new_lines.append('      // STUB: ' + line.lstrip())
    else:
        new_lines.append(line)
    i += 1

with open('lib/screens/anime/watch/controller/player_controller.dart', 'w') as f:
    f.writelines(new_lines)
print("✓ player_controller.dart")
PYEOF

echo ""
echo "=== 4. حذف Video stub من stubs لتجنب تعارض مع Hive Video ==="
python3 << 'PYEOF'
with open('lib/stubs/extension_stubs.dart', 'r') as f:
    content = f.read()

# حذف VideoStub class (لم نكن نحتاجه)
import re
content = re.sub(r'// Video and Track.*?class Track \{[^}]*\}', 
    '''// Track stub
class Track {
  final String? url;
  final String? label;
  const Track({this.url, this.label});
}''', content, flags=re.DOTALL)

# تأكد أن Video غير موجود في الـ stubs
content = re.sub(r'class VideoStub \{[^}]*\}', '', content)

with open('lib/stubs/extension_stubs.dart', 'w') as f:
    f.write(content)
print("✓ stubs - Video removed, Track kept")
PYEOF

echo ""
echo "=== 5. إصلاح video.dart - Track يجب أن يكون من Hive وليس من stubs ==="
# نزيل import stubs من video.dart لأن Track يجب أن يُعرَّف فيه
python3 << 'PYEOF'
with open('lib/models/Offline/Hive/video.dart', 'r') as f:
    content = f.read()

# احذف import stubs إن أضفناه
import re
content = re.sub(r"import 'package:nyantv/stubs/extension_stubs\.dart';\n", '', content)

# أضف class Track و Video مباشرة في الملف إن لم يكونا موجودَين
if 'class Track' not in content and 'class Video' not in content:
    # أضف في النهاية
    content += """
// Stub classes for compatibility
class Video {
  final String? url;
  final String? quality;
  final List<Track> subtitleTracks;
  final List<Track> audioTracks;
  const Video({this.url, this.quality, 
    this.subtitleTracks = const [], 
    this.audioTracks = const []});
  static Video fromVideo(dynamic v) => Video(url: v?.url?.toString());
}

class Track {
  final String? url;
  final String? label;
  final String? lang;
  const Track({this.url, this.label, this.lang});
}
"""

with open('lib/models/Offline/Hive/video.dart', 'w') as f:
    f.write(content)
print("✓ video.dart - Video and Track defined")
PYEOF

echo ""
echo "✅ اكتمل الإصلاح!"
echo ""
echo "  git add ."
echo "  git commit -m 'fix: targeted fixes for remaining compile errors'"
echo "  git push origin main"
