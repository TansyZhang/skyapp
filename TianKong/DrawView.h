//
//  DrawView.h
//  getituseit
//
//  Created by Leo Yeung on 6/8/14.
//
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView
{
	CGFloat tx; // x translation
	CGFloat ty; // y translation
	CGFloat scale; // zoom scale
	CGFloat theta; // rotation angle
    
    NSMutableArray *strokes;
    NSMutableDictionary *touchPaths;
    UIButton *btn;
    bool didDraw;
}
- (id) initWithFrame:(CGRect)frame;

@end



