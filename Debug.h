#import <UIKit/UIKit.h>

#define TWEAK_NAME @"SiriCoinControl"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]
#define settingsPath [NSString stringWithFormat:@"/var/mobile/Library/Preferences/com.wrp1002.%@.plist", [TWEAK_NAME lowercaseString]]

@interface Debug : NSObject
	+(UIWindow*)GetKeyWindow;
	+(void)ShowAlert:(NSString *)msg;
	+(void)Log:(NSString *)msg;
	+(void)LogException:(NSException *)e;
	+(void)SpringBoardReady;
@end