//
//  Allo.m
//

#import "Allo.h"

@implementation Allo

+ (void) i : (NSString*) format, ...
{
    @try
    {
        if (CUBE_DEBUG) {
            va_list args;
            va_start (args, format);
            NSString* message = [[NSString alloc] initWithFormat: format arguments: args];
            va_end (args);
            NSLog (@"%@ : %@", CUBE, message);
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

+ (void) t : (NSString*) format, ...
{
    @try
    {
        if (CUBE_DEBUG) {
            va_list args;
            va_start (args, format);
            NSString* message = [[NSString alloc] initWithFormat: format arguments: args];
            va_end (args);
            // 'keyWindow' is deprecated: first deprecated in iOS 13.0 - Should not be used for applications that support multiple scenes as it returns a key window across all connected scenes
            // ViewController* controller = (ViewController*) [UIApplication sharedApplication].keyWindow.rootViewController;
            UIWindow* keyWindow = [[[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock: ^BOOL(UIWindow *window, NSDictionary* bindings) {
                return window.isKeyWindow;
            }]] firstObject];
            ViewController* controller = (ViewController*) keyWindow.rootViewController;
            [controller.view makeToast: message];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

@end
