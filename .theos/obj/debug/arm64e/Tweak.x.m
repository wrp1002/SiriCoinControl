#line 1 "Tweak.x"
#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>

#define kIdentifier @"com.wrp1002.siricoincontrol"
#define kSettingsChangedNotification (CFStringRef)@"com.wrp1002.siricoincontrol/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.wrp1002.siricoincontrol.plist"





BOOL enabled = true;



int startupDelay = 5;
HBPreferences *preferences;

int coinChoice = -1;
bool siriVisible = false;



NSString *LogTweakName = @"SiriCoinControl";
bool springboardReady = false;

UIWindow* GetKeyWindow() {
    UIWindow        *foundWindow = nil;
    NSArray         *windows = [[UIApplication sharedApplication]windows];
    for (UIWindow   *window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}


void ShowAlert(NSString *msg, NSString *title) {
	if (!springboardReady) return;

	UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];

    
    UIAlertAction* dismissButton = [UIAlertAction
                                actionWithTitle:@"Cool!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
									
                                }];

    
    [alert addAction:dismissButton];

    [GetKeyWindow().rootViewController presentViewController:alert animated:YES completion:nil];
}


void Log(NSString *msg) {
	NSLog(@"%@: %@", LogTweakName, msg);
}


void LogException(NSException *e) {
	NSLog(@"%@: NSException caught", LogTweakName);
	NSLog(@"%@: Name:%@", LogTweakName, e.name);
	NSLog(@"%@: Reason:%@", LogTweakName, e.reason);
	
}





void Save() {
	Log(@"Saving to file");
	
}





#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SRServerUtteranceView; @class SpringBoard; @class SBVolumeHardwareButtonActions; @class VSSpeechRequest; @class SiriPresentationViewController; 


#line 88 "Tweak.x"
static void (*_logos_orig$SpringboardHooks$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$SpringboardHooks$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$SpringboardHooks$SiriPresentationViewController$_presentSiriViewControllerWithPresentationOptions$requestOptions$)(_LOGOS_SELF_TYPE_NORMAL SiriPresentationViewController* _LOGOS_SELF_CONST, SEL, id, id); static void _logos_method$SpringboardHooks$SiriPresentationViewController$_presentSiriViewControllerWithPresentationOptions$requestOptions$(_LOGOS_SELF_TYPE_NORMAL SiriPresentationViewController* _LOGOS_SELF_CONST, SEL, id, id); static void (*_logos_orig$SpringboardHooks$SiriPresentationViewController$dismiss)(_LOGOS_SELF_TYPE_NORMAL SiriPresentationViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$SpringboardHooks$SiriPresentationViewController$dismiss(_LOGOS_SELF_TYPE_NORMAL SiriPresentationViewController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$SpringboardHooks$VSSpeechRequest$setText$)(_LOGOS_SELF_TYPE_NORMAL VSSpeechRequest* _LOGOS_SELF_CONST, SEL, NSString *); static void _logos_method$SpringboardHooks$VSSpeechRequest$setText$(_LOGOS_SELF_TYPE_NORMAL VSSpeechRequest* _LOGOS_SELF_CONST, SEL, NSString *); static void (*_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressDown)(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressDown(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressDown)(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressDown(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressUp)(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressUp(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressUp)(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressUp(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST, SEL); 

	

		
		static void _logos_method$SpringboardHooks$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
			_logos_orig$SpringboardHooks$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
			springboardReady = true;
		}

	

	
	
		static void _logos_method$SpringboardHooks$SiriPresentationViewController$_presentSiriViewControllerWithPresentationOptions$requestOptions$(_LOGOS_SELF_TYPE_NORMAL SiriPresentationViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2) {
			_logos_orig$SpringboardHooks$SiriPresentationViewController$_presentSiriViewControllerWithPresentationOptions$requestOptions$(self, _cmd, arg1, arg2);
			Log(@"- (void)_presentSiriViewControllerWithPresentationOptions:(id)arg1 requestOptions:(id)arg2;");
			siriVisible = true;
			[preferences setInteger:(int)siriVisible forKey:@"kSiriVisible"];
		}

		




		static void _logos_method$SpringboardHooks$SiriPresentationViewController$dismiss(_LOGOS_SELF_TYPE_NORMAL SiriPresentationViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
			_logos_orig$SpringboardHooks$SiriPresentationViewController$dismiss(self, _cmd);
			Log(@"- (void)dismiss;");
			siriVisible = false;
			[preferences setInteger:(int)siriVisible forKey:@"kSiriVisible"];
		}

	

	
	
		static void _logos_method$SpringboardHooks$VSSpeechRequest$setText$(_LOGOS_SELF_TYPE_NORMAL VSSpeechRequest* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString * arg1) {

			if (!siriVisible || !enabled) {
				_logos_orig$SpringboardHooks$VSSpeechRequest$setText$(self, _cmd, arg1);
				return;
			}

			NSString *newText = arg1;

			if (coinChoice == 0) {
				newText = [newText stringByReplacingOccurrencesOfString:@"Heads" withString:@"Tails"];
				newText = [newText stringByReplacingOccurrencesOfString:@"heads" withString:@"tails"];
			}
			else if (coinChoice == 1) {
				newText = [newText stringByReplacingOccurrencesOfString:@"Tails" withString:@"Heads"];
				newText = [newText stringByReplacingOccurrencesOfString:@"tails" withString:@"heads"];
			}

			_logos_orig$SpringboardHooks$VSSpeechRequest$setText$(self, _cmd, newText);
		}
	

	
	
		static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressDown(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
			Log(@"volumeIncreasePressDown");

			if (siriVisible) {
				coinChoice = 1;
				[preferences setInteger:coinChoice forKey:@"kCoinChoice"];
			}
			else
				_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressDown(self, _cmd);
		}
		static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressDown(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
			Log(@"volumeDecreasePressDown");

			if (siriVisible) {
				coinChoice = 0;
				[preferences setInteger:coinChoice forKey:@"kCoinChoice"];
			}
			else
				_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressDown(self, _cmd);
		}

		static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressUp(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
			Log(@"volumeIncreasePressUp");

			coinChoice = -1;
			[preferences setInteger:coinChoice forKey:@"kCoinChoice"];
			_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressUp(self, _cmd);
		}
		static void _logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressUp(_LOGOS_SELF_TYPE_NORMAL SBVolumeHardwareButtonActions* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
			Log(@"volumeDecreasePressUp");

			coinChoice = -1;
			[preferences setInteger:coinChoice forKey:@"kCoinChoice"];
			_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressUp(self, _cmd);
		}
	

	



static void (*_logos_orig$SiriHooks$SRServerUtteranceView$setText$)(_LOGOS_SELF_TYPE_NORMAL SRServerUtteranceView* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$SiriHooks$SRServerUtteranceView$setText$(_LOGOS_SELF_TYPE_NORMAL SRServerUtteranceView* _LOGOS_SELF_CONST, SEL, id); 

	
	
		static void _logos_method$SiriHooks$SRServerUtteranceView$setText$(_LOGOS_SELF_TYPE_NORMAL SRServerUtteranceView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
			Log(@"SRServerUtteranceView -(void)setText:(NSString *)arg1");
			
			
			siriVisible = (bool)[preferences integerForKey:@"kSiriVisible"];

			if (!siriVisible || !enabled) {
				Log(@"No happen :(");
				Log([NSString stringWithFormat:@"SiriVisible: %d   Enabled: %d", siriVisible, enabled]);
				_logos_orig$SiriHooks$SRServerUtteranceView$setText$(self, _cmd, arg1);
			}
			else {
				Log(@"Happen! :)");

				
				coinChoice = [preferences integerForKey:@"kCoinChoice"];

				NSString *newText = arg1;

				if (coinChoice == 0) {
					newText = [newText stringByReplacingOccurrencesOfString:@"Heads" withString:@"Tails!"];
					newText = [newText stringByReplacingOccurrencesOfString:@"heads" withString:@"tails"];
				}
				else if (coinChoice == 1) {
					newText = [newText stringByReplacingOccurrencesOfString:@"Tails" withString:@"Heads!"];
					newText = [newText stringByReplacingOccurrencesOfString:@"tails" withString:@"heads!"];
				}

				_logos_orig$SiriHooks$SRServerUtteranceView$setText$(self, _cmd, newText);
			}
		}
	


	






static __attribute__((constructor)) void _logosLocalCtor_e13ba4cd(int __unused argc, char __unused **argv, char __unused **envp) {
	Log([NSString stringWithFormat:@"============== %@ started ==============", LogTweakName]);

	
	preferences = [[HBPreferences alloc] initWithIdentifier:kIdentifier];
	
	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {

		{Class _logos_class$SpringboardHooks$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$SpringboardHooks$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$SpringboardHooks$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$SpringboardHooks$SpringBoard$applicationDidFinishLaunching$);}Class _logos_class$SpringboardHooks$SiriPresentationViewController = objc_getClass("SiriPresentationViewController"); { MSHookMessageEx(_logos_class$SpringboardHooks$SiriPresentationViewController, @selector(_presentSiriViewControllerWithPresentationOptions:requestOptions:), (IMP)&_logos_method$SpringboardHooks$SiriPresentationViewController$_presentSiriViewControllerWithPresentationOptions$requestOptions$, (IMP*)&_logos_orig$SpringboardHooks$SiriPresentationViewController$_presentSiriViewControllerWithPresentationOptions$requestOptions$);}{ MSHookMessageEx(_logos_class$SpringboardHooks$SiriPresentationViewController, @selector(dismiss), (IMP)&_logos_method$SpringboardHooks$SiriPresentationViewController$dismiss, (IMP*)&_logos_orig$SpringboardHooks$SiriPresentationViewController$dismiss);}Class _logos_class$SpringboardHooks$VSSpeechRequest = objc_getClass("VSSpeechRequest"); { MSHookMessageEx(_logos_class$SpringboardHooks$VSSpeechRequest, @selector(setText:), (IMP)&_logos_method$SpringboardHooks$VSSpeechRequest$setText$, (IMP*)&_logos_orig$SpringboardHooks$VSSpeechRequest$setText$);}Class _logos_class$SpringboardHooks$SBVolumeHardwareButtonActions = objc_getClass("SBVolumeHardwareButtonActions"); { MSHookMessageEx(_logos_class$SpringboardHooks$SBVolumeHardwareButtonActions, @selector(volumeIncreasePressDown), (IMP)&_logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressDown, (IMP*)&_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressDown);}{ MSHookMessageEx(_logos_class$SpringboardHooks$SBVolumeHardwareButtonActions, @selector(volumeDecreasePressDown), (IMP)&_logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressDown, (IMP*)&_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressDown);}{ MSHookMessageEx(_logos_class$SpringboardHooks$SBVolumeHardwareButtonActions, @selector(volumeIncreasePressUp), (IMP)&_logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressUp, (IMP*)&_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeIncreasePressUp);}{ MSHookMessageEx(_logos_class$SpringboardHooks$SBVolumeHardwareButtonActions, @selector(volumeDecreasePressUp), (IMP)&_logos_method$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressUp, (IMP*)&_logos_orig$SpringboardHooks$SBVolumeHardwareButtonActions$volumeDecreasePressUp);}}
	}
	if ([bundleID isEqualToString:@"com.apple.siri"]) {
		

		{Class _logos_class$SiriHooks$SRServerUtteranceView = objc_getClass("SRServerUtteranceView"); { MSHookMessageEx(_logos_class$SiriHooks$SRServerUtteranceView, @selector(setText:), (IMP)&_logos_method$SiriHooks$SRServerUtteranceView$setText$, (IMP*)&_logos_orig$SiriHooks$SRServerUtteranceView$setText$);}}
	}
}
