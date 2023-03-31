//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>
#import "Allo.h"

@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate, FIRMessagingDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow * window;

@end

