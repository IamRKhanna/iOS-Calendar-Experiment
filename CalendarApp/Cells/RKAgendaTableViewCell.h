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

/**
 *   The event for this cell
 */
@property (nonatomic, strong) EKEvent *event;


/**
 *  Method to get the reuse identifier
 *
 *  @return Reuse Identifier String
 */
+ (NSString *)reuseIdentifier;

@end
