//
//  RKAgendaTableViewSectionHeaderView.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/12/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKAgendaTableViewSectionHeaderView : UITableViewHeaderFooterView

/**
 *  Date for this section
 */
@property (nonatomic, strong) NSDate *sectionDate;

/**
 *  IBOutlet for dateLabel
 */
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

/**
 *  Method to get the reuse identifier
 *
 *  @return Reuse Identifier String
 */
+ (NSString *)reuseIdentifier;

@end
