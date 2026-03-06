#!/bin/bash
echo "🔧 Android SDK/NDK Fix für macOS..."

# 1. Prüfe Android SDK
echo "📱 Prüfe Android SDK..."
if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    echo "✅ ANDROID_HOME gesetzt: $ANDROID_HOME"
fi

# 2. Installiere fehlende Komponenten
echo "⬇️  Installiere Android Komponenten..."
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses --sdk_root="$ANDROID_HOME"
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$ANDROID_HOME" \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "cmake;3.22.1" \
    "ndk;25.1.8937393"

# 3. Prüfe NDK
echo "🔍 Prüfe NDK Installation..."
if [ -d "$ANDROID_HOME/ndk/25.1.8937393" ]; then
    echo "✅ NDK 25.1.8937393 gefunden"
else
    echo "⚠️  NDK nicht gefunden, versuche alternative Version..."
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install "ndk;26.1.10909125"
fi

# 4. local.properties korrigieren
echo "📝 Korrigiere local.properties..."
cat > android/local.properties << EOF
sdk.dir=$ANDROID_HOME
ndk.dir=$ANDROID_HOME/ndk/25.1.8937393
cmake.dir=$ANDROID_HOME/cmake/3.22.1
EOF

echo "✅ Fix abgeschlossen! Versuche Build erneut..."