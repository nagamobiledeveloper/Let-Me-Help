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
@property (strong, nonatomic) IBOutlet UIButton *goBackButton;
@property (strong, nonatomic) IBOutlet UIButton *goForwardButton;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.customWebView.delegate = self;
    [self setBackAndForwardButtons];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.customWebView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.url != nil && ![self.url isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setBackAndForwardButtons];
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
@end
