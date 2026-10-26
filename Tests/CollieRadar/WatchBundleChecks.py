"""Check final Watch bundle metadata, not merely Xcode build settings."""
import plistlib
import sys
from pathlib import Path


def check(app):
    with (app / "Info.plist").open("rb") as stream:
        phone_companion = plistlib.load(stream)
    with (app / "PlugIns/YihuWatchWidgets.appex/Info.plist").open("rb") as stream:
        widget = plistlib.load(stream)
    group = phone_companion.get("YihuAppGroup")
    assert isinstance(group, str) and group.startswith("group.") and "$(" not in group, \
        "Watch app must contain a resolved App Group identifier"
    assert widget.get("YihuAppGroup") == group, "Watch app and widget App Groups must match"
    bundle_id = phone_companion.get("CFBundleIdentifier")
    assert isinstance(bundle_id, str) and bundle_id and "$(" not in bundle_id
    assert widget.get("CFBundleIdentifier", "").startswith(bundle_id + "."), \
        "Widget bundle identifier must extend the Watch app identifier"
    assert widget.get("NSExtension", {}).get("NSExtensionPointIdentifier") == "com.apple.widgetkit-extension"
    schemes = [scheme for entry in phone_companion.get("CFBundleURLTypes", [])
               for scheme in entry.get("CFBundleURLSchemes", [])]
    assert "yihu-watch" in schemes, "Watch category links need a registered URL scheme"
    icon_name = phone_companion.get("CFBundleIconName") or phone_companion.get("CFBundleIcons", {}).get("CFBundlePrimaryIcon", {}).get("CFBundleIconName")
    assert icon_name == "AppIcon", "Watch app must declare its compiled launcher icon"
    assert (app / "Assets.car").is_file() and (app / "Assets.car").stat().st_size > 0, \
        "Watch icon asset catalog must be included in the installed bundle"
    print("Watch bundle checks passed: resolved shared group, widget identity, URL scheme and launcher icon")


if __name__ == "__main__":
    check(Path(sys.argv[1]))
