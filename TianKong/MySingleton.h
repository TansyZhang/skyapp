//
//  MySingleton.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 10/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <CoreGraphics/CGGeometry.h>

@interface MySingleton : NSObject

//global variable declaration
@property (nonatomic,retain) NSNumber *globalLang;
@property (nonatomic,retain) NSBundle *globalLocaleBundle; //Lang --> Path --> Bundle (for changing lang on fly)
@property (nonatomic,retain) NSString *globalUserType;
@property (nonatomic,retain) NSString *globalUserName;
@property (nonatomic,retain) NSString *globalUserID;
@property (nonatomic,retain) NSString *globalOnSelectedNoteID;
@property (nonatomic,retain) NSString *globalReceivedNoteStr;

//will cancel global variables
@property (nonatomic,retain) NSData *globalImageData;
@property (nonatomic,assign) CGRect globalImageRect;

//for init tf frame size
@property (nonatomic,assign) CGRect globalPreviousTFFrame;

+(MySingleton*) getInstance;

//Retina Display Resize Image Ref: iCab Blog - Scaling images and creating thumbnails from UIViews
+ (void)beginImageContextWithSize:(CGSize)size;
+ (void)endImageContext;
+ (UIImage*)imageFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

extern const int R_LENGTH;
extern const int MAX_TF_CHAR;
extern const int MAX_TF_WIDTH;
extern const int MAX_TF_HEIGHT;
extern const int MIN_TF_WIDTH;

@end