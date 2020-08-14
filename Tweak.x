#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>

#define kIdentifier @"com.wrp1002.siricoincontrol"
#define kSettingsChangedNotification (CFStringRef)@"com.wrp1002.siricoincontrol/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.wrp1002.siricoincontrol.plist"
#define LogTweakName @"SiriCoinControl"


//	=========================== Preference vars ===========================

BOOL enabled = true;

//	=========================== Other vars ===========================

int startupDelay = 5;
HBPreferences *preferences;

int coinChoice = -1;
bool siriVisible = false;

//	=========================== Debugging stuff ===========================

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

//	Shows an alert box. Used for debugging 
void ShowAlert(NSString *msg, NSString *title) {
	if (!springboardReady) return;

	UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];

    //Add Buttons
    UIAlertAction* dismissButton = [UIAlertAction
                                actionWithTitle:@"Cool!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle dismiss button action here
									
                                }];

    //Add your buttons to alert controller
    [alert addAction:dismissButton];

    [GetKeyWindow().rootViewController presentViewController:alert animated:YES completion:nil];
}

//	Show log with tweak name as prefix for easy grep
void Log(NSString *msg) {
	NSLog(@"%@: %@", LogTweakName, msg);
}

//	Log exception info
void LogException(NSException *e) {
	NSLog(@"%@: NSException caught", LogTweakName);
	NSLog(@"%@: Name:%@", LogTweakName, e.name);
	NSLog(@"%@: Reason:%@", LogTweakName, e.reason);
	//ShowAlert(@"TVLock Crash Avoided!", @"Alert");
}


//	=========================== Classes / Functions ===========================


inline void Save() {
	Log(@"Saving to file");
	//[preferences setInteger:lives forKey:@"kLives"];
}


//	=========================== Hooks ===========================

%group SpringboardHooks

	//	Check when Siri is opened and closed
	%hook SiriPresentationViewController
		- (void)_presentSiriViewControllerWithPresentationOptions:(id)arg1 requestOptions:(id)arg2 {
			%orig;
			Log(@"- (void)_presentSiriViewControllerWithPresentationOptions:(id)arg1 requestOptions:(id)arg2;");
			siriVisible = true;
		}

		/*
		- (void)dismissWithOptions:(id)arg1 {
			%orig;
			Log(@"- (void)dismissWithOptions:(id)arg1;");
		}*/
		- (void)dismiss {
			%orig;
			Log(@"- (void)dismiss;");
			siriVisible = false;
		}

	%end

	//	Change speech output phrase of Siri
	%hook VSSpeechRequest
		-(void)setText:(NSString *)arg1 {

			if (!siriVisible || !enabled) {
				%orig(arg1);
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

			%orig(newText);
		}
	%end

	//	Functions used to detect volume buttons
	%hook SBVolumeHardwareButtonActions
		-(void)volumeIncreasePressDown {
			Log(@"volumeIncreasePressDown");

			if (siriVisible) {
				coinChoice = 1;
			}
			else
				%orig;
		}
		-(void)volumeDecreasePressDown {
			Log(@"volumeDecreasePressDown");

			if (siriVisible) {
				coinChoice = 0;
			}
			else
				%orig;
		}

		-(void)volumeIncreasePressUp {
			Log(@"volumeIncreasePressUp");

			coinChoice = -1;
			%orig;
		}
		-(void)volumeDecreasePressUp {
			Log(@"volumeDecreasePressUp");

			coinChoice = -1;
			%orig;
		}
	%end

%end	//SpringboardHooks



%group SiriHooks

	//	I couldn't find a way within SpringBoard to change the text output of Siri, so hook into this Siri function to do so
	%hook SRServerUtteranceView
		-(void)setText:(id)arg1 {
			Log(@"SRServerUtteranceView -(void)setText:(NSString *)arg1");
			
			if (!siriVisible || !enabled) {
				Log(@"No happen :(");
				Log([NSString stringWithFormat:@"SiriVisible: %d   Enabled: %d", siriVisible, enabled]);
				%orig(arg1);
			}
			else {
				Log(@"Happen! :)");

				NSString *newText = arg1;

				if (coinChoice == 0) {
					newText = [newText stringByReplacingOccurrencesOfString:@"Heads" withString:@"Tails!"];
					newText = [newText stringByReplacingOccurrencesOfString:@"heads" withString:@"tails"];
				}
				else if (coinChoice == 1) {
					newText = [newText stringByReplacingOccurrencesOfString:@"Tails" withString:@"Heads!"];
					newText = [newText stringByReplacingOccurrencesOfString:@"tails" withString:@"heads!"];
				}

				%orig(newText);
			}
		}
	%end


%end	//SiriHooks


//	=========================== Constructor stuff ===========================



%ctor {
	Log([NSString stringWithFormat:@"============== %@ started ==============", LogTweakName]);
	
	preferences = [[HBPreferences alloc] initWithIdentifier:kIdentifier];
	
	NSString const *bundleID = NSBundle.mainBundle.bundleIdentifier;
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {

		springboardReady = true;
		%init(SpringboardHooks);
		
	}
	else {
		

		%init(SiriHooks);
	}
}
