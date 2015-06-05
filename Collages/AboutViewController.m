//
//  AboutViewController.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 04/06/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIView *logoFrameView;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@end


@implementation AboutViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    
    UIColor *mainBackgroundColor = [UIColor colorWithRed:103.0f/255.0f green:128.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
    self.view.backgroundColor = mainBackgroundColor;
    _logoImageView.layer.masksToBounds = YES;
    _logoImageView.layer.cornerRadius = 15;
    
}

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    //[iRate sharedInstance].applicationBundleID = @"com.charcoaldesign.RainbowBlocksLite";
    
    //enable preview mode
    [iRate sharedInstance].previewMode = YES;
    
    //prevent automatic prompt
    [iRate sharedInstance].promptAtLaunch = NO;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    UIColor *lineColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //line under logoFrame
    [path moveToPoint:CGPointMake( 20, _logoFrameView.frame.origin.y + _logoFrameView.frame.size.height)];
    [path addLineToPoint:CGPointMake( self.view.frame.size.width-20, _logoFrameView.frame.origin.y + _logoFrameView.frame.size.height)];
    
    //line under signLabel
    [path moveToPoint:CGPointMake( 20, _signLabel.frame.origin.y + _signLabel.frame.size.height + 30.0f)];
    [path addLineToPoint:CGPointMake( self.view.frame.size.width - 20, _signLabel.frame.origin.y + _signLabel.frame.size.height + 30.0f)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = lineColor.CGColor;
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];

    
}

- (IBAction)sendFeedback:(id)sender {
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        
        [mailCont setSubject:@"Collages - Feedback"];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"kate.belinskaya@gmail.com"]];
        //[mailCont setMessageBody:@"Email message" isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)rateApp:(id)sender {
    [[iRate sharedInstance] promptIfNetworkAvailable];
}

@end
