//
//  ViewController.h
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "Allo.h"
#import "UIView+Toast.h"
#import "NSString+Addtions.h"

@interface ViewController : UIViewController <WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) WKWebView* web;
@property (nonatomic, retain) UIRefreshControl* refreshControl;
@property (nonatomic, retain) UIActivityIndicatorView* indicator;

- (void) rotateFirebase;
- (void) registDevice : (NSString*) token;
- (void) rotateNotification : (NSDictionary*) info;
- (void) rotateToken : (NSNotification *) notification;

- (void) loadSite;
- (void) loadLink;
- (void) openLink;
- (void) actionPrev;
- (void) actionNext;
- (void) actionRefresh;
- (void) actionRefreshDelay;
- (void) showIndicator;
- (void) hideIndicator;
- (void) handleSwipeGesture: (UISwipeGestureRecognizer*) sender;

@end

