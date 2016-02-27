//
//  RKCalendarDataHelper.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/10/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarDataHelper.h"

@implementation RKCalendarDataHelper

+ (NSCalendar *)calendar {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    [calendar setTimeZone:timeZone];
    
    return calendar;
}

+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate {
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [RKCalendarDataHelper calendar];
    
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

+ (NSDate *)dateByAddingYears:(NSInteger)years months:(NSInteger)months days:(NSInteger)days toDate:(NSDate *)inputDate {
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [RKCalendarDataHelper calendar];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:years];
    [dateComponents setMonth:months];
    [dateComponents setDay:days];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:inputDate options:0];
    return newDate;
}

+ (NSDate *)dateByAddingHours:(NSInteger)hours toDate:(NSDate *)inputDate {
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [RKCalendarDataHelper calendar];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setHour:hours];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:inputDate options:0];
    return newDate;
}

+ (NSString *)stringForTimeDifferenceBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate {
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [RKCalendarDataHelper calendar];
    
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    
    return [formatter dateFromString:[NSString stringWithFormat:@"%ld", year]];
}

+ (NSDate *)dateAtEndOfYear:(NSUInteger )year {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MM yyyy"];
    
    return [formatter dateFromString:[NSString stringWithFormat:@"31 12 %ld", year]];
}

+ (NSDate *)weekFirstDate:(NSDate *)date {
    NSCalendar *calendar = [RKCalendarDataHelper calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = components.weekday;
    
    //1 for Sunday
    if (weekday == 1) {
        return date;
    } else {
        return [RKCalendarDataHelper dateByAddingYears:0 months:0 days:(1-weekday) toDate:date];
    }
}

+ (NSDate *)weekLastDate:(NSDate *)date {
    NSCalendar *calendar = [RKCalendarDataHelper calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = components.weekday;
    //1 for Sunday
    if (weekday == 7) { //7 for Saturday
        return date;
    } else {
        return [RKCalendarDataHelper dateByAddingYears:0 months:0 days:(7 - weekday) toDate:date];
    }
}

+ (NSInteger)daysBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate {
    NSDateComponents *components = [[RKCalendarDataHelper calendar] components:NSCalendarUnitDay fromDate:beginDate toDate:endDate options:0];
    return components.day;
}

+ (BOOL)isYearThisYear:(NSInteger)year {
    NSDateComponents *components = [[RKCalendarDataHelper calendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    return components.year == year;
}

+ (BOOL)isdate:(NSDate *)date1 sameAsDate:(NSDate *)date2 {
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSCalendar *calendar = [RKCalendarDataHelper calendar];
    
    return [calendar isDate:date1 equalToDate:date2 toUnitGranularity:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];
}

+ (NSDate *)monthFirstDate:(NSDate *)date
{
    NSCalendar *calendar = [RKCalendarDataHelper calendar];

    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDateComponents *result = [[NSDateComponents alloc] init];
    [result setDay:1];
    [result setMonth:[components month]];
    [result setYear:[components year]];
    [result setHour:12];
    [result setMinute:0];
    [result setSecond:0];
    
    return [calendar dateFromComponents:result];
}
@end