//
//  DragLabel.h
//  Skyapp
//
//  Created by Leo Yeung on 30/6/14.
//
//

#import <UIKit/UIKit.h>

@interface DragView : UIImageView <UIGestureRecognizerDelegate>
{
    //Ready for future development
    CGFloat tx; // x translation
    CGFloat ty; // y translation
    CGFloat scale; // zoom scale
    CGFloat theta; // rotation angle
    
    //float minScale;
    //float maxScale;
    
    //status for drag and menu
    NSString * status;
    NSString * link; //related to URL
    NSString * title; // related to URL
    
    CAShapeLayer * dashBorder;
}

- (id) initWithImage:(UIImage *)image andLink:(NSString*)myLink andTitle:(NSString*)myTitle;
- (id) initWithImage:(UIImage *)image andFrame:(CGRect)rect andBounds:(CGRect)myBounds andSCALE:(CGFloat)myScale andTHETA:(CGFloat)myTheta andLink:(NSString*)myLink andTitle:(NSString*)myTitle;

- (NSString *) getLINK;
- (NSString *) getTITLE;
- (CGFloat) getSCALE;
- (CGFloat) getTHETA;
- (void) setTHETA:(CGFloat) myTheta;

- (void) refreshFrame;
- (void) refreshBorder;
- (void) restoreOriginal;
- (void) onHighLight;
- (void) offHighLight;

@end