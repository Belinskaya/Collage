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

@end


@implementation AboutViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    
    UIColor *mainBackgroundColor = [UIColor colorWithRed:103.0f/255.0f green:128.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
    self.view.backgroundColor = mainBackgroundColor;
    _logoImageView.layer.masksToBounds = YES;
    _logoImageView.layer.cornerRadius = 15;
    
    _feedbackButton.layer.shadowRadius = 3.0f;
    _feedbackButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _feedbackButton.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _feedbackButton.layer.shadowOpacity = 0.5f;
    _feedbackButton.layer.masksToBounds = NO;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake( 20, _logoFrameView.frame.origin.y + _logoFrameView.frame.size.height)];
    [path addLineToPoint:CGPointMake( self.view.frame.size.width-20, _logoFrameView.frame.origin.y + _logoFrameView.frame.size.height)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    UIColor *lineColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
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

@end
