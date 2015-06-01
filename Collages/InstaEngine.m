//
//  InstaEngine.m
//  InstaCollage
//
//  Created by Ekaterina Belinskaya on 10/02/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstaEngine.h"
#import "InstaUser.h"
#import "InstaPhoto.h"
#import "AFNetworking.h"



@implementation InstaEngine
/*
 ADD YOUR CLIENT_ID HERE
 */
static NSString *const client_id = @"267939c79a88482e8a99817dd74cde54";



static NSString *const redirectUri = @"http://instagram.com";
static NSString *const authUrlString = @"https://instagram.com/oauth/authorize/";
static NSString *const searchPeopleString = @"https://api.instagram.com/v1/users/search?q=";
static NSString *const recentPhotoString =@"https://api.instagram.com/v1/users/";
NSString *token;


static InstaEngine *_sharedInstance = nil;

+ (InstaEngine *)sharedInstance
{
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[InstaEngine alloc] init];
        if (_sharedInstance){
            token =  [[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"];
            //NSLog(@"TOKEN %@", token);
            if (token){
                _sharedInstance.isSignedIn = YES;
            } else {
                _sharedInstance.isSignedIn = NO;
            }
        }
    });
    return _sharedInstance;
}


-(BOOL) findTokenIn: (NSURL *) url{
    NSString* urlString = [url absoluteString];
    NSArray *UrlParts = [urlString componentsSeparatedByString:[NSString stringWithFormat:@"%@/", redirectUri]];
    if ([UrlParts count] > 1) {
        // do any of the following here
        urlString = [UrlParts objectAtIndex:1];
        NSRange accessToken = [urlString rangeOfString: @"#access_token="];
        if (accessToken.location != NSNotFound) {
            NSString* strAccessToken = [urlString substringFromIndex: NSMaxRange(accessToken)];
            //save
            [[NSUserDefaults standardUserDefaults] setValue:strAccessToken forKey: @"access_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            token = strAccessToken;
            _isSignedIn = YES;
            //we finded!!!
            return YES;
        }
    }
    return NO;
}

-(void) forgetUser{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_token"];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    _isSignedIn = NO;
    token = nil;
}

-(NSURL *) authUrl{
    NSString *fullAuthUrlString = [[NSString alloc]
                                   initWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&display=touch",
                                   authUrlString,
                                   client_id,
                                   redirectUri  ];
    NSLog(@"%@", fullAuthUrlString );
    NSURL *authUrl = [NSURL URLWithString:fullAuthUrlString];
    return authUrl;
}

-(NSString *) redirectUri{
    return redirectUri;
}

-(void) getDataWith:(NSURL *)url sendNotification: (NSString *) notificationName{

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __block __weak NSDictionary *dataDict = nil;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // 3
        dataDict = (NSDictionary *)responseObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:dataDict];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving user's photos"
                                                            message:@"Maybe this user is private"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    // 5
    [operation start];
}


-(NSURL *) getUsersSearchURLWith: (NSString *) queryString{
    NSString *resultURLString = nil;
    if (_sharedInstance.isSignedIn){
        resultURLString = [NSString stringWithFormat:@"%@%@&access_token=%@", searchPeopleString, queryString, token];
    }
    else {
        resultURLString = [NSString stringWithFormat:@"%@%@&client_id=%@", searchPeopleString, queryString, client_id];
    }
    NSURL *url= [NSURL URLWithString:[resultURLString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    return url;
}

-(NSURL *) getPhotoSearchURLWith: (NSString *) userID{
    NSString *resultURLString = nil;
    if (_sharedInstance.isSignedIn){
        resultURLString = [NSString stringWithFormat:@"%@%@/media/recent?count=20&access_token=%@", recentPhotoString, userID, token];
    } else {
        resultURLString = [NSString stringWithFormat:@"%@%@/media/recent?count=20&client_id=%@", recentPhotoString, userID, client_id];
    }
    NSURL *url = [NSURL URLWithString:[resultURLString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    return url;
}

+ (NSMutableArray *) parseUsersWith: (NSDictionary *) dict{
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *dataArray = [dict objectForKey:@"data"];
    for (int i=0; i< dataArray.count; i++) {
        NSString *userId = [dataArray[i] objectForKey:@"id"];
        NSString *userName = [dataArray[i] objectForKey:@"username"];
        NSString *pictureURL = [dataArray[i] objectForKey:@"profile_picture"];
        NSString *webSite = [dataArray[i] objectForKey:@"website"];
        NSString *bio = [dataArray[i] objectForKey:@"bio"];
        NSString *full_name = [dataArray[i] objectForKey:@"full_name"];
        InstaUser *user = [[InstaUser alloc] initWithName:userName
                                                   UserID:userId
                                               PictureURL:pictureURL
                                                 FullName:full_name
                                                      Bio:bio
                                                  WebSite:webSite];
        [users addObject:user];

    };

    return users;
}


+(NSMutableArray *) parsePhotos: (NSMutableArray *) photos{
    NSMutableArray *parsedPhoto = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *itm in photos){
        NSString *photoId = [itm objectForKey:@"id"];
        NSDictionary *thumbnail = [[itm objectForKey:@"images"] objectForKey:@"thumbnail"];
        NSDictionary *stResolution = [[itm objectForKey:@"images"] objectForKey:@"standard_resolution"];
        NSInteger likesCount = (NSInteger)[[itm objectForKey:@"likes"] objectForKey:@"count"];
        //NSString *txt = [[itm objectForKey:@"caption"] objectForKey:@"text"];
        
        InstaPhoto *photo = [[InstaPhoto alloc] initWithPthotoId:photoId Likes: likesCount User:nil Thumbnail:thumbnail StandartResolution:stResolution text:nil commentCount:0];
        [parsedPhoto addObject:photo];
        
    }
    return parsedPhoto;
}


@end
