//
//  DCTNetworkActivityIndicatorController.h
//  DCTNetworkActivityIndicatorController
//
//  Created by Daniel Tull on 07.08.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

@import Foundation;
@import UIKit;

//! Project version number and string for DCTNetworkActivityIndicatorController.
FOUNDATION_EXPORT double DCTNetworkActivityIndicatorControllerVersionNumber;
FOUNDATION_EXPORT const unsigned char DCTNetworkActivityIndicatorControllerVersionString[];

/**
 *  This notification is posted when networkActivity has changed.
 */
extern NSString *const DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification;

/**
 *  Controls the network activity indicator.
 */
@interface DCTNetworkActivityIndicatorController : NSObject

/**
 *  Returns a single instance of the controller, that should be used to increment
 *  and decrement the activity.
 *
 *  @return Shared controller.
 */
+ (instancetype)sharedNetworkActivityIndicatorController;

/**
 *  The current count of network activity. This property is obserservable. 
 */
@property (nonatomic, readonly) NSUInteger networkActivity;

/**
 *  Call this when the networking is complete.
 */
- (void)decrementNetworkActivity;

/**
 *  Call this when the networking begins.
 */
- (void)incrementNetworkActivity;

@end
