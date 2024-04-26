#import <Foundation/Foundation.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "Globals.h"
#import "Debug.h"


#define TWEAK_NAME @"SiriCoinControl"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]
#define BUNDLE_NOTIFY (CFStringRef)[NSString stringWithFormat:@"%@/ReloadPrefs", BUNDLE]

#define COIN_CHOICE_REQUEST @"com.wrp1002.SiriCoinControlServer.CoinChoice"
#define COIN_CHOICE_RESPONSE @"com.wrp1002.SiriCoinControlServer.CoinChoiceResponse"
#define PREFS_REQUEST @"com.wrp1002.SiriCoinControlServer.PrefsRequest"
#define PREFS_RESPONSE @"com.wrp1002.SiriCoinControlServer.PrefsResponse"



@interface SBVolumeHardwareButtonActions
-(void)handleSCCVolumeIncreasePressDown;
-(void)handleSCCVolumeDecreasePressDown;
@end