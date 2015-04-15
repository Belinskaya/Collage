//
//  Collage.h
//  InstaCollage
//
//  Created by Ekaterina Belinskaya on 05/03/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Collage : NSObject

@property (nonatomic, strong) NSMutableArray *collagePhotos;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;


+(Collage *) sharedInstance;

//-(UIImage *)getImageByIndex: (NSInteger) index;

@end
