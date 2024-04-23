#include "SCCRootListController.h"

@implementation SCCRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	NSArray *subviews = [self.view subviews];
    for (UIView *subview in subviews) {
		if ([subview class] == [UITableView class]) {
			UITableView *tableView = (UITableView *)subview;
			tableView.keyboardDismissMode =  UIScrollViewKeyboardDismissModeOnDrag;
		}
    }

	return _specifiers;
}

-(void)Respring {
    // From Cephei since other methods I tried didn't work
	[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FrontBoardServices.framework"] load];
	[[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardServices.framework"] load];

	Class $FBSSystemService = NSClassFromString(@"FBSSystemService");
	Class $SBSRelaunchAction = NSClassFromString(@"SBSRelaunchAction");
	if ($FBSSystemService && $SBSRelaunchAction) {
		SBSRelaunchAction *restartAction = [$SBSRelaunchAction actionWithReason:@"RestartRenderServer" options:SBSRelaunchActionOptionsFadeToBlackTransition targetURL:nil];
		[[$FBSSystemService sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
	}
}

-(void)OpenGithub {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://github.com/wrp1002/SiriCoinControl"];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void)OpenPaypal {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://paypal.me/wrp1002"];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void)OpenReddit {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"https://reddit.com/u/wes_hamster"];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void)OpenEmail {
	UIApplication *application = [UIApplication sharedApplication];
	NSURL *URL = [NSURL URLWithString:@"mailto:wes.hamster@gmail.com?subject=SiriCoinControl16"];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void)Reset {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE];
	NSArray *allKeys = [prefs dictionaryRepresentation].allKeys;

	for (NSString *key in allKeys) {
		[prefs removeObjectForKey:key];
	}
	[prefs synchronize];

	[self reloadSpecifiers];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), BUNDLE_NOTIFY, nil, nil, true);
}

-(void)DismissKeybaord {
	[self.view endEditing:YES];
}

@end
