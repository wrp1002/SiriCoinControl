#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <MRYIPCCenter.h>

#define kIdentifier @"com.wrp1002.siricoincontrol"
#define LogTweakName @"SiriCoinControl"


//	=========================== Preference vars ===========================

bool enabled;
bool customPhraseEnabled;
NSString *headsPhrase;
NSString *tailsPhrase;
NSString *customPhrase;

//	=========================== Other vars ===========================

int startupDelay = 5;
HBPreferences *preferences;
static MRYIPCCenter* center;

int coinChoice = -1;
bool siriVisible = false;
typedef NS_ENUM(NSUInteger, CoinChoices) {
	RANDOM,
    HEADS,
	TAILS,
	CUSTOM
};

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


@interface SiriCoinControlServer : NSObject {
	MRYIPCCenter* center;
}
	-(id)init;
	-(NSNumber*)getCoinChoice:(NSDictionary*)args;
	-(NSNumber*)getSiriVisible:(NSDictionary*)args;
@end

@implementation SiriCoinControlServer
	-(id)init {
		Log(@"SiriCoinControlServer init()");
		self = [super init];

		center = [MRYIPCCenter centerNamed:@"com.wrp1002.SiriCoinControlServer"];
		[center addTarget:self action:@selector(getCoinChoice:)];
		[center addTarget:self action:@selector(getSiriVisible:)];
		
		return self;
	}
	-(NSNumber*)getCoinChoice:(NSDictionary*)args {
		return @(coinChoice);
	}
	-(NSNumber*)getSiriVisible:(NSDictionary*)args {
		return @((int)siriVisible);
	}

@end

static SiriCoinControlServer *server;

NSString *ReplaceHeadsAndTails(NSString *text) {
	NSString *oldText = text;

	if (coinChoice == RANDOM)
		return text;

	NSString *searchFor;
	NSString *replaceWith;

	if (coinChoice == HEADS) {
		searchFor = [tailsPhrase lowercaseString];
		replaceWith = [headsPhrase lowercaseString];
	}
	else if (coinChoice == TAILS) {
		searchFor = [headsPhrase lowercaseString];
		replaceWith = [tailsPhrase lowercaseString];
	}
	else if (coinChoice == CUSTOM) {
		if (customPhraseEnabled)
			return customPhrase;
		else
			return text;
	}

	text = [text stringByReplacingOccurrencesOfString:searchFor withString:replaceWith];
	text = [text stringByReplacingOccurrencesOfString:[searchFor capitalizedString] withString:[replaceWith capitalizedString]];

	Log([NSString stringWithFormat:@"Old: %@   New: %@", oldText, text]);

	return text;
}

//	=========================== Hooks ===========================

%group SpringboardHooks

	%hook SpringBoard

		//	Called when springboard is finished launching
		-(void)applicationDidFinishLaunching:(id)application {
			%orig;
			springboardReady = true;
		}

	%end

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

			NSString *newText = ReplaceHeadsAndTails(arg1);

			%orig(newText);
		}
	%end

	//	Functions used to detect volume buttons
	%hook SBVolumeHardwareButtonActions
		-(void)volumeIncreasePressDown {
			Log(@"volumeIncreasePressDown");

			if (!enabled || !siriVisible)
				%orig;

			if (coinChoice == RANDOM)
				coinChoice = HEADS;
			else
				coinChoice = CUSTOM;
		}
		-(void)volumeDecreasePressDown {
			Log(@"volumeDecreasePressDown");

			if (!enabled || !siriVisible)
				%orig;

			if (coinChoice == RANDOM) 
				coinChoice = TAILS;
			else 
				coinChoice = CUSTOM;
		}

		-(void)volumeIncreasePressUp {
			Log(@"volumeIncreasePressUp");
			%orig;

			if (coinChoice == HEADS)
				coinChoice = RANDOM;
			else
				coinChoice = TAILS;
		}
		-(void)volumeDecreasePressUp {
			Log(@"volumeDecreasePressUp");
			%orig;

			if (coinChoice == TAILS)
				coinChoice = RANDOM;
			else
				coinChoice = HEADS;
		}
	%end

%end	//SpringboardHooks



%group SiriHooks

	//	I couldn't find a way within SpringBoard to change the text output of Siri, so hook into this Siri function to do so
	%hook SRServerUtteranceView
		-(void)setText:(id)arg1 {
			Log(@"SRServerUtteranceView -(void)setText:(NSString *)arg1");
			
			//	Since this hook isn't within SpringBoard, ask the server in Springboard for the variable
			siriVisible = [[center callExternalMethod:@selector(getSiriVisible:) withArguments:@{}] intValue];

			if (!siriVisible || !enabled) {
				%orig(arg1);
			}
			else {
				//	Since this hook isn't within SpringBoard, ask the server in Springboard for the variable
				coinChoice = [[center callExternalMethod:@selector(getCoinChoice:) withArguments:@{}] intValue];

				NSString *newText = ReplaceHeadsAndTails(arg1);
				%orig(newText);
			}
		}
	%end

%end	//SiriHooks


//	=========================== Constructor stuff ===========================

%ctor {
	Log([NSString stringWithFormat:@"============== %@ started ==============", LogTweakName]);

	preferences = [[HBPreferences alloc] initWithIdentifier:kIdentifier];

	[preferences registerBool:&enabled default:true forKey:@"kEnabled"];
	[preferences registerBool:&customPhraseEnabled default:false forKey:@"kCustomPhraseEnabled"];

	[preferences registerObject:&headsPhrase default:@"Heads" forKey:@"kHeadsPhrase"];
	[preferences registerObject:&tailsPhrase default:@"Tails" forKey:@"kTailsPhrase"];
	
	[preferences registerObject:&customPhrase default:@"Oops, it rolled under the bed" forKey:@"kCustomPhrase"];

	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {
		server = [[SiriCoinControlServer alloc] init];

		/*@try {
			center = [MRYIPCCenter centerNamed:@"com.wrp1002.SiriCoinControlServer"];
			[center addTarget:^NSNumber*(NSDictionary* args){
				NSInteger value1 = [args[@"value1"] integerValue];
				NSInteger value2 = [args[@"value2"] integerValue];
				return @(value1 + value2);
			} 
			forSelector:@selector(addNumbers:)];
		}
		@catch (NSException *e) {
			LogException(e);
		}*/

		%init(SpringboardHooks);
	}
	if ([bundleID isEqualToString:@"com.apple.siri"]) {
		center = [MRYIPCCenter centerNamed:@"com.wrp1002.SiriCoinControlServer"];

		%init(SiriHooks);
	}
}
