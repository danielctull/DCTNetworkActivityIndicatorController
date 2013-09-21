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
NSString *const DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountIncreasedNotification = @"DCTConnectionQueueActiveConnectionCountIncreasedNotification";
NSString *const DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountDecreasedNotification = @"DCTConnectionQueueActiveConnectionCountDecreasedNotification";

NSString *const DCTNetworkActivityIndicatorControllerNetworkActivityKey = @"networkActivity";
NSString *const DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification = @"DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification";

static DCTNetworkActivityIndicatorController *sharedInstance = nil;

@implementation DCTNetworkActivityIndicatorController {
	__strong NSOperationQueue *_operationQueue;
}

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
    
	_networkActivity = 0;
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(incrementNetworkActivity) name:DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountIncreasedNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(decrementNetworkActivity) name:DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountDecreasedNotification object:nil];
	_operationQueue = [NSOperationQueue new];
	[_operationQueue setMaxConcurrentOperationCount:1];
	[_operationQueue setName:@"uk.co.danieltull.DCTNetworkActivityIndicatorController"];
	
	return self;
}

- (void)dealloc {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountIncreasedNotification object:nil];
	[notificationCenter removeObserver:self name:DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountDecreasedNotification object:nil];
}

- (void)decrementNetworkActivity {
	
	[_operationQueue addOperationWithBlock:^{
		NSAssert((self.networkActivity > 0), @"%@ increment/decrement calls mismatch", self);
		[self willChangeValueForKey:DCTNetworkActivityIndicatorControllerNetworkActivityKey];
		_networkActivity--;
		[self didChangeValueForKey:DCTNetworkActivityIndicatorControllerNetworkActivityKey];
	
		[self _calculateNetworkActivity];
	}];
}

- (void)incrementNetworkActivity {
	[_operationQueue addOperationWithBlock:^{
		[self willChangeValueForKey:DCTNetworkActivityIndicatorControllerNetworkActivityKey];
		_networkActivity++;
		[self didChangeValueForKey:DCTNetworkActivityIndicatorControllerNetworkActivityKey];
	
		[self _calculateNetworkActivity];
	}];
}

- (void)_calculateNetworkActivity {
	[[NSNotificationCenter defaultCenter] postNotificationName:DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification object:self];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(self.networkActivity > 0)];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p; networkActivity = %@>", NSStringFromClass([self class]), self, @(self.networkActivity)];
}

@end
