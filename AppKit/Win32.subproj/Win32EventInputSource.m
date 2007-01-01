/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <AppKit/Win32EventInputSource.h>
#import <AppKit/Win32Display.h>
#import <AppKit/NSEvent_periodic.h>

@implementation Win32EventInputSource

-(BOOL)canProcessImmediateInput {
   return YES;
}

-(NSDate *)limitDateForMode:(NSString *)mode {
   return [NSDate distantFuture];
}

/* We only post periodic events if there are no other normal events, otherwise
   an long event handling can constantly only generate periodics
 */
-(BOOL)processInputImmediately {
   BOOL hadPeriodic=[[Win32Display currentDisplay] containsAndRemovePeriodicEvents];
   MSG  msg;

   if([[Win32Display currentDisplay] hasEventsMatchingMask])
    return YES;

   if(PeekMessage(&msg,NULL,0,0,PM_REMOVE)){
    NSAutoreleasePool *pool=[NSAutoreleasePool new];

    if(![[Win32Display currentDisplay] postMSG:msg])
     DispatchMessage(&msg);

    [pool release];
    return YES;
   }

   if(hadPeriodic){
    NSEvent *event=[[[NSEvent_periodic alloc] initWithType:NSPeriodic location:NSMakePoint(0,0) modifierFlags:0 window:nil] autorelease];

    [[Win32Display currentDisplay] postEvent:event atStart:NO];
   }

   return NO;
}

-(unsigned)waitForEventsAndMultipleObjects:(HANDLE *)objects count:(unsigned)count milliseconds:(DWORD)milliseconds {
   if(count==0){
    UINT timer=SetTimer(NULL,0,milliseconds,NULL);

    WaitMessage();

    KillTimer(NULL,timer);
    return WAIT_TIMEOUT;
   }

   return MsgWaitForMultipleObjects(count,objects,FALSE,milliseconds,QS_ALLINPUT);
}


@end
