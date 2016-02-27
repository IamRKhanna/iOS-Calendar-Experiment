//
//  BackgroundCoverView.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/28/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "BackgroundCoverView.h"

@implementation BackgroundCoverView

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    height -= self.heightPadding;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((width-height)/2, self.heightPadding/2, height, height)];
    [path closePath];
    [self.fillColor setFill];
    [path fill];
}

@end
