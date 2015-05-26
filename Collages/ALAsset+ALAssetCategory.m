//
//  ALAsset+ALAssetCategory.m
//  Collages
//
//  Created by Ekaterina Belinskaya on 22/05/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "ALAsset+ALAssetCategory.h"

@implementation ALAsset (ALAssetCategory)

- (NSDate *) date
{
    return [self valueForProperty:ALAssetPropertyDate];
}

@end
