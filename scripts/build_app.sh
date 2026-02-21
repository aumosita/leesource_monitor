#!/bin/bash
set -e

APP_NAME="LeeSource Monitor"
BUNDLE_ID="com.leesource.monitor"
EXECUTABLE="LeeSourceMonitor"
BUILD_DIR=".build/release"
APP_DIR="${APP_NAME}.app"

echo "📦 Creating ${APP_DIR}..."

# Clean previous
rm -rf "${APP_DIR}"

# Create bundle structure
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# Copy executable
cp "${BUILD_DIR}/${EXECUTABLE}" "${APP_DIR}/Contents/MacOS/"

# Copy bundled resources
RESOURCE_BUNDLE="${BUILD_DIR}/LeeSourceMonitor_LeeSourceMonitor.bundle"
if [ -d "${RESOURCE_BUNDLE}" ]; then
    cp -R "${RESOURCE_BUNDLE}" "${APP_DIR}/Contents/Resources/"
fi

# Create Info.plist
cat > "${APP_DIR}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>15.0</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create .icns from PNG
ICON_PNG="Sources/LeeSourceMonitor/Resources/AppIcon.png"
if [ -f "${ICON_PNG}" ]; then
    ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
    mkdir -p "${ICONSET_DIR}"
    
    # Convert to proper PNG format first
    TEMP_PNG=$(mktemp).png
    sips -s format png -s formatOptions best "${ICON_PNG}" --out "${TEMP_PNG}" > /dev/null 2>&1
    
    sips -z 16 16     "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null 2>&1
    sips -z 32 32     "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null 2>&1
    sips -z 32 32     "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null 2>&1
    sips -z 64 64     "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null 2>&1
    sips -z 128 128   "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null 2>&1
    sips -z 256 256   "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null 2>&1
    sips -z 256 256   "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null 2>&1
    sips -z 512 512   "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null 2>&1
    sips -z 512 512   "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null 2>&1
    sips -z 1024 1024 "${TEMP_PNG}" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null 2>&1
    
    if iconutil -c icns "${ICONSET_DIR}" -o "${APP_DIR}/Contents/Resources/AppIcon.icns" 2>/dev/null; then
        echo "✅ Icon (.icns) created"
    else
        # Fallback: just copy the PNG
        cp "${ICON_PNG}" "${APP_DIR}/Contents/Resources/AppIcon.png"
        echo "⚠️  Using PNG icon (icns conversion failed)"
    fi
    rm -f "${TEMP_PNG}"
fi

echo "✅ ${APP_DIR} created successfully!"
echo "📍 Location: $(pwd)/${APP_DIR}"
du -sh "${APP_DIR}"
