//
//  RKCalendarDataManager.m
//  CalendarApp
//
//  Created by Rahul Khanna on 2/10/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import "RKCalendarDataManager.h"
#import "RKCalendarDataHelper.h"
#import "RKAppDelegate.h"


// Defining Notification Constants
NSString * const RKCalendarDataManagerDidUpdateEventsNotification = @"RKCalendarDataManagerDidUpdateEventsNotification";


@interface RKCalendarDataManager()

@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation RKCalendarDataManager

#pragma mark - Singleton Class Method

static  RKCalendarDataManager *sharedInstance = nil;
+ (instancetype)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[RKCalendarDataManager alloc] init];
        }
    }
    return sharedInstance;
}

#pragma mark - Initilization

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Custom initialization
        _eventStore = [[EKEventStore alloc] init];
        
        [self updateCalendarAccessPermissions];
    }
    
    return self;
}

- (void)updateCalendarAccessPermissions {
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError * _Nullable error) {
                                        self.accessToCalendarGranted = granted;
                                        
                                        if (self.accessToCalendarGranted && !self.isEventsDataReady) {
                                            [self updateEventsData];
                                        }
                                    }];
}

#pragma mark - Notification Observers

- (void)addNotificationObservers {
    // Add an observer to receive Calendar changes made in the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.eventStore];
}

- (void)removeNotificatonObservers {
    
    // Remove observer for calendar changes
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:EKEventStoreChangedNotification
                                                  object:self.eventStore];
    
}

- (void)eventStoreChanged:(NSNotification *)notification {
    
    // Refresh Events
    [self updateEventsData];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RKCalendarDataManagerDidUpdateEventsNotification
                                                        object:nil];
}

#pragma mark - Accessor methods

- (void)setAccessToCalendarGranted:(BOOL)accessToCalendarGranted {
    _accessToCalendarGranted = accessToCalendarGranted;
    
    // Store this data in user defaults
    [[NSUserDefaults standardUserDefaults] setBool:accessToCalendarGranted forKey:RKCalendarAccessPermissionGrantedKey];
}

#pragma mark - Calendar Dates
- (NSDate *)startDateForCalendarView {
    return [RKCalendarDataHelper dateAtBeginningOfYear:RK_CALENDAR_DEFAULT_START_YEAR];
}

- (NSDate *)endDateForCalendarView {
    return [RKCalendarDataHelper dateAtBeginningOfYear:RK_CALENDAR_DEFAULT_END_YEAR];
}

#pragma mark - Fetching Calendar Events

- (void)updateEventsData {
    self.isEventsDataReady = NO;
    
    // Get list of all events first
    NSArray<EKEvent *> *allEvents = [self fetchEventsFromEventStore];
    
    // Set the eventsDictionary property
    self.eventsDictionary = [self dictionaryWithDayWiseEventsForEventLits:allEvents];
    
    // Let's sort things by date
    self.sortedEventsDaysArray = [self sortedEventsDays];
    
    self.isEventsDataReady = YES;
}

- (NSArray<EKEvent *> *)fetchEventsFromEventStore {
    // First, let's just find today without clock information
    NSDate *today = [RKCalendarDataHelper dateAtBeginningOfDayForDate:[NSDate date]];
    
    // Let's figure out start and end dates
    NSDate *startDate = [RKCalendarDataHelper dateByAddingYears:0 months:RK_CALENDAR_AGENDA_DEFAULT_HISTORY_DURATION toDate:today];
    NSDate *endDate = [RKCalendarDataHelper dateByAddingYears:0 months:RK_CALENDAR_AGENDA_DEFAULT_FUTURE_DURATION toDate:today];
    
    // Fetch the events from Event store
    NSPredicate *searchPredicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    
    return [self.eventStore eventsMatchingPredicate:searchPredicate];
}


- (NSDictionary<NSDate *, NSArray<EKEvent *> *> *)dictionaryWithDayWiseEventsForEventLits:(NSArray<EKEvent *> *)eventsList {
    
    // Let's create a mutable dictionary to store all events day-wise
    NSMutableDictionary *mutableEventsDictionary = [NSMutableDictionary dictionary];
    
    // Iterate through all events
    [eventsList enumerateObjectsUsingBlock:^(EKEvent *obj, NSUInteger idx, BOOL *stop) {
        // Let's find out which day this event belongs to
        NSDate *beginningDateForThisEvent = [RKCalendarDataHelper dateAtBeginningOfDayForDate:obj.startDate];
        
        // Find out the array this event belongs to in the events dictionary. If not found, create a new entry of the array in the dictionary
        NSMutableArray *eventsOnThisDay = [mutableEventsDictionary objectForKey:beginningDateForThisEvent];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            
            // Since we created a new events array for this day, add it to events dictionary
            [mutableEventsDictionary setObject:eventsOnThisDay forKey:beginningDateForThisEvent];
        }
        
        // Add this event to array
        [eventsOnThisDay addObject:obj];
    }];
    
    return mutableEventsDictionary;
}

- (NSArray<NSDate *> *)sortedEventsDays {
    NSArray<NSDate *> *unsortedDays = [self.eventsDictionary allKeys];
    
    return [unsortedDays sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

#pragma mark - Event Information Helper Methods
- (BOOL)doesEventExistForDate:(NSDate *)date {
    // Find weekday info without timestamp
    NSDate *beginDate = [RKCalendarDataHelper dateAtBeginningOfDayForDate:date];

    return [self.sortedEventsDaysArray containsObject:beginDate];
}

- (NSUInteger)indexForEventNearestToDate:(NSDate *)date {
    // Find weekday info without timestamp
    NSDate *beginDate = [RKCalendarDataHelper dateAtBeginningOfDayForDate:date];
    
    NSUInteger index = [self.sortedEventsDaysArray indexOfObject:beginDate
                                inSortedRange:NSMakeRange(0, self.sortedEventsDaysArray.count-1)
                                      options:NSBinarySearchingInsertionIndex
                              usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                  return [obj1 compare:obj2];
                              }];
    
    return index;
}


#pragma mark - Dealloc
- (void)dealloc {
    
    // Rmeove notification observers
    [self removeNotificatonObservers];
}

@end
