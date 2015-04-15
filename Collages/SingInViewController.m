//
//  SingInViewController.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 15/03/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "SingInViewController.h"
#import "InstaEngine.h"

@interface SingInViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) InstaEngine *iEngine;

@end

@implementation SingInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _iEngine = [InstaEngine sharedInstance];
    
    _webView.delegate = self;
    NSMutableURLRequest  *request = [NSMutableURLRequest requestWithURL:[_iEngine authUrl]];
    [_webView loadRequest:request];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicator setHidden:NO];
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_activityIndicator stopAnimating];
    [_activityIndicator setHidden:YES];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([_iEngine findTokenIn:[request URL]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
