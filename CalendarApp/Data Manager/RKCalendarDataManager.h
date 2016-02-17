//
//  RKCalendarDataManager.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/10/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

extern NSString * const RKCalendarDataManagerDidUpdateEventsNotification;

@interface RKCalendarDataManager : NSObject

// Property Declaration
/**
 *  Dictionary containing all events for this user
 */
@property (nonatomic, strong) NSDictionary<NSDate *, NSArray<EKEvent *> *> *eventsDictionary;

/**
 *  Array containing sorted list of events
 */
@property (nonatomic, strong) NSArray<NSDate *> *sortedEventsDaysArray;

/**
 *  BOOL to check if user data is fetched and ready to be consumed by the app
 */
@property (nonatomic, assign) BOOL isEventsDataReady;

/**
 *  BOOL to check if access to calendars is granted or not
 */
@property (nonatomic, assign) BOOL accessToCalendarGranted;


// Methods Declaration

+ (instancetype)sharedInstance;

/**
 *  Method that will upate calendar access permissions
 */
- (void)updateCalendarAccessPermissions;

/**
 *  Start date for Calendar View
 *
 *  @return Start Date
 */
- (NSDate *)startDateForCalendarView;

/**
 *  End date for calendar view
 *
 *  @return End Date
 */
- (NSDate *)endDateForCalendarView;

/**
 *  Checks from sorted events list if an event exists for give NSDate
 *
 *  @param date Date for which check is to be made
 *
 *  @return BOOL to indicate whether even exist
 */
- (BOOL) doesEventExistForDate:(NSDate *)date;

/**
 *  Method to fetch Section index nearest/at for this date. This methods checks whether an event exists at the given day.
 *  If an event exists, the index is returned
 *  If no event exists, this method finds the nearest future event (unless there are no more events left in future in which case it will send last event)
 *
 *  @param date Date for which nearest section index is demanded
 *
 *  @return Integer for the index
 */
- (NSUInteger)sectionIndexForEventNearestToDate:(NSDate *)date;

@end