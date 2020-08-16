#include "SCCRootListController.h"

@implementation SCCRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)Respring {
    pid_t pid;
	int status;
	const char* args[] = {"killall", "-9", "SpringBoard", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	waitpid(pid, &status, WEXITED);//wait untill the process completes (only if you need to do that)
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
	NSURL *URL = [NSURL URLWithString:@"mailto:wes.hamster@gmail.com?subject=SiriCoinControl"];
	[application openURL:URL options:@{} completionHandler:nil];
}

-(void)Reset {
	[[[HBPreferences alloc] initWithIdentifier: @"com.wrp1002.siricoincontrol"] removeAllObjects];

	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath: @"/var/mobile/Library/Preferences/com.wrp1002.siricoincontrol.plist" error: nil];

	[self Respring];
}

@end
