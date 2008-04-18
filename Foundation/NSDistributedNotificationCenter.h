/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSNotificationCenter.h>

// FIXME: cleanup

typedef int NSNotificationSuspensionBehavior;

FOUNDATION_EXPORT NSString *NSLocalNotificationCenterType;

@interface NSDistributedNotificationCenter : NSNotificationCenter

+(NSDistributedNotificationCenter *)defaultCenter;

+(NSDistributedNotificationCenter *)notificationCenterForType:(NSString *)type;

-(BOOL)suspended;

-(void)setSuspended:(BOOL)value;

-(void)addObserver:observer selector:(SEL)selector name:(NSString *)name object:(NSString *)object;
-(void)addObserver:observer selector:(SEL)selector name:(NSString *)name object:(NSString *)object suspensionBehavior:(NSNotificationSuspensionBehavior)behavior;

-(void)removeObserver:observer name:(NSString *)name object:(NSString *)object;

-(void)postNotificationName:(NSString *)name object:(NSString *)object;
-(void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo;
-(void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo deliverImmediately:(BOOL)immediately;
-(void)postNotificationName:(NSString *)name object:(NSString *)object userInfo:(NSDictionary *)userInfo options:(NSUInteger)options;

@end
