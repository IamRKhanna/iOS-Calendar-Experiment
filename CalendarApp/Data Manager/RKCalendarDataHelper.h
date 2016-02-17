//
//  RKCalendarDataHelper.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/10/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RK_CALENDAR_AGENDA_DEFAULT_HISTORY_DURATION     -3       // No of months
#define RK_CALENDAR_AGENDA_DEFAULT_FUTURE_DURATION      12      // No of months
#define RK_CALENDAR_DEFAULT_START_YEAR                  2010    // Reference taken from Outlook iOS App
#define RK_CALENDAR_DEFAULT_END_YEAR                    2020    // Reference taken from Outlook iOS App

/**
 *  Key to check whether user has granted permission
 */
extern NSString * const RKCalendarAccessPermissionGrantedKey;

/**
 *  Purpose of this class is to provide class level helper methods for NSDate related operations
 */
@interface RKCalendarDataHelper : NSObject

/**
 *  Method to filter the time component of a date setting time at 00:00 so as to get a beginning refernce of the date
 *
 *  @param inputDate Input date for which beginning date is needed
 *
 *  @return NSDate with reseted time component
 */
+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;


/**
 *  Method to get a date by adding years, months, to a given date
 *
 *  @param numberOfYears Number of years to be added
 *  @param months        Number of months to be added
 *  @param inputDate     Date to which years/months are to be added
 *
 *  @return New NSDate
 */
+ (NSDate *)dateByAddingYears:(NSInteger)numberOfYears months:(NSInteger)months toDate:(NSDate *)inputDate;

/**
 *  Method to fetch a string representing time difference between two dates in the form of "1y 1M 1d 1h 1m"
 *
 *  @param startDate Start date
 *  @param endDate   End date
 *
 *  @return String with time difference between the dates
 */
+ (NSString *)stringForTimeDifferenceBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate;

/**
 *  Method to fetch date at the beginning of a year
 *
 *  @param year Year for which the beginning date is required
 *
 *  @return NSDate at the start of the given year
 */
+ (NSDate *)dateAtBeginningOfYear:(NSUInteger )year;

@end
