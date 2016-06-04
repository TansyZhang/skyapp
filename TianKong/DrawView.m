//
//  DrawView.m
//  getituseit
//
//  Created by Leo Yeung on 6/8/14.
//
//

#import "DrawView.h"
#import "UIView-Transform.h"
#import "MySingleton.h"


#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

const int SCALE_MIN_VIEW = 100;

@implementation DrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        strokes = [NSMutableArray array];
        touchPaths = [NSMutableDictionary dictionary];
        didDraw = NO;
        
        //transparent background
        //self.alpha = myAlphaFloat;
        UIColor *transparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05f];
        self.backgroundColor = transparentColor;
        self.opaque = NO;
        
        //add Button
        btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        //********* need to determine better
        btn.frame= CGRectMake(self.frame.size.width-80, 0, 80, 44); //toolbar = 44
        //*********	self.previewButton.enabled=false;

        btn.layer.borderColor = [UIColor blackColor].CGColor;
        btn.layer.borderWidth = 3.0f;
        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn setTitle:@"Finish" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [btn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{

        
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        CGPoint pt = [touch locationInView:self];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = IS_IPAD? 3: 1;
        path.lineCapStyle = kCGLineCapRound;
        [path moveToPoint:pt];
        
        [touchPaths setObject:path forKey:key];
    }
    
}

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        UIBezierPath *path = [touchPaths objectForKey:key];
        if (!path) break;
        
        CGPoint pt = [touch locationInView:self];
        [path addLineToPoint:pt];
    }
    
    [self setNeedsDisplay];
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        UIBezierPath *path = [touchPaths objectForKey:key];
        if (path) [strokes addObject:path];
        [touchPaths removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //(@"touchesCancelled");
	[self touchesEnded:touches withEvent:event];
}

- (void) drawRect:(CGRect)rect
{
	[COOKBOOK_PURPLE_COLOR set];
    for (UIBezierPath *path in strokes)
        [path stroke];
    
    [[COOKBOOK_PURPLE_COLOR colorWithAlphaComponent:0.5f] set];
    for (UIBezierPath *path in [touchPaths allValues]){
        didDraw = YES;
        [path stroke];
    }
}

- (void)finishAction {
    MySingleton* singleton = [MySingleton getInstance];
    
    btn.hidden = true;
    [btn removeFromSuperview];

    //real transparent
    UIColor *realTransparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.backgroundColor = realTransparentColor;
    self.opaque = NO;
    
    //NSLog( @"%@", strokes );
    //NSLog (@"Number of Objects in Array %i", strokes.count);

    //check if user did draw something
    if (didDraw){
        //sizeToFit by myself
        
        int newMinX = 0; int newMinY = 0; int newMaxX = 0; int newMaxY =0;
        int minX = 10000; int minY = 10000; int maxX = 0; int maxY = 0;
        for (UIBezierPath *path in strokes){
            //NSLog(@"This path = %@",path);
            newMinX = CGRectGetMinX(path.bounds);
            if (newMinX > 10000)
                newMinX = 10000;
            newMinY = CGRectGetMinY(path.bounds);
            if (newMinY > 10000)
                newMinY = 10000;
            newMaxX = CGRectGetMaxX(path.bounds);
            if (newMaxX > 10000)
                newMaxX = 0;
            newMaxY = CGRectGetMaxY(path.bounds);
            if (newMaxY > 10000)
                newMaxY = 0;
            
            if (newMinX < minX)
                minX = newMinX;
            if (newMinY < minY)
                minY = newMinY;
            if (newMaxX > maxX)
                maxX = newMaxX;
            if (newMaxY > maxY)
                maxY = newMaxY;
        }
        minX = minX - 5;
        minY = minY - 5;
        maxX = maxX + 5;
        maxY = maxY + 5;
        
        if (maxX - minX < SCALE_MIN_VIEW){
            int difference = SCALE_MIN_VIEW - (maxX - minX);
            maxX = maxX + difference/2;
            minX = minX - difference/2;
        }
        
        if (maxY - minY < SCALE_MIN_VIEW){
            int difference = SCALE_MIN_VIEW - (maxY - minY);
            maxY = maxY + difference/2;
            minY = minY - difference/2;
        }
        
        singleton.globalImageRect = CGRectMake(self.frame.origin.x+minX, self.frame.origin.y+minY, maxX-minX, maxY-minY);
        
        CGRect screenRect = self.bounds;
        UIGraphicsBeginImageContextWithOptions(screenRect.size, NO, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        singleton.globalImageData = UIImagePNGRepresentation(img);
        
        //tell Gallery get the image and close this popup
        [self performSelector:@selector(noticeDismiss) withObject:nil afterDelay:0.1];
    }else{
        [self performSelector:@selector(noticeDismissWithNoStroke) withObject:nil afterDelay:0.1];
    }
}

-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DrawViewDismissed"
                                                        object:nil
                                                      userInfo:nil];
}

-(void)noticeDismissWithNoStroke{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DrawViewDismissedWithNoStroke"
                                                        object:nil
                                                      userInfo:nil];
}

@end
