//
//  WebViewController.m
//  Let Me Help
//
//  Created by Nagaseshu Vadlapudi on 5/2/15.
//  Copyright (c) 2015 Naga. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *customWebView;
- (IBAction)doneButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UIButton *goForwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *domainLabel;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customWebView.delegate = self;
    [self setBackAndForwardButtons];
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    
    // Set swipe direction
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture to customWebView
    [self.customWebView addGestureRecognizer:swipeGestureLeft];
    [self.customWebView addGestureRecognizer:swipeGestureRight];
    
    [self.domainLabel setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:20.0],
                                         NSForegroundColorAttributeName: [UIColor blackColor]
                                         } forState:UIControlStateNormal];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.customWebView loadRequest:request];
}

-(void)dealloc {
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.url != nil && ![self.url isKindOfClass:[NSNull class]]) {
        return YES;
    }
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setBackAndForwardButtons];
    [self updateDomain:webView.request.URL];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self setBackAndForwardButtons];
}

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

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self webViewGoForwardPressed:nil];
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [self webViewGoBackPressed:nil];
    } 
    
    [self setBackAndForwardButtons];
}

- (void)updateDomain:(NSURL *)url {
    if (![url isKindOfClass:[NSNull class]] && url != nil) {
        NSString *domain = [[NSMutableString alloc] initWithString:[url host]];
        if (domain != nil || ![domain  isEqual: @""]) {
            domain = [domain stringByReplacingOccurrencesOfString:@"www."                                             withString:@""];
            if (![self.domainLabel.title isEqualToString:domain]) {
                self.domainLabel.title = domain;
            }
        }
    }
}
@end
