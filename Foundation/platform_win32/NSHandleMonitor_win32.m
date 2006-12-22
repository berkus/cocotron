/* Copyright (c) 2006 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSHandleMonitor_win32.h>
#import <Foundation/NSRunLoop-InputSource.h>
#import <Foundation/NSString.h>

#import <windows.h>

@implementation NSHandleMonitor_win32

+(NSHandleMonitor_win32 *)handleMonitorWithHandle:(void *)handle {
   return [[[self allocWithZone:NULL] initWithHandle:handle] autorelease];
}

-initWithHandle:(void *)handle {
   _handle=handle;
   return self;
}

-(void *)handle {
   return _handle;
}

-(void)setDelegate:delegate {
   _delegate=delegate;
}

-(void)setCurrentActivity:(unsigned)activity {
   _currentActivity=activity;
}

-(void)notifyDelegateOfCurrentActivity {

   if(_currentActivity==Win32HandleSignaled)
    [_delegate handleMonitorIndicatesSignaled:self];

   if(_currentActivity==Win32HandleAbandoned)
    [_delegate handleMonitorIndicatesAbandoned:self];
}

@end
