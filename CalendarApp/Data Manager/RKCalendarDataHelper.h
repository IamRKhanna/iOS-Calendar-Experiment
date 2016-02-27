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
 *  Purpose of this class is to provide class level helper methods for NSDate related operations
 */
@interface RKCalendarDataHelper : NSObject

/**
 *  Method to fetch the calendar to be used
 *
 *  @return NSCalendar to be used for all calendar related operations
 */
+ (NSCalendar *)calendar;

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
+ (NSDate *)dateByAddingYears:(NSInteger)years months:(NSInteger)months days:(NSInteger)days toDate:(NSDate *)inputDate;

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

/**
 *  Method to fetch date at the end of a year
 *
 *  @param year Year for which the end date is required
 *
 *  @return NSDate at the end of the given year
 */
+ (NSDate *)dateAtEndOfYear:(NSUInteger )year;

/**
 *  Method to get date on the first day of the week for the given date
 *
 *  @param date Date for which the first day of the week is needed
 *
 *  @return Date on the first day of the week for the given date
 */
+ (NSDate *)weekFirstDate:(NSDate *)date;

/**
 *  Method to get date on the last day of the week for the given date
 *
 *  @param date Date for which the last day of the week is needed
 *
 *  @return Date on the last day of the week for the given date
 */
+ (NSDate *)weekLastDate:(NSDate *)date;

/**
 *  Method to get number of days between two dates
 *
 *  @param beginDate Begin date
 *  @param endDate   End date
 *
 *  @return  Number of days between begin and end date
 */
+ (NSInteger)daysBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate;

/**
 *  Method to returns a bool if a given year is the current year
 *
 *  @param year Year value
 *
 *  @return YES, if given year is the current year, else NO
 */
+ (BOOL)isYearThisYear:(NSInteger)year;

/**
 *  Method to check if two dates are the same
 *
 *  @param date1 Date 1
 *  @param date2 Date 2
 *
 *  @return YES, if both dates are same, otherwise NO
 */
+ (BOOL)isdate:(NSDate *)date1 sameAsDate:(NSDate *)date2;

/**
 *  Method to fetch first date of the month to which the given date belongs
 *
 *  @param date Date for which the month's first date is needed
 *
 *  @return First date of the month for the given date
 */
+ (NSDate *)monthFirstDate:(NSDate *)date;

@end
