//
//  ChangingBordersViewController.h
//  Collages
//
//  Created by Ekaterina Belinskaya on 19/04/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BordersDelegate <NSObject>
@required
-(void)changeBordersWidth: (UISlider *) sender;
-(void)changeConerRadius:(UISlider *) sender;
@end

@interface ChangingBordersViewController : UIViewController

@property (nonatomic, weak) id<BordersDelegate> delegate;

@end
