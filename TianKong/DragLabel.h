//
//  DragLabel.h
//  Skyapp
//
//  Created by Leo Yeung on 30/6/14.
//
//

#import <UIKit/UIKit.h>

@interface DragLabel : UILabel <UIGestureRecognizerDelegate>
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
}

- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle;
- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta;
- (void)updateText:(NSAttributedString *)myStr;

- (NSString *) getLINK;
- (NSString *) getTITLE;
- (CGFloat) getSCALE;
- (CGFloat) getTHETA;
- (NSAttributedString *) getAttStr;

- (void) refreshFrame;
- (void) refreshBorder;
- (void) restoreOriginal;
- (void) onHighLight;
- (void) offHighLight;

@end



