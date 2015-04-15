//
//  ImageCollectionViewCell.h
//  InstaCollage
//
//  Created by Ekaterina Belinskaya on 18/02/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
