/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

@class NSTimeZone, NSThread, NSInputSource,NSInputSourceSet;

FOUNDATION_EXPORT NSString *NSPlatformExecutableFileExtension;
FOUNDATION_EXPORT NSString *NSPlatformLoadableObjectFileExtension;
FOUNDATION_EXPORT NSString *NSPlatformLoadableObjectFilePrefix;
FOUNDATION_EXPORT NSString *NSPlatformExecutableDirectory;
FOUNDATION_EXPORT NSString *NSPlatformResourceNameSuffix;

@interface NSPlatform : NSObject

+currentPlatform;

-(NSInputSource *)parentDeathInputSource;

-(Class)taskClass;
-(Class)pipeClass;
-(Class)lockClass;
-(Class)conditionLockClass;
-(Class)persistantDomainClass;

-(NSString *)userName;
-(NSString *)fullUserName;
-(NSString *)homeDirectory;
-(NSString *)temporaryDirectory;

-(NSArray *)arguments;
-(NSDictionary *)environment;

-(NSTimeZone *)systemTimeZone;

-(NSString *)hostName;

-(NSString *)DNSHostName;
-(NSArray *)addressesForDNSHostName:(NSString *)name;

-(void *)contentsOfFile:(NSString *)path length:(NSUInteger *)length;
-(void *)mapContentsOfFile:(NSString *)path length:(NSUInteger *)length;
-(void)unmapAddress:(void *)ptr length:(NSUInteger)length;

-(BOOL)writeContentsOfFile:(NSString *)path bytes:(const void *)bytes length:(NSUInteger)length atomically:(BOOL)atomically;

-(void)checkEnvironmentKey:(NSString *)key value:(NSString *)value;
@end

FOUNDATION_EXPORT int NSPlatformProcessID();
FOUNDATION_EXPORT NSUInteger NSPlatformThreadID();
FOUNDATION_EXPORT NSTimeInterval NSPlatformTimeIntervalSinceReferenceDate();
FOUNDATION_EXPORT void NSPlatformLogString(NSString *string);
FOUNDATION_EXPORT void NSPlatformSleepThreadForTimeInterval(NSTimeInterval interval);

// These functions are implemented in the platform subproject

NSThread *NSPlatformCurrentThread();
void NSPlatformSetCurrentThread(NSThread *thread);
#ifdef WINDOWS
NSUInteger NSPlatformDetachThread(unsigned (*__stdcall func)(void *arg), void *arg);
#else
NSUInteger NSPlatformDetachThread(void *(* func)(void *arg), void *arg);
#endif
