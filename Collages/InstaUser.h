//
//  InstaUser.h
//  TestCollectionView
//
//  Created by Ekaterina Belinskaya on 07/11/14.
//  Copyright (c) 2014 Ekaterina Belinskaya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface InstaUser : NSObject

@property (nonatomic, strong) NSString *userName;
@property  (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *pictureURL;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *fullName;


-(instancetype)initWithName:(NSString*) uName
                     UserID:(NSString*) userId
                 PictureURL:(NSString *) pictureURL
                   FullName: (NSString *) fullName
                        Bio: (NSString *) userBio
                    WebSite: (NSString *) webSite ;



@end