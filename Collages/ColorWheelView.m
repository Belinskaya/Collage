//
//  ColorWheelView.m
//  testWheel
//
//  Created by Ekaterina Belinskaya on 27/05/15.
//  Copyright (c) 2015 Ekaterina Belinskaya. All rights reserved.
//

#import "ColorWheelView.h"
#import "MSColorUtils.h"

@interface ColorWheelView()
{
    @private

    CALayer *_indicatorLayer;
    CGFloat _hue;
    CGFloat _saturation;
}
@end

@implementation ColorWheelView


+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _hue = 0.0f;
        _saturation = 0.0f;
        
        self.layer.delegate = self;
        [self.layer addSublayer:[self indicatorLayer]];
        
        //    [self setSelectedPoint:CGPointMake(dimension / 2, dimension / 2)];
    }
    
    return self;
}

- (CALayer *)indicatorLayer
{
    if (!_indicatorLayer) {
        CGFloat dimension = 33;
        UIColor *edgeColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        _indicatorLayer = [CALayer layer];
        _indicatorLayer.cornerRadius = dimension / 2;
        _indicatorLayer.borderColor = edgeColor.CGColor;
        _indicatorLayer.borderWidth = 2;
        _indicatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
        _indicatorLayer.bounds = CGRectMake(0, 0, dimension, dimension);
        _indicatorLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
        _indicatorLayer.shadowColor = [UIColor blackColor].CGColor;
        _indicatorLayer.shadowOffset = CGSizeZero;
        _indicatorLayer.shadowRadius = 1;
        _indicatorLayer.shadowOpacity = 0.5f;
    }
    
    return _indicatorLayer;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint position = [[touches anyObject] locationInView:self];
    
    [self onTouchEventWithPosition:position];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint position = [[touches anyObject] locationInView:self];
    
    [self onTouchEventWithPosition:position];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint position = [[touches anyObject] locationInView:self];
    
    [self onTouchEventWithPosition:position];
}

- (void)onTouchEventWithPosition:(CGPoint)point
{
    CGFloat radius = CGRectGetWidth(self.bounds) / 2;
    CGFloat dist = sqrtf((radius - point.x) * (radius - point.x) + (radius - point.y) * (radius - point.y));
    
    if (dist <= radius) {
        [self ms_colorWheelValueWithPosition:point hue:&_hue saturation:&_saturation];
        [self setSelectedPoint:point];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelectedPoint:(CGPoint)point
{
    UIColor *selectedColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:1.0f alpha:1.0f];
    [_delegate changeColor:selectedColor];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    self.indicatorLayer.position = point;
    self.indicatorLayer.backgroundColor = selectedColor.CGColor;
    [CATransaction commit];
}

- (void)setHue:(CGFloat)hue
{
    _hue = hue;
    [self setSelectedPoint:[self ms_selectedPoint]];
    [self setNeedsDisplay];
}

- (void)setSaturation:(CGFloat)saturation
{
    _saturation = saturation;
    [self setSelectedPoint:[self ms_selectedPoint]];
    [self setNeedsDisplay];
}

#pragma mark - CALayerDelegate methods

- (void)displayLayer:(CALayer *)layer
{
    CGFloat dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CFMutableDataRef bitmapData = CFDataCreateMutable(NULL, 0);
    
    CFDataSetLength(bitmapData, dimension * dimension * 4);
    [self ms_colorWheelBitmap:CFDataGetMutableBytePtr(bitmapData) withSize:CGSizeMake(dimension, dimension)];
    id image = [self ms_imageWithRGBAData:bitmapData width:dimension height:dimension];
    CFRelease(bitmapData);
    self.layer.contents = image;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (layer == self.layer) {
        [self setSelectedPoint:[self ms_selectedPoint]];
        [self.layer setNeedsDisplay];
    }
}

#pragma mark - Private methods

- (CGPoint)ms_selectedPoint
{
    CGFloat dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGFloat radius = _saturation * dimension / 2;
    CGFloat x = dimension / 2 + radius * cosf(_hue * M_PI * 2.0f);
    CGFloat y = dimension / 2 + radius * sinf(_hue * M_PI * 2.0f);
    
    return CGPointMake(x, y);
}

- (void)ms_colorWheelBitmap:(out UInt8 *)bitmap withSize:(CGSize)size
{
    for (NSUInteger y = 0; y < size.width; y++) {
        for (NSUInteger x = 0; x < size.height; x++) {
            CGFloat hue, saturation, a = 0.0f;
            [self ms_colorWheelValueWithPosition:CGPointMake(x, y) hue:&hue saturation:&saturation];
            RGB rgb = { 0.0f, 0.0f, 0.0f, 0.0f };
            
            if (saturation < 1.0) {
                // Antialias the edge of the circle.
                if (saturation > 0.99) {
                    a = (1.0 - saturation) * 100;
                } else {
                    a = 1.0;
                }
                
                HSB hsb = { hue, saturation, 1.0f, a };
                rgb = MSHSB2RGB(hsb);
            }
            
            NSInteger i = 4 * (x + y * size.width);
            bitmap[i] = rgb.red * 0xff;
            bitmap[i + 1] = rgb.green * 0xff;
            bitmap[i + 2] = rgb.blue * 0xff;
            bitmap[i + 3] = rgb.alpha * 0xff;
        }
    }
}

- (void)ms_colorWheelValueWithPosition:(CGPoint)position hue:(out CGFloat *)hue saturation:(out CGFloat *)saturation
{
    NSInteger c = CGRectGetWidth(self.bounds) / 2;
    CGFloat dx = (float)(position.x - c) / c;
    CGFloat dy = (float)(position.y - c) / c;
    CGFloat d = sqrtf((float)(dx * dx + dy * dy));
    
    *saturation = d;
    
    if (d == 0) {
        *hue = 0;
    } else {
        *hue = acosf((float)dx / d) / M_PI / 2.0f;
        
        if (dy < 0) {
            *hue = 1.0 - *hue;
        }
    }
}

- (id)ms_imageWithRGBAData:(CFDataRef)data width:(NSUInteger)width height:(NSUInteger)height
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, 0, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colorSpace);
    return (__bridge_transfer id)imageRef;
}

@end

