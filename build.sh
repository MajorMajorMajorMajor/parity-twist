#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
LIBS_DIR="$PROJECT_DIR/libs"
SRC_DIR="$PROJECT_DIR/src"
RES_DIR="$PROJECT_DIR/res"
ASSETS_DIR="$PROJECT_DIR/assets"
ANDROID_JAR="$LIBS_DIR/android.jar"
PACKAGE="com.paritytwist"
MIN_SDK=26
TARGET_SDK=34

echo "=== Parity Twist Build ==="

# Clean
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/compiled_res" "$BUILD_DIR/classes" "$BUILD_DIR/dex"

# Step 1: Compile resources
echo "[1/6] Compiling resources..."
aapt2 compile --dir "$RES_DIR" -o "$BUILD_DIR/compiled_res/"

# Step 2: Link resources
echo "[2/6] Linking resources..."
aapt2 link \
    -o "$BUILD_DIR/parity-unaligned.apk" \
    -I "$ANDROID_JAR" \
    --manifest "$PROJECT_DIR/AndroidManifest.xml" \
    --min-sdk-version "$MIN_SDK" \
    --target-sdk-version "$TARGET_SDK" \
    --java "$BUILD_DIR/gen" \
    -A "$ASSETS_DIR" \
    --auto-add-overlay \
    "$BUILD_DIR/compiled_res/"*.flat

# Step 3: Compile Java
echo "[3/6] Compiling Java..."
find "$SRC_DIR" -name "*.java" > "$BUILD_DIR/sources.txt"
find "$BUILD_DIR/gen" -name "*.java" >> "$BUILD_DIR/sources.txt"

javac \
    --release 11 \
    -classpath "$ANDROID_JAR" \
    -d "$BUILD_DIR/classes" \
    @"$BUILD_DIR/sources.txt"

# Step 4: Convert to DEX
echo "[4/6] Converting to DEX..."
find "$BUILD_DIR/classes" -name "*.class" > "$BUILD_DIR/classfiles.txt"
java -cp "$LIBS_DIR/r8.jar" com.android.tools.r8.D8 \
    --min-api "$MIN_SDK" \
    --lib "$ANDROID_JAR" \
    --output "$BUILD_DIR/dex" \
    @"$BUILD_DIR/classfiles.txt"

# Step 5: Add DEX to APK
echo "[5/6] Packaging APK..."
cp "$BUILD_DIR/parity-unaligned.apk" "$BUILD_DIR/parity-twist.apk"
cd "$BUILD_DIR/dex"
zip -u "$BUILD_DIR/parity-twist.apk" classes.dex
cd "$PROJECT_DIR"

# Step 6: Sign APK
echo "[6/6] Signing APK..."

# Create keystore if it doesn't exist
KEYSTORE="$PROJECT_DIR/keystore/debug.keystore"
if [ ! -f "$KEYSTORE" ]; then
    mkdir -p "$PROJECT_DIR/keystore"
    keytool -genkeypair \
        -keystore "$KEYSTORE" \
        -storepass android \
        -keypass android \
        -alias androiddebugkey \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=Debug,O=Android,C=US"
fi

apksigner sign \
    --ks "$KEYSTORE" \
    --ks-pass pass:android \
    --key-pass pass:android \
    --ks-key-alias androiddebugkey \
    "$BUILD_DIR/parity-twist.apk"

echo ""
echo "=== Build complete ==="
echo "APK: $BUILD_DIR/parity-twist.apk"
ls -lh "$BUILD_DIR/parity-twist.apk"
