//
//  RKCalendarMonthCoverScrollView.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/27/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKCalendarMonthCoverScrollView : UIScrollView

@property (nonatomic, strong) NSDictionary *textAttributes;

- (void)updateWithFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate calendar:(NSCalendar *)calendar rowHeight:(CGFloat)rowHeight;

@end
