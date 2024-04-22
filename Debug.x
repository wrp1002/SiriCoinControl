#import "Debug.h"

//int __isOSVersionAtLeast(int major, int minor, int patch) { NSOperatingSystemVersion version; version.majorVersion = major; version.minorVersion = minor; version.patchVersion = patch; return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]; }

@implementation Debug
	static bool springboardReady = false;

	+(UIWindow*) GetKeyWindow {
		if (@available(iOS 13, *)) {
			NSSet *connectedScenes = [UIApplication sharedApplication].connectedScenes;
			for (UIScene *scene in connectedScenes) {
				if ([scene isKindOfClass:[UIWindowScene class]]) {
					UIWindowScene *windowScene = (UIWindowScene *)scene;
					for (UIWindow *window in windowScene.windows) {
						if (window.isKeyWindow) {
							return window;
						}
					}
				}
			}
		} else {
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
			NSArray		 *windows = [[UIApplication sharedApplication] windows];
	#pragma clang diagnostic pop
			for (UIWindow   *window in windows) {
				if (window.isKeyWindow) {
					return window;
				}
			}
		}
		return nil;
	}

	//	Shows an alert box. Used for debugging
	+(void)ShowAlert:(NSString *)msg {
		if (!springboardReady) return;

		UIAlertController * alert = [UIAlertController
									alertControllerWithTitle:@"Alert"
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

		[[self GetKeyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
	}

	//	Show log with tweak name as prefix for easy grep
	+(void)Log:(NSString *)msg {
		NSLog(@"%@: %@", TWEAK_NAME, msg);
	}

	//	Log exception info
	+(void)LogException:(NSException *)e {
		NSLog(@"%@: NSException caught", TWEAK_NAME);
		NSLog(@"%@: Name:%@", TWEAK_NAME, e.name);
		NSLog(@"%@: Reason:%@", TWEAK_NAME, e.reason);
	}

	+(void)SpringBoardReady {
		springboardReady = true;
	}
@end