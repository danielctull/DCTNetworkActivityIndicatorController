//
//  DCTNetworkActivityIndicatorController.m
//  DCTConnectionController
//
//  Created by Daniel Tull on 07.08.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCTNetworkActivityIndicatorController.h"

// These tie to DCTConnectionQueue
NSString *const DCTInternal_NetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountIncreasedNotification = @"DCTConnectionQueueActiveConnectionCountIncreasedNotification";
NSString *const DCTInternal_NetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountDecreasedNotification = @"DCTConnectionQueueActiveConnectionCountDecreasedNotification";

NSString *const DCTInternal_NetworkActivityIndicatorControllerNetworkActivityKey = @"networkActivity";

NSString *const DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification = @"DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification";

static DCTNetworkActivityIndicatorController *sharedInstance = nil;

@interface DCTNetworkActivityIndicatorController ()
- (void)dctInternal_calculateNetworkActivity;
@end

@implementation DCTNetworkActivityIndicatorController

@synthesize networkActivity;

+ (void)load {
	
	@autoreleasepool {
	    [DCTNetworkActivityIndicatorController sharedNetworkActivityIndicatorController];
	}
}

+ (DCTNetworkActivityIndicatorController *)sharedNetworkActivityIndicatorController {
	
	static dispatch_once_t sharedToken;
	dispatch_once(&sharedToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
    return sharedInstance;
}

- (id)init {
    
    if (!(self = [super init])) return nil;
    
	networkActivity = 0;
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(incrementNetworkActivity) name:DCTInternal_NetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountIncreasedNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(decrementNetworkActivity) name:DCTInternal_NetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountDecreasedNotification object:nil];
	
	return self;
}

- (void)dealloc {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter removeObserver:self name:DCTInternal_NetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountIncreasedNotification object:nil];
	[notificationCenter removeObserver:self name:DCTInternal_NetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountDecreasedNotification object:nil];
}

- (void)decrementNetworkActivity {
	
	dispatch_async(dispatch_get_main_queue(), ^{
		NSAssert((networkActivity > 0), @"%@ increment/decrement calls mismatch", self);
		[self willChangeValueForKey:DCTInternal_NetworkActivityIndicatorControllerNetworkActivityKey];
		networkActivity--;
		[self didChangeValueForKey:DCTInternal_NetworkActivityIndicatorControllerNetworkActivityKey];
	
		[self dctInternal_calculateNetworkActivity];
	});
}

- (void)incrementNetworkActivity {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self willChangeValueForKey:DCTInternal_NetworkActivityIndicatorControllerNetworkActivityKey];
		networkActivity++;
		[self didChangeValueForKey:DCTInternal_NetworkActivityIndicatorControllerNetworkActivityKey];
	
		[self dctInternal_calculateNetworkActivity];
	});
}

- (void)dctInternal_calculateNetworkActivity {
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification object:self];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(networkActivity > 0)];
	});
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p; networkActivity = %i>", NSStringFromClass([self class]), self, self.networkActivity];
}

@end
