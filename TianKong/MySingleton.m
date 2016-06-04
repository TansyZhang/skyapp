//
//  MySingleton.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 10/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "MySingleton.h"

@implementation MySingleton

const int R_LENGTH = 80;
const int MAX_TF_CHAR = 20;
const int MAX_TF_WIDTH = 770;
const int MAX_TF_HEIGHT = 80;
const int MIN_TF_WIDTH = 55;

@synthesize globalLang;
@synthesize globalLocaleBundle;
@synthesize globalUserType;
@synthesize globalUserName;
@synthesize globalUserID;
@synthesize globalOnSelectedNoteID;
@synthesize globalReceivedNoteStr;
@synthesize globalImageData;
@synthesize globalImageRect;
@synthesize globalPreviousTFFrame;

static MySingleton *singletonInstance;

+ (MySingleton*)getInstance{
    if (singletonInstance == nil) {
        singletonInstance = [[super alloc] init];
    }
    return singletonInstance;
}


//Retina Display Resize Image Ref: iCab Blog - Scaling images and creating thumbnails from UIViews
+ (void)beginImageContextWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (void)endImageContext
{
    UIGraphicsEndImageContext();
}

+ (UIImage*)imageFromView:(UIView*)view
{
    [self beginImageContextWithSize:[view bounds].size];
    BOOL hidden = [view isHidden];
    [view setHidden:NO];
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    [view setHidden:hidden];
    return image;
}

+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize
{
    UIImage *image = [self imageFromView:view];
    if ([view bounds].size.width != newSize.width ||
        [view bounds].size.height != newSize.height) {
        image = [self imageWithImage:image scaledToSize:newSize];
    }
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    [self beginImageContextWithSize:newSize];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return newImage;
}


@end