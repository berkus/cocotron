/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
                 2009 Markus Hitter <mah@jump-ing.de>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSTask.h>
#import <Foundation/NSPlatform.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSFileManager.h>

NSString *NSTaskDidTerminateNotification=@"NSTaskDidTerminateNotification";

@implementation NSTask

+allocWithZone:(NSZone *)zone {
   if(self==[NSTask class])
    return NSAllocateObject([[NSPlatform currentPlatform] taskClass],0,zone);
   else
    return NSAllocateObject(self,0,zone);
}

+(NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments {
   NSTask *task=[[NSTask new] autorelease];
   [task setLaunchPath:path];
   [task setArguments:arguments];
   [task launch];
   return task;
}

-init {
   self=[super init];
   if(self!=nil){
    launchPath=nil;
    arguments=nil;
    currentDirectoryPath=[[[NSFileManager defaultManager] currentDirectoryPath] copy];
    standardInput=nil;
    standardOutput=nil;
    standardError=nil;
    isRunning=NO;
   } 
   return self;
}

-(void)dealloc {
  [launchPath release];
  [arguments release];
  [currentDirectoryPath release];
  [standardInput release];
  [standardOutput release];
  [standardError release];
  [super dealloc];
}

-(NSString *)currentDirectoryPath {
   return currentDirectoryPath;
}

-(NSString *)launchPath {
   return launchPath;
}

-(NSArray *)arguments {
   return arguments;
}

-(NSDictionary *)environment {
   NSInvalidAbstractInvocation();
   return nil;
}

-(id)standardError {
   return standardError;
}

-(id)standardInput {
   return standardInput;
}

-(id)standardOutput {
   return standardOutput;
}

-(void)setCurrentDirectoryPath:(NSString *)path {
   [currentDirectoryPath autorelease];
   currentDirectoryPath=[path copy];
}

-(void)setLaunchPath:(NSString *)path {
   [launchPath autorelease];
   launchPath=[path copy];
}

-(void)setArguments:(NSArray *)args {
   [arguments autorelease];
   arguments=[args copy];
}

-(void)setEnvironment:(NSDictionary *)values {
   NSInvalidAbstractInvocation();
}

-(void)setStandardInput:(id)input {
   [standardInput autorelease];
   standardInput=[input retain];
}

-(void)setStandardOutput:(id)output {
   [standardOutput autorelease];
   standardOutput=[output retain];
}

-(void)setStandardError:(id)error {
   [standardError autorelease];
   standardError=[error retain];
}

-(void)launch {
   NSInvalidAbstractInvocation();
}

-(BOOL)isRunning {
   return isRunning;
}

-(void)interrupt {
   NSInvalidAbstractInvocation();
}

-(BOOL)suspend {
   NSInvalidAbstractInvocation();
   return NO;
}

-(BOOL)resume {
   NSInvalidAbstractInvocation();
   return NO;
}

-(void)terminate {
   NSInvalidAbstractInvocation();
}

-(int)terminationStatus {
   NSInvalidAbstractInvocation();
   return -1;
}

-(void)waitUntilExit {
   while(isRunning)
     [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode 
                              beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
}

-(int)processIdentifier {
   NSInvalidAbstractInvocation();
   return -1;
}

@end
