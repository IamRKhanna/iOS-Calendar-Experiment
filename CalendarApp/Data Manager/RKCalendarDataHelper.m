//
//  RKCalendarDataHelper.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/10/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarDataHelper.h"

NSString * const RKCalendarAccessPermissionGrantedKey = @"RKCalendarAccessPermissionGrantedKey";


@implementation RKCalendarDataHelper

+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inputDate];
    
    // Set the time components manually
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComponents];
    return beginningOfDay;
}

+ (NSDate *)dateByAddingYears:(NSInteger)numberOfYears months:(NSInteger)numberOfMonths toDate:(NSDate *)inputDate
{
    // Use the user's current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:numberOfYears];
    [dateComponents setMonth:numberOfMonths];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:inputDate options:0];
    return newDate;
}

+ (NSString *)stringForTimeDifferenceBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute
                                                   fromDate:startDate
                                                     toDate:endDate
                                                    options:0];
    
    NSMutableString *durationString = [NSMutableString string];
    
    if (dateComponents.year) {
        [durationString appendFormat:@"%ldy ", (long)dateComponents.year];
    }
    if (dateComponents.month) {
        [durationString appendFormat:@"%ldM ", (long)dateComponents.month];
    }
    if (dateComponents.day) {
        [durationString appendFormat:@"%ldd ", (long)dateComponents.day];
    }
    if (dateComponents.hour) {
        [durationString appendFormat:@"%ldh ", (long)dateComponents.hour];
    }
    if (dateComponents.minute) {
        [durationString appendFormat:@"%ldm", (long)dateComponents.minute];
    }
    
    return durationString;
}

+ (NSDate *)dateAtBeginningOfYear:(NSUInteger )year {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    [calendar setTimeZone:timeZone];
    
    return  [calendar dateWithEra:0
                             year:year
                            month:0
                              day:0
                             hour:0
                           minute:0
                           second:0
                       nanosecond:0];
}

@end