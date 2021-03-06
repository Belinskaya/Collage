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
@property (weak, nonatomic) IBOutlet UIView *viewForDrawing;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@end
