//
//  ChangingBordersViewController.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 19/04/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "ChangingBordersViewController.h"

@interface ChangingBordersViewController ()

@end

@implementation ChangingBordersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(200.0f, 300.0f);
    
    //----------------------------Border width label---------------------------
    UILabel *borderWidthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200.0f, 30.0f)];
    borderWidthLabel.text = @"Border width";
    borderWidthLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:borderWidthLabel];
    
    //----------------------------Border width slider---------------------------
    UISlider *borderWidthSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, borderWidthLabel.frame.origin.y+20, 200.0f, 30.0f)];
    borderWidthSlider.maximumValue = 20;
    borderWidthSlider.minimumValue = 0;
    [borderWidthSlider addTarget:_delegate action:@selector(changeBordersWidth:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:borderWidthSlider];
    
    //------------------------------Border Coner label---------------
    UILabel *borderCornerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, borderWidthSlider.frame.origin.y+40, 200.0f, 30.0f)];
    borderCornerLabel.text = @"Border coner radius";
    borderCornerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:borderCornerLabel];
    
    //----------------------------Border coner slider---------------------------
    UISlider *cornerRadiusSlider =[[UISlider alloc] initWithFrame:CGRectMake(0, borderCornerLabel.frame.origin.y+30, 200.0f, 30.0f)];
    cornerRadiusSlider.minimumValue = 0;
    cornerRadiusSlider.maximumValue = 100;
    [cornerRadiusSlider addTarget:_delegate action:@selector(changeConerRadius:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:cornerRadiusSlider];
    
    //-------------------------------Color Wheel----------------------------------
    _colorWheel = [[ColorWheelView alloc] initWithFrame:CGRectMake(0, cornerRadiusSlider.frame.origin.y+30, 150.0f, 150.0f)];
    [self.view addSubview:_colorWheel];
    CGPoint newCenter = CGPointMake(self.preferredContentSize.width/2, _colorWheel.center.y);
    _colorWheel.center = newCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

@end
