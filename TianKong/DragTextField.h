//
//  DragTextField.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 4/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragTextField: UITextField <UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    //Ready for future development
    CGFloat tx; // x translation
    CGFloat ty; // y translation
    CGFloat scale; // zoom scale
    CGFloat theta; // rotation angle
    
    NSMutableAttributedString *myAttributedText;
    
    //status for drag and menu
    NSString * status;
    NSString * link; //related to URL
    NSString * title; // related to URL
    
    CAShapeLayer * dashBorder;
    
    //data for keyboard moveup
    bool movedUp;
    int originalY;
}

- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle;
- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta;

- (NSString *) getLINK;
- (NSString *) getTITLE;
- (CGFloat) getSCALE;
- (CGFloat) getTHETA;
- (NSString *) getSTR;
- (NSString *) getSTATUS;

//for everytime refresh
- (void) toLayerTop;

- (void) refreshFrame;
- (void) refreshBorder;
- (void) restoreOriginal;
- (void) onHighLight;
- (void) offHighLight;



@end
