//
//  ColorWheelView.h
//  testWheel
//
//  Created by Ekaterina Belinskaya on 27/05/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>


@protocol ColorDelegate <NSObject>
@required
-(void)changeColor: (UIColor *) sender;
@end
@interface ColorWheelView : UIControl

//! @abstract The hue value.
@property (nonatomic, assign) CGFloat hue;

//! @abstract The saturation value.
@property (nonatomic, assign) CGFloat saturation;
@property (nonatomic, weak) id<ColorDelegate> delegate;

@end
