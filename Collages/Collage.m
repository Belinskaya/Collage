//
//  Collage.m
//  InstaCollage
//
//  Created by Ekaterina Belinskaya on 05/03/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "Collage.h"

@implementation Collage

    static Collage *_sharedInstance = nil;

+ (Collage *)sharedInstance
{
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[Collage alloc] init];
        if (_sharedInstance){
            _sharedInstance.collagePhotos = [[NSMutableArray alloc] initWithCapacity:3];
            _sharedInstance.selectedPhotos = [[NSMutableArray alloc] initWithCapacity:1];
        }
    });
    return _sharedInstance;
}


@end
