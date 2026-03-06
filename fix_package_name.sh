#!/bin/bash
# fix_package_name.sh
cd ~/NyanTV_clean 2>/dev/null || cd ~/NyanTV

echo "=== اسم الـ package الحقيقي ==="
PACKAGE_NAME=$(grep "^name:" pubspec.yaml | awk '{print $2}' | tr -d '"'"'"' ')
echo "Package name: $PACKAGE_NAME"

if [ -z "$PACKAGE_NAME" ]; then
  echo "ERROR: لم يُعثر على اسم الـ package"
  exit 1
fi

echo ""
echo "=== استبدال 'nyantv' بـ '$PACKAGE_NAME' في جميع الـ imports ==="
find lib -name "*.dart" | xargs grep -l "package:nyantv/" | while read FILE; do
  sed -i "s|package:nyantv/|package:$PACKAGE_NAME/|g" "$FILE"
  echo "✓ $FILE"
done

echo ""
echo "=== تحديث ملف stubs إن كان يستخدم package:nyantv ==="
sed -i "s|package:nyantv/|package:$PACKAGE_NAME/|g" lib/stubs/extension_stubs.dart 2>/dev/null || true

echo ""
echo "=== Push ==="
git add .
git commit -m "fix: correct package name in all stub imports ($PACKAGE_NAME)"
git push origin main

echo ""
echo "✅ تم! شغّل Build APK من Actions"
