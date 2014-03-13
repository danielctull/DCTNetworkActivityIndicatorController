//
//  DCTNetworkActivityIndicatorController.m
//  DCTConnectionController
//
//  Created by Daniel Tull on 07.08.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

@import UIKit;
#import "DCTNetworkActivityIndicatorController.h"

// These tie to DCTConnectionQueue
static NSString *const DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountIncreasedNotification = @"DCTConnectionQueueActiveConnectionCountIncreasedNotification";
static NSString *const DCTNetworkActivityIndicatorControllerConnectionQueueActiveConnectionCountDecreasedNotification = @"DCTConnectionQueueActiveConnectionCountDecreasedNotification";

NSString *const DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification = @"DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification";

@interface DCTNetworkActivityIndicatorController ()
@property (nonatomic) NSOperationQueue *operationQueue;
@property (nonatomic, readwrite) NSUInteger networkActivity;
@end

@implementation DCTNetworkActivityIndicatorController

#pragma mark - NSObject

+ (void)load {
	@autoreleasepool {
	    [DCTNetworkActivityIndicatorController sharedNetworkActivityIndicatorController];
	}
}

- (id)init {

	self = [super init];
	if (!self) return nil;

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

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p; networkActivity = %@>", NSStringFromClass([self class]), self, @(self.networkActivity)];
}

#pragma mark - DCTNetworkActivityIndicatorController

+ (instancetype)sharedNetworkActivityIndicatorController {

	static DCTNetworkActivityIndicatorController *sharedInstance;
	static dispatch_once_t sharedToken;
	dispatch_once(&sharedToken, ^{
		sharedInstance = [[self class] new];
	});
	
    return sharedInstance;
}

- (void)decrementNetworkActivity {
	[self.operationQueue addOperationWithBlock:^{
		NSAssert((self.networkActivity > 0), @"%@ increment/decrement calls mismatch", self);
		self.networkActivity--;
		[self calculateNetworkActivity];
	}];
}

- (void)incrementNetworkActivity {
	[self.operationQueue addOperationWithBlock:^{
		self.networkActivity++;
		[self calculateNetworkActivity];
	}];
}

#pragma mark - Internal

- (void)calculateNetworkActivity {
	[[NSNotificationCenter defaultCenter] postNotificationName:DCTNetworkActivityIndicatorControllerNetworkActivityChangedNotification object:self];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(self.networkActivity > 0)];
}

@end
