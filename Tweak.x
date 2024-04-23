#import <Foundation/Foundation.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "Tweak.h"

#define TWEAK_NAME @"SiriCoinControl"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]
#define BUNDLE_NOTIFY (CFStringRef)[NSString stringWithFormat:@"%@/ReloadPrefs", BUNDLE]

#define COIN_CHOICE_REQUEST @"com.wrp1002.SiriCoinControlServer.CoinChoice"
#define COIN_CHOICE_RESPONSE @"com.wrp1002.SiriCoinControlServer.CoinChoiceResponse"
#define PREFS_REQUEST @"com.wrp1002.SiriCoinControlServer.PrefsRequest"
#define PREFS_RESPONSE @"com.wrp1002.SiriCoinControlServer.PrefsResponse"



//	=========================== Preference vars ===========================

bool enabled;
bool customPhraseEnabled;
NSString *headsPhrase;
NSString *tailsPhrase;
NSString *customPhrase;

NSUserDefaults *prefs = nil;

extern void NotifyPreferences();

void InitPrefs(void) {
	if (!prefs) {
		NSDictionary *defaultPrefs = @{
			@"kEnabled": @YES,
			@"kCustomPhraseEnabled": @NO,
			@"kHeadsPhrase": @"Heads",
			@"kTailsPhrase": @"Tails",
			@"kCustomPhrase": @"Oops, it rolled under the bed",
		};
		prefs = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE];
		[prefs registerDefaults:defaultPrefs];
	}
}

void SetPrefsFromDict(NSDictionary *prefsDict) {
	enabled = [[prefsDict valueForKey:@"kEnabled"] integerValue];
	customPhraseEnabled = [[prefsDict valueForKey:@"kCustomPhraseEnabled"] integerValue];
	headsPhrase = [prefsDict valueForKey:@"kHeadsPhrase"];
	tailsPhrase = [prefsDict valueForKey:@"kTailsPhrase"];
	customPhrase = [prefsDict valueForKey:@"kCustomPhrase"];
	//[Debug Log:[NSString stringWithFormat:@"loaded prefs from dict: %i %i %@ %@ %@", enabled, customPhraseEnabled, headsPhrase, tailsPhrase, customPhrase]];
}

void UpdatePrefs() {
	//[Debug Log:@"prefs changed!"];
	enabled = [prefs boolForKey:@"kEnabled"];
	customPhraseEnabled = [prefs boolForKey:@"kCustomPhraseEnabled"];

	headsPhrase = [prefs stringForKey:@"kHeadsPhrase"];
	tailsPhrase = [prefs stringForKey:@"kTailsPhrase"];
	customPhrase = [prefs stringForKey:@"kCustomPhrase"];

	//[Debug Log:[NSString stringWithFormat:@"customPhraseEnabled: %i  %@", customPhraseEnabled, customPhrase]];
}

void PrefsChangeCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	//[Debug Log:[NSString stringWithFormat:@"prefs changed callback from bundle: %@", bundleID]];

	UpdatePrefs();
	NotifyPreferences();
}


//	=========================== Other vars ===========================

typedef NS_ENUM(NSUInteger, CoinChoices) { RANDOM, HEADS, TAILS, CUSTOM };
bool siriVisible = false;
int coinChoice = RANDOM;


//	=========================== Classes / Functions ===========================


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

	//[Debug Log:[NSString stringWithFormat:@"(ReplaceHeadsAndTails)  Old: %@   New: %@", oldText, text]];
	return text;
}


void NotifyCoinChoice() {
	if (!siriVisible)
		return;

	//[Debug Log:[NSString stringWithFormat:@"sending coin notifiction for %i", coinChoice]];
	NSDictionary *responseData = @{@"coinChoice": @(coinChoice)};
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:COIN_CHOICE_RESPONSE object:nil userInfo:responseData];
}


void NotifyPreferences() {
	if (!siriVisible)
		return;

	//[Debug Log:@"sending prefs notification from SpringBoard"];
	NSDictionary *prefsDict = @{
		@"kEnabled": @(enabled),
		@"kCustomPhraseEnabled": @(customPhraseEnabled),
		@"kHeadsPhrase": headsPhrase,
		@"kTailsPhrase": tailsPhrase,
		@"kCustomPhrase": customPhrase,
	};
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:PREFS_RESPONSE object:nil userInfo:prefsDict];
}


//	=========================== Hooks ===========================

%group SpringboardHooks
	//	Check when Siri is opened and closed
	%hook SiriPresentationViewController
		- (void)_presentSiriViewControllerWithPresentationOptions:(id)arg1 requestOptions:(id)arg2 {
			%orig;
			//[Debug Log:@"- (void)_presentSiriViewControllerWithPresentationOptions:(id)arg1 requestOptions:(id)arg2;"];
			siriVisible = true;

			// Send notifications to Siri process once it becomes active
			NotifyCoinChoice();
			NotifyPreferences();
		}
		- (void)dismiss {
			//[Debug Log:@"- (void)dismiss;"];
			siriVisible = false;
			%orig;
		}
		- (void)dismissSiriSetupViewController:(id)arg1 {
			//[Debug Log:@"- (void)dismissSiriSetupViewController:(id)arg1"];
			siriVisible = false;
			%orig;
		}
		- (void)dismissSiriViewController:(id)arg1 withReason:(unsigned long long)arg2 {
			//[Debug Log:@"- (void)dismissSiriViewController:(id)arg1 withReason:(unsigned long long)arg2"];
			siriVisible = false;
			%orig;
		}
		- (void)dismissWithOptions:(id)arg1 {
			//[Debug Log:@"- (void)dismissWithOptions:(id)arg1"];
			siriVisible = false;
			%orig;
		}

	%end

	//	Functions used to detect volume buttons
	%hook SBVolumeHardwareButtonActions
		%new
		-(void)handleSCCVolumeIncreasePressDown {
			if (coinChoice == RANDOM)
				coinChoice = HEADS;
			else
				coinChoice = CUSTOM;
			NotifyCoinChoice();
		}
		%new
		-(void)handleSCCVolumeDecreasePressDown {
			if (coinChoice == RANDOM)
				coinChoice = TAILS;
			else
				coinChoice = CUSTOM;
			NotifyCoinChoice();
		}

		-(void)volumeIncreasePressDown {
			//[Debug Log:@"volumeIncreasePressDown"];

			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeIncreasePressDown];
		}
		-(void)volumeIncreasePressDownWithModifiers:(long long)arg1 {
			//[Debug Log:@"volumeIncreasePressDown"];

			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeIncreasePressDown];
		}

		-(void)volumeDecreasePressDown {
			//[Debug Log:@"volumeDecreasePressDown"];
			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeDecreasePressDown];
		}
		-(void)volumeDecreasePressDownWithModifiers:(long long)arg1 {
			//[Debug Log:@"volumeDecreasePressDown"];
			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeDecreasePressDown];
		}

		-(void)volumeIncreasePressUp {
			//[Debug Log:@"volumeIncreasePressUp"];
			%orig;

			if (coinChoice == HEADS)
				coinChoice = RANDOM;
			else
				coinChoice = TAILS;

			NotifyCoinChoice();
		}
		-(void)volumeDecreasePressUp {
			//[Debug Log:@"volumeDecreasePressUp"];
			%orig;

			if (coinChoice == TAILS)
				coinChoice = RANDOM;
			else
				coinChoice = HEADS;

			NotifyCoinChoice();
		}
	%end

%end	//SpringboardHooks


%group SiriHooks
	%hook SiriSharedUICompactServerUtteranceView
		- (void)_setTextForLabel:(id)arg1 text:(id)arg2 {
			//[Debug Log:[NSString stringWithFormat:@"- (void)_setTextForLabel  %@", arg2]];

			if (!enabled) {
				%orig;
				return;
			}

			//[Debug Log:[NSString stringWithFormat:@"doing replacement.  original text: %@", arg1]];
			NSString *newText = ReplaceHeadsAndTails(arg2);
			//[Debug Log:[NSString stringWithFormat:@"setting text to %@", newText]];
			return %orig(arg1, newText);
		}
	%end

	%hook SiriTTSSpeechRequest
		- (id)initWithText:(id)arg1 voice:(id)arg2 {
			//[Debug Log:[NSString stringWithFormat:@"- (id)initWithText  arg1: %@", arg1]];

			if (!enabled) {
				//[Debug Log:@"orig"];
				return %orig;
			}

			//[Debug Log:[NSString stringWithFormat:@"doing replacement.  original text: %@", arg1]];
			NSString *newText = ReplaceHeadsAndTails(arg1);
			//[Debug Log:[NSString stringWithFormat:@"setting text to %@", newText]];
			return %orig(newText, arg2);
		}
	%end

%end	//SiriHooks


//	=========================== Constructor stuff ===========================

%ctor {
	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	//[Debug Log:[NSString stringWithFormat:@"============== started from %@ ==============", bundleID]];

	if ([bundleID isEqualToString:@"com.apple.springboard"]) {
		//[Debug Log:@"init springboard hooks"];
		// Setup preferences
		InitPrefs();
		UpdatePrefs();

		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			&PrefsChangeCallback,
			BUNDLE_NOTIFY,
			NULL,
			0
		);

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:COIN_CHOICE_REQUEST object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			//[Debug Log:[NSString stringWithFormat:@"got coin requyet notification!!  userInfo: %@", [notification.userInfo objectForKey:@"test"]]];
			NSDictionary *responseData = @{@"coinChoice": @(coinChoice)};
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:COIN_CHOICE_RESPONSE object:nil userInfo:responseData];

		}];

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:PREFS_REQUEST object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			//[Debug Log:@"got prefs request notification!!"];
			NotifyPreferences();
		}];

		%init(SpringboardHooks);
	}
	if ([bundleID isEqualToString:@"com.apple.siri"]) {
		//[Debug Log:@"init siri hooks"];

		// Request preferences from SpringBoard since they can't be loaded in Siri for some reason
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:PREFS_REQUEST object:nil userInfo:nil];
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:COIN_CHOICE_REQUEST object:nil userInfo:nil];

		// coinChoice receiver
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:COIN_CHOICE_RESPONSE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			//[Debug Log:[NSString stringWithFormat:@"siri COIN_CHOICE_RESPONSE!!  userInfo: %li", [[notification.userInfo objectForKey:@"coinChoice"] integerValue]]];
			coinChoice = [[notification.userInfo objectForKey:@"coinChoice"] integerValue];
		}];

		// preferences receiver
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:PREFS_RESPONSE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			//[Debug Log:@"siri PREFS_RESPONSE!!"];
			SetPrefsFromDict(notification.userInfo);
		}];

		%init(SiriHooks);
	}
}
