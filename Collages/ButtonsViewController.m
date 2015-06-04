//
//  ButtonsViewController.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 19/04/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "ButtonsViewController.h"

@interface ButtonsViewController ()

@end

@implementation ButtonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(100.0f, 80.0f);
    //-------------------------------BORDERS-------------------------------
    UIButton *borderButton = [UIButton buttonWithType: UIButtonTypeSystem];//[[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 30)];
    [borderButton addTarget:_delegate
                     action:@selector(showBordersPopover:)
           forControlEvents:UIControlEventTouchUpInside];
    [borderButton setTitle:@"Borders" forState:UIControlStateNormal];
    borderButton.frame = CGRectMake (0,0, 100.0f, 40.0f);
    [self.view addSubview:borderButton];
    [self drawLineWithStartX:0 StartY:40.0f EndX:100.0f EndY:40.0f];
    
    //----------------------------------ABOUT--------------------------------------
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [aboutButton addTarget:_delegate
                    action:@selector(aboutClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    [aboutButton setTitle:@"About" forState:UIControlStateNormal];
    aboutButton.frame = CGRectMake (0,40, 100.0f, 40.0f);
    [self.view addSubview:aboutButton];
    
    // Do any additional setup after loading the view.
}

-(void) drawLineWithStartX: (float) x1 StartY: (float) y1 EndX: (float) x2 EndY:(float) y2{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake( x1, y1)];
    [path addLineToPoint:CGPointMake( x2, y2)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.view.layer addSublayer:shapeLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
