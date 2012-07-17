//
//  DCTNetworkActivityIndicatorController.h
//  DCTConnectionController
//
//  Created by Daniel Tull on 07.08.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef dctnetworkactivityindicatorcontroller
#define dctnetworkactivityindicatorcontroller_1_0       10000
#define dctnetworkactivityindicatorcontroller_1_0_1     10001
#define dctnetworkactivityindicatorcontroller_1_0_2     10002
#define dctnetworkactivityindicatorcontroller_1_0_3     10003
#define dctnetworkactivityindicatorcontroller_1_1		10100
#define dctnetworkactivityindicatorcontroller           dctnetworkactivityindicatorcontroller_1_1
#endif

extern NSString *const DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification;

@interface DCTNetworkActivityIndicatorController : NSObject

+ (DCTNetworkActivityIndicatorController *)sharedNetworkActivityIndicatorController;

@property (nonatomic, readonly) NSUInteger networkActivity;

- (void)decrementNetworkActivity;
- (void)incrementNetworkActivity;

@end
