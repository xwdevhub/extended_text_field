//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<pasteboard/PasteboardPlugin.h>)
#import <pasteboard/PasteboardPlugin.h>
#else
@import pasteboard;
#endif

#if __has_include(<path_provider_foundation/PathProviderPlugin.h>)
#import <path_provider_foundation/PathProviderPlugin.h>
#else
@import path_provider_foundation;
#endif

#if __has_include(<rich_clipboard_ios/RichClipboardPlugin.h>)
#import <rich_clipboard_ios/RichClipboardPlugin.h>
#else
@import rich_clipboard_ios;
#endif

#if __has_include(<url_launcher_ios/URLLauncherPlugin.h>)
#import <url_launcher_ios/URLLauncherPlugin.h>
#else
@import url_launcher_ios;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [PasteboardPlugin registerWithRegistrar:[registry registrarForPlugin:@"PasteboardPlugin"]];
  [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
  [RichClipboardPlugin registerWithRegistrar:[registry registrarForPlugin:@"RichClipboardPlugin"]];
  [URLLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"URLLauncherPlugin"]];
}

@end