//
//  RKAppDelegate.h
//  CalendarApp
//
//  Created by Rahul Khanna on 2/10/16.
//  Copyright © 2016 Rahul Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Helper Methods
+ (UIViewController *)rootViewController;

@end

