//
//  ViewController.m
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize web;
@synthesize refreshControl;
@synthesize indicator;

- (void) viewDidLoad {
    [super viewDidLoad];
    [Allo i : @"viewDidLoad %@", [[self class] description]];
    
    @try
    {
        [self.view setBackgroundColor: [UIColor redColor]];
        // [self.view setBackgroundColor: UIColorFromRGB (0xed1d24)];

        WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = true;
        configuration.mediaTypesRequiringUserActionForPlayback = true;
        [configuration.preferences setValue: @"TRUE" forKey: @"allowFileAccessFromFileURLs"];
        web = [[WKWebView alloc] initWithFrame: [self.view bounds] configuration: configuration];

        // web = [[WKWebView alloc] initWithFrame: [self.view bounds]];
        [web setAutoresizingMask: (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [web setHidden: NO];
        [web setUIDelegate: self];
        [web setNavigationDelegate: self];
        [web setBackgroundColor: [UIColor whiteColor]];
        [web setAutoresizesSubviews: YES];
        [web setMultipleTouchEnabled: YES];
        [web setUserInteractionEnabled: YES];
        [web setAllowsLinkPreview: NO]; // long press disabled (이미지 다운로드 방지용)
        [web setAutoresizingMask: (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [web.scrollView setDelegate: self];
        [web.scrollView setDecelerationRate: UIScrollViewDecelerationRateNormal];
        [self.view addSubview: web];
        
        web.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 11, *))
        {
            UILayoutGuide* guide = self.view.safeAreaLayoutGuide;
            [web.topAnchor constraintEqualToAnchor: guide.topAnchor].active = YES;
            [web.bottomAnchor constraintEqualToAnchor: guide.bottomAnchor].active = YES;
            [web.leadingAnchor constraintEqualToAnchor: guide.leadingAnchor].active = YES;
            [web.trailingAnchor constraintEqualToAnchor: guide.trailingAnchor].active = YES;
        }
        else
        {
            UILayoutGuide* margins = self.view.layoutMarginsGuide;
            [web.leadingAnchor constraintEqualToAnchor: margins.leadingAnchor].active = YES;
            [web.trailingAnchor constraintEqualToAnchor: margins.trailingAnchor].active = YES;
            [web.topAnchor constraintEqualToAnchor: self.topLayoutGuide.bottomAnchor].active = YES;
            [web.bottomAnchor constraintEqualToAnchor: self.bottomLayoutGuide.topAnchor].active = YES;
        }
        [self.view layoutIfNeeded];
        // [self.web layoutIfNeeded];
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl setTintColor: [UIColor whiteColor]];
        [self.refreshControl setBackgroundColor: UIColorFromRGB (0xed1d24)];
        [self.refreshControl addTarget: self action: @selector (actionRefreshDelay) forControlEvents: UIControlEventValueChanged];
        [web.scrollView addSubview: self.refreshControl];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        if (@available(iOS 13.0, *))
        {
            [indicator setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleLarge];
        }
        [indicator setHidden: YES];
        [indicator stopAnimating];
        [indicator setCenter: [self.view center]];
        // [indicator setColor: [UIColor blackColor]];
        [indicator setColor: UIColorFromRGB(0xed1d24)];
        [self.view addSubview: indicator];
        
        // 좌우로 스크롤해서 이전 다음 페이지 이동용 (iOS 은 Android 와 같은 back 버튼 기능이 없음)
        UISwipeGestureRecognizer* swipeGesture;
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector (handleSwipeGesture:)];
        swipeGesture.delegate = self;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [web addGestureRecognizer: swipeGesture];
        swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self action: @selector (handleSwipeGesture:)];
        swipeGesture.delegate = self;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [web addGestureRecognizer: swipeGesture];

        [self loadSite];
        [self rotateFirebase];
    } @catch (NSException* e) { [Allo i: @"error %@ %@", [e name], [e reason]]; }
}

- (void) rotateNotification : (NSDictionary*) info
{
    [Allo i : @"rotateNotification %@", [[self class] description]];

    @try
    {
        // 푸시 알림 기본 데이터
        NSDictionary* aps = [info objectForKey: @"aps"];
        NSDictionary* alert = [aps objectForKey: @"alert"];
        NSString* title = [alert objectForKey: @"title"];
        NSString* message = [alert objectForKey: @"body"];
        
        // 추가 데이터 (바로가기 링크)
        NSString* link = [info objectForKey: @"link"];

        [Allo i : @"Check notification [%@][%@][%@]", title, message, link];

        NSURL* check = [NSURL URLWithString: link];
        if (check && check.scheme && check.host)
        {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: link] options: @{} completionHandler: nil];
        }
    } @catch (NSException* e) { [Allo i: @"error %@ %@", [e name], [e reason]]; }
}

- (void) rotateFirebase
{
    [Allo i : @"rotateFirebase %@", [[self class] description]];

    @try
    {
        [[NSNotificationCenter defaultCenter] addObserver : self
                                              selector : @selector (rotateToken :)
                                              name : @"FCMToken"
                                              object : nil];
    } @catch (NSException* e) { [Allo i: @"error %@ %@", [e name], [e reason]]; }
}


- (void) rotateToken : (NSNotification *) notification {
    [Allo i : @"rotateToken %@", [[self class] description]];

    @try
    {
        [self registDevice: [notification userInfo][@"token"]];
    } @catch (NSException* e) { [Allo i: @"error %@ %@", [e name], [e reason]]; }
}

- (void) registDevice : (NSString*) token
{
    [Allo i : @"registDevice %@", [[self class] description]];

    @try
    {
        // 필요시 로컬 및 리모트 서버 연동하여 저장함
        [Allo i : @"Check token [%@]", token];
    } @catch (NSException* e) { [Allo i : @"error %@ %@", [e name], [e reason]]; }
}

- (void) loadSite
{
    [Allo i: @"loadSite %@", [[self class] description]];

    @try
    {
        [self loadLink: CUBE_SITE];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) loadLink: (NSString*) link
{
    [Allo i: @"loadLink %@", [[self class] description]];

    @try
    {
        [web loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: link]]];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) openLink: (NSString*) link
{
    [Allo i: @"openLink %@", [[self class] description]];

    @try
    {
        NSURL* check = [NSURL URLWithString: link];
        if (check && check.scheme && check.host)
        {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: link] options: @{} completionHandler: nil];
        }
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionPrev
{
    [Allo i: @"actionPrev %@", [[self class] description]];

    @try
    {
        if ([self.web canGoBack]) [self.web goBack];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionNext
{
    [Allo i: @"actionNext %@", [[self class] description]];

    @try
    {
        if ([self.web canGoForward]) [self.web goForward];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) actionRefresh
{
    [Allo i: @"actionRefresh %@", [[self class] description]];

    [web reload];
    [self.refreshControl endRefreshing];
}

- (void) actionRefreshDelay
{
    [Allo i: @"actionRefreshDelay %@", [[self class] description]];

    CGFloat delay = 0.50;
    [self performSelector: @selector (actionRefresh) withObject: nil afterDelay: delay];
}

- (void) showIndicator
{
    [Allo i: @"showIndicator %@", [[self class] description]];

    @try
    {
        [indicator setHidden: NO];
        [indicator startAnimating];
        
        // 인디케이터는 1200 후 자동으로 없어짐 (로드가 빨리된다면 그전에 onPageFinished 에서 처리됨)
        // 간혹 웹페이지에서 로드 불가한 (css, js 등) 리소스로 인해 계속 로딩중 상태가 지속되는걸 방지하기 위함
        CGFloat delay = 1.500;
        [self performSelector: @selector (hideIndicator) withObject: nil afterDelay: delay];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) hideIndicator
{
    [Allo i: @"hideIndicator %@", [[self class] description]];

    @try
    {
        [indicator setHidden: YES];
        [indicator stopAnimating];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) handleSwipeGesture: (UISwipeGestureRecognizer*) sender
{
    [Allo i: @"handleSwipeGesture %@", [[self class] description]];

    @try
    {
        if (UISwipeGestureRecognizerDirectionLeft == sender.direction) [self actionNext];
        if (UISwipeGestureRecognizerDirectionRight == sender.direction) [self actionPrev];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

#pragma mark - WKWebView UIDelegate

- (void) webView: (WKWebView *) webView runOpenPanelWithParameters: (WKOpenPanelParameters *) parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> *URLs))completionHandler;
{
    [Allo i: @"webView / runOpenPanelWithParameters / initiatedByFrame / completionHandler %@", [[self class] description]];
}

- (void) webView: (WKWebView *) webView runJavaScriptAlertPanelWithMessage: (NSString *) message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    [Allo i: @"webView / runJavaScriptAlertPanelWithMessage / initiatedByFrame / completionHandler %@", [[self class] description]];
    
    @try
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString (@"title_alert", @"Alert") message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_ok", @"Ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler();
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) webView: (WKWebView *) webView runJavaScriptConfirmPanelWithMessage: (NSString *) message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    [Allo i: @"webView / runJavaScriptConfirmPanelWithMessage / initiatedByFrame / completionHandler %@", [[self class] description]];

    @try
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedString (@"title_confirm", @"Confirm") message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            completionHandler(YES);
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler(NO);
        }]];
        [self presentViewController: alertController animated:YES completion:nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) webView: (WKWebView *) webView runJavaScriptTextInputPanelWithPrompt: (NSString *) prompt defaultText: (nullable NSString *) defaultText initiatedByFrame: (WKFrameInfo *) frame completionHandler: (void (^) (NSString * __nullable result)) completionHandler {
    [Allo i: @"webView / runJavaScriptTextInputPanelWithPrompt / defaultText / initiatedByFrame / completionHandler %@", [[self class] description]];

    @try
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = defaultText;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
            completionHandler(input);
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString (@"action_cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            completionHandler(nil);
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

#pragma mark - WKWebView WKNavigationDelegate

- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (null_unspecified WKNavigation *) navigation
{
    [Allo i: @"webView / didStartProvisionalNavigation [%@] %@", web.URL, [[self class] description]];
    
    @try
    {
        [self showIndicator];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) webView: (WKWebView *) webView didFinishNavigation: (null_unspecified WKNavigation *) navigation
{
    [Allo i: @"webView / didFinishNavigation [%@] %@", web.URL, [[self class] description]];
    
    @try
    {
        // [self hideIndicator];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [Allo i: @"webView / didFailNavigation [%@] %@", web.URL, [[self class] description]];

    @try
    {
        // [self hideIndicator];
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^) (WKNavigationActionPolicy)) decisionHandler
{
    [Allo i: @"webView / decidePolicyForNavigationAcśion / decisionHandler [%@] %@", navigationAction.request.URL.absoluteString, [[self class] description]];

    @try
    {
        // NSString *requestString = navigationAction.request.URL.absoluteString;
        decisionHandler (WKNavigationActionPolicyAllow);
    } @catch (NSException* e) { NSLog ( @"error : %@ %@", [e name], [e reason]); }
}

@end
