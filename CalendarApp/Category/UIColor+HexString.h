//
//  UIColor+HexString.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/13/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (CGFloat) colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length;

@end