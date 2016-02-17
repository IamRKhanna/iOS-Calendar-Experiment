//
//  NSDate+RKCalendarHelper.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "NSDate+RKCalendarHelper.h"

@implementation NSDate (RKCalendarHelper)

- (NSString *)amPmTimeStampString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    return [formatter stringFromDate:self];
}

-(NSString *)weekdayMonthDayString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    
    return [formatter stringFromDate:self];
}

- (NSString *)monthYearString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM y"];
    
    return [formatter stringFromDate:self];
}

- (BOOL)isToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    return [calendar isDateInToday:self];
}

- (BOOL)isYesterday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    return [calendar isDateInYesterday:self];
}

- (BOOL)isTomorrow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    return [calendar isDateInTomorrow:self];
}

@end
