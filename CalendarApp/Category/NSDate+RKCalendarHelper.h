//
//  NSDate+RKCalendarHelper.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RKCalendarHelper)

/**
 *  Method to get Time stamp string
 *
 *  @return Time Stamp string in the format of "h:mm a"
 */
- (NSString *)amPmTimeStampString; 

/**
 *  Method to get weekday, month and day string like "Wednesday, 12 December"
 *
 *  @return Weekday, month and day string in the format of "EEEE, MMMM d"
 */
- (NSString *)weekdayMonthDayString;

/**
 *  Month and year string of a date like "February 2016"
 *
 *  @return Month, year string in the format of MMMM y
 */
- (NSString *)monthYearString;

/**
 *  Method to check whether the date is today's date
 *
 *  @return BOOL value depicting whther the date is today
 */
- (BOOL)isToday;

/**
 *  Method to check whether the date is yesterday's date
 *
 *  @return BOOL value depicting whther the date is yesterday
 */
- (BOOL)isYesterday;

/**
 *  Method to check whether the date is tomorrow's date
 *
 *  @return BOOL value depicting whther the date is tomorrow
 */
- (BOOL)isTomorrow;

@end
