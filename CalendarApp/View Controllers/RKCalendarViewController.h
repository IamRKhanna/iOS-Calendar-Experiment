//
//  RKCalendarViewController.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKCalendarViewController : UIViewController

// Agenda table view helper methods
- (void)scrollAgendaTableViewToDate:(NSDate *)date;
@end
