//
//  NSDate+RKCalendarHelper.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RKCalendarHelper)

- (NSString *)amPmTimeStampString;      // 1y 3m 2d 2h

- (NSString *)weekdayMonthDayString;    // Wednesday, 12 December

- (BOOL)isToday;

- (BOOL)isYesterday;

- (BOOL)isTomorrow;

- (NSDate *)dateByAddingDays:(NSInteger)addedDays;

@end
