//
//  RKCalendarDataHelper.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/10/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>


#define RK_CALENDAR_ONE_DAY_DURATION            60*60*24
#define RK_CALENDAR_DEFAULT_HISTORY_DURATION    3       // No of months
#define RK_CALENDAR_DEFAULT_FUTURE_DURATION     12      // No of months
#define RK_CALENDAR_DEFAULT_START_YEAR          2010    // Reference taken from Outlook iOS App
#define RK_CALENDAR_DEFAULT_END_YEAR            2020

extern NSString * const RKCalendarAccessPermissionGrantedKey;


@interface RKCalendarDataHelper : NSObject

+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

+ (NSDate *)dateByAddingYears:(NSInteger)numberOfYears months:(NSInteger)months toDate:(NSDate *)inputDate;

+ (NSString *)stringForTimeDifferenceBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

+ (NSUInteger )numberOfDaysBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

+ (NSDate *)dateAtBeginningOfYear:(NSUInteger )year;

@end
