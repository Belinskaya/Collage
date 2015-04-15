//
//  Header.h
//  InstaCollage
//
//  Created by Ekaterina Belinskaya on 10/02/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstaEngine : NSObject

@property BOOL isSignedIn;

+ (InstaEngine *)sharedInstance;


-(NSURL *) authUrl;
-(NSString *) redirectUri;
-(BOOL) findTokenIn: (NSURL *) url;
-(void) forgetUser;

-(void) getDataWith:(NSURL *)url sendNotification: (NSString *) notificationName;

-(NSURL *) getUsersSearchURLWith: (NSString *) queryString;-(NSURL *) getPhotoSearchURLWith: (NSString *) userID;


+(NSMutableArray *) parseUsersWith: (NSDictionary *) dict;
+(NSMutableArray *) parsePhotos: (NSMutableArray *) photos;



@end
