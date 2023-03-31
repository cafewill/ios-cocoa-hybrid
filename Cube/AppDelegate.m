//
//  AppDelegate.m
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL) application : (UIApplication *) application didFinishLaunchingWithOptions : (NSDictionary *) launchOptions {
    [Allo i : @"application / didFinishLaunchingWithOptions %@", [[self class] description]];
    
    @try
    {
        [FIRApp configure];
        [FIRMessaging messaging].delegate = self;
        if ([UNUserNotificationCenter class] != nil) {
          // iOS 10 or later
          // For iOS 10 display notification (sent via APNS)
          [UNUserNotificationCenter currentNotificationCenter].delegate = self;
          UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
              UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
          [[UNUserNotificationCenter currentNotificationCenter]
              requestAuthorizationWithOptions:authOptions
              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                // ...
              }];
        } else {
          // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
          UIUserNotificationType allNotificationTypes =
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
          UIUserNotificationSettings *settings =
          [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
          [application registerUserNotificationSettings:settings];
        }
        [application registerForRemoteNotifications];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *) application : (UIApplication *) application configurationForConnectingSceneSession: (UISceneSession *) connectingSceneSession options: (UISceneConnectionOptions *) options {
    [Allo i : @"application / configurationForConnectingSceneSession / options %@", [[self class] description]];

    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void) application : (UIApplication *) application didDiscardSceneSessions: (NSSet<UISceneSession *> *) sceneSessions {
    [Allo i : @"application / didDiscardSceneSessions %@", [[self class] description]];
}

#pragma mark - Firebase

// [START receive_message]
- (void) application : (UIApplication *) application didReceiveRemoteNotification: (NSDictionary *) userInfo
{
    [Allo i : @"application / didReceiveRemoteNotification %@", [[self class] description]];
}

- (void) application : (UIApplication *) application didReceiveRemoteNotification: (NSDictionary *) userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [Allo i : @"application / didReceiveRemoteNotification / fetchCompletionHandler [%@] %@", userInfo, [[self class] description]];

    completionHandler (UIBackgroundFetchResultNewData);
}
// [END receive_message]

- (void) application : (UIApplication *) application didFailToRegisterForRemoteNotificationsWithError: (NSError *) error {
    [Allo i : @"application / didFailToRegisterForRemoteNotificationsWithError [%@] %@", [error localizedDescription], [[self class] description]];
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void) application : (UIApplication *) application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *) deviceToken {
    NSString * token = [[NSString alloc] initWithData : deviceToken encoding : NSUTF8StringEncoding];
    [Allo i : @"application / didRegisterForRemoteNotificationsWithDeviceToken [%@] %@", token, [[self class] description]];
}

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void) userNotificationCenter: (UNUserNotificationCenter *) center
       willPresentNotification: (UNNotification *) notification
         withCompletionHandler: (void (^)(UNNotificationPresentationOptions)) completionHandler {
  [Allo i : @"userNotificationCenter / willPresentNotification / withCompletionHandler %@", [[self class] description]];

    @try
    {
        NSDictionary* userInfo = notification.request.content.userInfo;

        NSDictionary* aps = [userInfo objectForKey: @"aps"];
        NSDictionary* alert = [aps objectForKey: @"alert"];
        NSString* title = [alert objectForKey: @"title"];
        NSString* message = [alert objectForKey: @"body"];
        NSString* link = [userInfo objectForKey: @"link"];

        [Allo i : @"Check notification => [%@][%@][%@]", title, message, link];

        // 'keyWindow' is deprecated: first deprecated in iOS 13.0 - Should not be used for applications that support multiple scenes as it returns a key window across all connected scenes
        // ViewController* controller = (ViewController*) [UIApplication sharedApplication].keyWindow.rootViewController;
        UIWindow* keyWindow = [[[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock: ^BOOL(UIWindow *window, NSDictionary* bindings) {
            return window.isKeyWindow;
        }]] firstObject];
        ViewController* controller = (ViewController*) keyWindow.rootViewController;

        [controller.view makeToast: [NSString stringWithFormat: @"Check notification (willPresentNotification) => [%@][%@][%@]", title, message, link]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
    
  // Change this to your preferred presentation option
  completionHandler (UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
}

// Handle notification messages after display notification is tapped by the user.
- (void) userNotificationCenter: (UNUserNotificationCenter *) center
didReceiveNotificationResponse: (UNNotificationResponse *) response
         withCompletionHandler: (void(^)(void)) completionHandler  API_AVAILABLE(ios(10.0)) {
    [Allo i : @"userNotificationCenter / didReceiveNotificationResponse / withCompletionHandler %@", [[self class] description]];

    @try
    {
        // 알림 수신 / 터치시 엑션 적용요
        // ios 의 경우 수신된 푸시 알림을 메인 뷰 컨트롤러로 넘겨서 처리함 (android 와 다르게 심플함)
        NSDictionary* userInfo = response.notification.request.content.userInfo;
        
        // 'keyWindow' is deprecated: first deprecated in iOS 13.0 - Should not be used for applications that support multiple scenes as it returns a key window across all connected scenes
        // ViewController* controller = (ViewController*) [UIApplication sharedApplication].keyWindow.rootViewController;
        UIWindow* keyWindow = [[[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock: ^BOOL(UIWindow *window, NSDictionary* bindings) {
            return window.isKeyWindow;
        }]] firstObject];
        ViewController* controller = (ViewController*) keyWindow.rootViewController;

        [controller rotateNotification: userInfo];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }

    completionHandler ();
}

// [END ios_10_message_handling]

// [START refresh_token]
- (void) messaging: (FIRMessaging *) messaging didReceiveRegistrationToken: (NSString *) fcmToken {
    [Allo i : @"messaging / didReceiveRegistrationToken %@", [[self class] description]];

    @try
    {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject: fcmToken forKey: @"token"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"FCMToken" object: nil userInfo: userInfo];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}
// [END refresh_token]

@end
