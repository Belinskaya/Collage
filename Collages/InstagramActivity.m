//
//  InstagramActivity.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 03/05/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "InstagramActivity.h"

@implementation InstagramActivity

- (NSString *)activityType {
    return @"Instagram";
}

- (NSString *)activityTitle {
    return @"Instagram";
}

- (UIImage *)_activityImage {
    return [UIImage imageNamed:@"insta_icon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
}

-(void)performActivity {
    [self activityDidFinish:YES];
}


@end
