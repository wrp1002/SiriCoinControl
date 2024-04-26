#import "Tweak.h"

//	=========================== Preference vars ===========================

bool enabled;
bool customPhraseEnabled;
bool loggingEnabled;
NSString *headsPhrase;
NSString *tailsPhrase;
NSString *customPhrase;

NSUserDefaults *prefs = nil;


extern void NotifyPreferences();

void UpdatePrefs() {
	[Debug Log:@"prefs changed!"];
	enabled = [prefs boolForKey:@"kEnabled"];
	loggingEnabled = [prefs boolForKey:@"kLoggingEnabled"];
	customPhraseEnabled = [prefs boolForKey:@"kCustomPhraseEnabled"];

	headsPhrase = [prefs stringForKey:@"kHeadsPhrase"];
	tailsPhrase = [prefs stringForKey:@"kTailsPhrase"];
	customPhrase = [prefs stringForKey:@"kCustomPhrase"];

	[Debug Log:[NSString stringWithFormat:@"loaded prefs: %i, %i, %@, %@, %@", enabled, customPhraseEnabled, headsPhrase, tailsPhrase, customPhrase]];
}

void PrefsChangeCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
	[Debug Log:[NSString stringWithFormat:@"prefs changed callback called"]];
	UpdatePrefs();
	NotifyPreferences();
}

void InitPrefs(void) {
	if (!prefs) {
		NSDictionary *defaultPrefs = @{
			@"kEnabled": @YES,
			@"kLoggingnabled": @NO,
			@"kCustomPhraseEnabled": @NO,
			@"kHeadsPhrase": @"Heads",
			@"kTailsPhrase": @"Tails",
			@"kCustomPhrase": @"Oops, it rolled under the bed",
		};
		prefs = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE];
		[prefs registerDefaults:defaultPrefs];

		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			&PrefsChangeCallback,
			BUNDLE_NOTIFY,
			NULL,
			0
		);
	}
}

void SetPrefsFromDict(NSDictionary *prefsDict) {
	enabled = [[prefsDict valueForKey:@"kEnabled"] integerValue];
	loggingEnabled = [[prefsDict valueForKey:@"kLoggingEnabled"] integerValue];
	customPhraseEnabled = [[prefsDict valueForKey:@"kCustomPhraseEnabled"] integerValue];
	headsPhrase = [prefsDict valueForKey:@"kHeadsPhrase"];
	tailsPhrase = [prefsDict valueForKey:@"kTailsPhrase"];
	customPhrase = [prefsDict valueForKey:@"kCustomPhrase"];
	[Debug Log:[NSString stringWithFormat:@"loaded prefs from dict: %i, %i, %@, %@, %@", enabled, customPhraseEnabled, headsPhrase, tailsPhrase, customPhrase]];
}



//	=========================== Other vars ===========================

typedef NS_ENUM(NSUInteger, CoinChoices) { RANDOM, HEADS, TAILS, CUSTOM };
bool siriVisible = false;
int coinChoice = RANDOM;
NSString *bundleID;


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

	[Debug Log:[NSString stringWithFormat:@"ReplaceHeadsAndTails made replacement!   Old: %@   New: %@", oldText, text]];
	return text;
}


void NotifyCoinChoice() {
	if (!siriVisible)
		return;

	[Debug Log:[NSString stringWithFormat:@"sending coin notifiction for %i", coinChoice]];
	NSDictionary *responseData = @{@"coinChoice": @(coinChoice)};
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:COIN_CHOICE_RESPONSE object:nil userInfo:responseData];
}


void NotifyPreferences() {
	if (!siriVisible)
		return;

	[Debug Log:@"sending prefs notification"];
	NSDictionary *prefsDict = @{
		@"kEnabled": @(enabled),
		@"kLoggingEnabled": @(loggingEnabled),
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
			[Debug Log:@"- (void)_presentSiriViewControllerWithPresentationOptions:(id)arg1 requestOptions:(id)arg2;"];
			siriVisible = true;

			// Send notifications to Siri process once it becomes active
			NotifyCoinChoice();
			NotifyPreferences();
		}
		- (void)dismiss {
			[Debug Log:@"SiriPresentationViewController- (void)dismiss;"];
			siriVisible = false;
			%orig;
		}
		- (void)dismissSiriSetupViewController:(id)arg1 {
			[Debug Log:@"SiriPresentationViewController- (void)dismissSiriSetupViewController:(id)arg1"];
			siriVisible = false;
			%orig;
		}
		- (void)dismissSiriViewController:(id)arg1 withReason:(unsigned long long)arg2 {
			[Debug Log:@"SiriPresentationViewController- (void)dismissSiriViewController:(id)arg1 withReason:(unsigned long long)arg2"];
			siriVisible = false;
			%orig;
		}
		- (void)dismissWithOptions:(id)arg1 {
			[Debug Log:@"SiriPresentationViewController- (void)dismissWithOptions:(id)arg1"];
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
			[Debug Log:@"volume increase pressed"];

			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeIncreasePressDown];
		}
		-(void)volumeIncreasePressDownWithModifiers:(long long)arg1 {
			[Debug Log:@"volume increase pressed"];

			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeIncreasePressDown];
		}
		-(void)volumeIncreasePressUp {
			[Debug Log:@"volume increase released"];
			%orig;

			if (coinChoice == HEADS)
				coinChoice = RANDOM;
			else
				coinChoice = TAILS;

			NotifyCoinChoice();
		}

		-(void)volumeDecreasePressDown {
			[Debug Log:@"volume decrease pressed"];
			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeDecreasePressDown];
		}
		-(void)volumeDecreasePressDownWithModifiers:(long long)arg1 {
			[Debug Log:@"volume decrease pressed"];
			if (!enabled || !siriVisible)
				%orig;
			else
				[self handleSCCVolumeDecreasePressDown];
		}

		-(void)volumeDecreasePressUp {
			[Debug Log:@"volume decrease released"];
			%orig;

			if (coinChoice == TAILS)
				coinChoice = RANDOM;
			else
				coinChoice = HEADS;

			NotifyCoinChoice();
		}
	%end

%end	// end SpringboardHooks


%group SiriHooks
	%hook SiriSharedUICompactServerUtteranceView
		- (void)_setTextForLabel:(id)arg1 text:(id)arg2 {
			if (!enabled) {
				%orig;
				return;
			}

			[Debug Log:[NSString stringWithFormat:@"- (void)_setTextForLabel  %@", arg2]];
			NSString *newText = ReplaceHeadsAndTails(arg2);
			[Debug Log:[NSString stringWithFormat:@"setting text to %@", newText]];
			return %orig(arg1, newText);
		}
	%end

	%hook SiriTTSSpeechRequest
		- (id)initWithText:(id)arg1 voice:(id)arg2 {
			if (!enabled)
				return %orig;

			[Debug Log:[NSString stringWithFormat:@"- (id)initWithText  arg1: %@", arg1]];
			NSString *newText = ReplaceHeadsAndTails(arg1);
			[Debug Log:[NSString stringWithFormat:@"setting text to %@", newText]];
			return %orig(newText, arg2);
		}
	%end

%end	//SiriHooks


//	=========================== Constructor stuff ===========================

%ctor {
	bundleID = NSBundle.mainBundle.bundleIdentifier;
	loggingEnabled = YES; // Enable logging at least until prefs are loaded

	[Debug Log:[NSString stringWithFormat:@"============== started from %@ ==============", bundleID]];

	if ([bundleID isEqualToString:@"com.apple.springboard"]) {
		[Debug Log:@"init springboard hooks"];
		// Setup preferences
		InitPrefs();
		UpdatePrefs();

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:COIN_CHOICE_REQUEST object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[Debug Log:@"got COIN_CHOICE_REQUEST notification!"];
			NSDictionary *responseData = @{@"coinChoice": @(coinChoice)};
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:COIN_CHOICE_RESPONSE object:nil userInfo:responseData];

		}];

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:PREFS_REQUEST object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[Debug Log:@"got PREFS_REQUEST notification!!"];
			NotifyPreferences();
		}];

		%init(SpringboardHooks);
	}
	else if ([bundleID isEqualToString:@"com.apple.siri"]) {
		[Debug Log:@"init siri hooks"];

		// Request preferences from SpringBoard since they can't be loaded in Siri for some reason
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:PREFS_REQUEST object:nil userInfo:nil];
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:COIN_CHOICE_REQUEST object:nil userInfo:nil];

		// coinChoice receiver
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:COIN_CHOICE_RESPONSE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[Debug Log:[NSString stringWithFormat:@"got COIN_CHOICE_RESPONSE  notification!! %li", [[notification.userInfo objectForKey:@"coinChoice"] integerValue]]];
			coinChoice = [[notification.userInfo objectForKey:@"coinChoice"] integerValue];
		}];

		// preferences receiver
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:PREFS_RESPONSE object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[Debug Log:@"got PREFS_RESPONSE notification!!"];
			SetPrefsFromDict(notification.userInfo);
		}];

		%init(SiriHooks);
	}

}
