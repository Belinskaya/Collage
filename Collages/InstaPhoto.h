//
//  InstaPhoto.h
//  TestCollectionView
//
//  Created by Ekaterina Belinskaya on 07/11/14.
//  Copyright (c) 2014 Ekaterina Belinskaya. All rights reserved.
//

#ifndef TestCollectionView_InstaPhoto_h
#define TestCollectionView_InstaPhoto_h


#endif

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "InstaUser.h"

@interface InstaPhoto : NSObject

@property (nonatomic, strong) NSString *photoID;
@property  NSInteger likesCount;
@property (nonatomic, strong) InstaUser *user;
@property (nonatomic, strong) NSDictionary *standard_resolution;
@property (nonatomic, strong) NSDictionary *thumbnail;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSMutableArray *comments;
@property NSInteger commentCount;


-(instancetype)initWithPthotoId: (NSString*) photoID
                          Likes:(NSInteger) likes
                           User: (InstaUser*) user
                      Thumbnail: (NSDictionary*) thumb
             StandartResolution: (NSDictionary*) stResolution
                           text: (NSString*) txt
                   commentCount: (NSInteger) count;

-(NSURL*) getThumbnailURL;
-(NSURL*) getStandartResolutionURL;
-(UIImage*) getThumbnailImage;
-(UIImage*) getStandartResImage;
-(CGSize) getThumbnailSize;
-(CGSize) getStandartResolutionSize;

@end