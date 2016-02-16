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
@property (nonatomic, strong) NSDictionary<NSDate *, NSArray<EKEvent *> *> *eventsDictionary;
@property (nonatomic, strong) NSArray<NSDate *> *sortedEventsDaysArray;

@property (nonatomic, assign) BOOL isEventsDataReady;

@property (nonatomic, assign) BOOL accessToCalendarGranted;


// Methods Declaration
+ (instancetype)sharedInstance;

- (void)updateCalendarAccessPermissions;

- (NSDate *)startDateForCalendarView;

- (NSDate *)endDateForCalendarView;

- (BOOL) doesEventExistForDate:(NSDate *)date;

- (NSUInteger)indexForEventNearestToDate:(NSDate *)date;

@end