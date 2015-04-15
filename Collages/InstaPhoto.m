//
//  InstaPhoto.m
//  TestCollectionView
//
//  Created by Ekaterina Belinskaya on 07/11/14.
//  Copyright (c) 2014 Ekaterina Belinskaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstaPhoto.h"

@interface InstaPhoto ()

@property (nonatomic, strong) UIImage *photoImage;

@end

@implementation InstaPhoto

-(NSURL*) getThumbnailURL;
{
    NSString *urlString = [_thumbnail objectForKey:@"url"];
    return [NSURL URLWithString:urlString];
    
}
-(NSURL*) getStandartResolutionURL
{
    NSString *urlString = [_standard_resolution objectForKey:@"url"];
    return [NSURL URLWithString:urlString];
}
-(UIImage*) getThumbnailImage
{
    NSURL *imageURL = [self getThumbnailURL];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    return [UIImage imageWithData:imageData];
}
-(UIImage*) getStandartResImage
{
    NSURL *imageURL = [self getStandartResolutionURL];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    return [UIImage imageWithData:imageData];
}

-(instancetype)initWithPthotoId: (NSString*) photoID
                  Likes:(NSInteger) likes
                   User: (InstaUser*) user
              Thumbnail: (NSDictionary*) thumb
             StandartResolution: (NSDictionary*) stResolution
                           text: (NSString*) txt
                   commentCount: (NSInteger) count
{
    _photoID = photoID;
    _likesCount = likes;
    _user = user;
    _thumbnail = thumb;
    _standard_resolution = stResolution;
    _text = txt;
    _commentCount = count;
    return self;
}

-(CGSize) getThumbnailSize
{
    NSInteger w = [[_thumbnail objectForKey:@"width"] integerValue];
    NSInteger h = [[_thumbnail objectForKey:@"height"] integerValue];
    CGSize size = CGSizeMake(w, h);
    return size;
}

-(CGSize) getStandartResolutionSize
{
    NSInteger w = [[_standard_resolution objectForKey:@"width"] integerValue];
    NSInteger h = [[_standard_resolution objectForKey:@"height"] integerValue];
    CGSize size = CGSizeMake(w, h);
    return size;
}

/*-(instancetype)init{
    [self initWithPthotoId:@"-1" Likes:0 User:nil Thumbnail:nil StandartResolution:nil];
    return self;
}*/

@end
