//
//  InstaUser.m
//  TestCollectionView
//
//  Created by Ekaterina Belinskaya on 07/11/14.
//  Copyright (c) 2014 Ekaterina Belinskaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstaUser.h"



@implementation InstaUser

-(instancetype)initWithName:(NSString*) uName
                     UserID:(NSString*) userId
                 PictureURL:(NSString *) pictureURL
                   FullName: (NSString *) fullName
                        Bio: (NSString *) userBio
                    WebSite: (NSString *) webSite{
    _pictureURL=pictureURL;
    _userId = userId;
    _userName = uName;
    _bio = userBio;
    _fullName = fullName;
    _website = webSite;
    return self;
}


@end