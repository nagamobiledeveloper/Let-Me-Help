//
//  WebViewController.m
//  Let Me Help
//
//  Created by Nagaseshu Vadlapudi on 5/2/15.
//  Copyright (c) 2015 Naga. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()<WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UIButton *goForwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *domainLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet WKWebView *customWebView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *wkConfiguration = [[WKWebViewConfiguration alloc] init];
    self.customWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) configuration:wkConfiguration];
    
    self.customWebView.navigationDelegate = self;
    self.customWebView.allowsBackForwardNavigationGestures = YES;
    
    [self.customWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
    
    [self setBackAndForwardButtons];
    
    [self.domainLabel setTitleTextAttributes:@{
                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:20.0],
                                               NSForegroundColorAttributeName: [UIColor blackColor]
                                               } forState:UIControlStateNormal];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.customWebView loadRequest:request];
    [self.webViewContainer addSubview:self.customWebView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize containerSize = self.webViewContainer.frame.size;
    CGRect webViewFrame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    if (!CGRectEqualToRect(self.customWebView.frame, webViewFrame)) {
        self.customWebView.frame = webViewFrame;
    }
}

-(void)dealloc {
    if ([self isViewLoaded]) {
        [self.customWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

#pragma mark -  WebView delegates
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    WKNavigationActionPolicy decision = WKNavigationActionPolicyAllow;
    [self updateDomain:webView.URL];
    if (self.url == nil || [self.url isKindOfClass:[NSNull class]]) {
        decision = WKNavigationActionPolicyCancel;
    }
    
    decisionHandler(decision);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self setBackAndForwardButtons];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self setBackAndForwardButtons];
}

#pragma mark -  Helper methods
- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)webViewGoBackPressed:(id)sender {
    if ([self.customWebView canGoBack]) {
        [self.customWebView goBack];
    }
}

- (IBAction)webViewGoForwardPressed:(id)sender {
    if ([self.customWebView canGoForward]) {
        [self.customWebView goForward];
    }
}

- (void)setBackAndForwardButtons {
    if ([self.customWebView canGoBack]) {
        [self.goBackButton setEnabled:true];
        self.goBackButton.alpha = 1.0;
    } else{
        [self.goBackButton setEnabled:false];
        self.goBackButton.alpha = 0.3;
    }
    
    if ([self.customWebView canGoForward]) {
        [self.goForwardButton setEnabled:true];
        self.goForwardButton.alpha = 1.0;
    } else {
        [self.goForwardButton setEnabled:false];
        self.goForwardButton.alpha = 0.3;
    }
}

- (void)updateDomain:(NSURL *)url {
    if (![url isKindOfClass:[NSNull class]] && url != nil) {
        NSString *domain = [[NSMutableString alloc] initWithString:[url host]];
        if (domain != nil || ![domain  isEqual: @""]) {
            domain = [domain stringByReplacingOccurrencesOfString:@"www." withString:@""];
            if (![self.domainLabel.title isEqualToString:domain]) {
                self.domainLabel.title = domain;
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.customWebView) {
        if(self.customWebView.estimatedProgress == 1.0) {
            [self.progressView setProgress:0.0 animated:NO];
        } else {
            [self.progressView setProgress:self.customWebView.estimatedProgress animated:YES];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
