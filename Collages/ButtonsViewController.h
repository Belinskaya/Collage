//
//  ButtonsViewController.h
//  Collages
//
//  Created by Ekaterina Belinskaya on 19/04/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ButtonsDelegate <NSObject>
@required
-(void)showBordersPopover:(id) sender;
-(void)aboutClicked:(id) sender;
@end

@interface ButtonsViewController : UIViewController

@property (nonatomic, weak) id<ButtonsDelegate> delegate;

@end
