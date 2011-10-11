
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/


#import "TourUnderLineLabel.h"


@implementation TourUnderLineLabel


- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    const CGFloat* colors = CGColorGetComponents(self.textColor.CGColor);
    
    CGContextSetRGBStrokeColor(ctx, colors[0], colors[1], colors[2], 1.0); // RGBA
    
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGSize tmpSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(200, 9999)];
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height - 1);
    CGContextAddLineToPoint(ctx, tmpSize.width, self.bounds.size.height - 1);
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];  
}

@end
