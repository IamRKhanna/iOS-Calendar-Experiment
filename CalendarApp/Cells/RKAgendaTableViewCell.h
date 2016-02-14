//
//  RKAgendaTableViewCell.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>


@interface RKAgendaTableViewCell : UITableViewCell

@property (nonatomic, strong) EKEvent *event;


+ (NSString *)reuseIdentifier;

@end
