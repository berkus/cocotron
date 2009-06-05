/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSTask_win32.h>
#import <Foundation/NSFileHandle_win32.h>
#import <Foundation/NSHandleMonitor_win32.h>
#import <Foundation/NSRunLoop-InputSource.h>
#import <Foundation/NSString_win32.h>
#import <Foundation/NSPlatform_win32.h>
#import <windows.h>
#import <Foundation/NSPropertyListWriter_vintage.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSString.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSPipe.h>
#import <Foundation/NSPathUtilities.h>

@implementation NSTask_win32

-(NSData *)_argumentsData {
   NSMutableData *data=[NSMutableData data];
   NSInteger            i,count=[arguments count];

   [data appendData:NSTaskArgumentDataFromString(launchPath)];
   [data appendBytes:" " length:1];

   for(i=0;i<count;i++){
    NSString *argument=[arguments objectAtIndex:i];

    [data appendData:NSTaskArgumentDataFromString(argument)];
    [data appendBytes:" " length:1];
    
    if ([data length] > 32767){
     [NSException raise:NSInvalidArgumentException format:@"More than 32768 bytes needed for argument list of task %@.", launchPath];
     return nil;
    }
   }

   [data appendBytes:"\0" length:1];

   return data;
}

-(void)launch {
   STARTUPINFO   startupInfo;

   if(launchPath==nil)
    [NSException raise:NSInvalidArgumentException
                format:@"NSTask launchPath is nil"];

   ZeroMemory(&startupInfo,sizeof(startupInfo));
   startupInfo.cb=sizeof(startupInfo);
   startupInfo.dwFlags=STARTF_USESTDHANDLES;

   if(standardInput==nil)
    startupInfo.hStdInput=GetStdHandle(STD_INPUT_HANDLE);
   else if([standardInput isKindOfClass:[NSPipe class]])
    startupInfo.hStdInput=[(NSFileHandle_win32 *)[standardInput fileHandleForReading] fileHandle];
   else
    startupInfo.hStdInput=[standardInput fileHandle];

   if(standardOutput==nil)
    startupInfo.hStdOutput=GetStdHandle(STD_OUTPUT_HANDLE);
   else if([standardOutput isKindOfClass:[NSPipe class]])
    startupInfo.hStdOutput=[(NSFileHandle_win32 *)[standardOutput fileHandleForWriting] fileHandle];
   else
    startupInfo.hStdOutput=[standardOutput fileHandle];

   if(standardError==nil)
     startupInfo.hStdError=GetStdHandle(STD_ERROR_HANDLE);
   else if([standardError isKindOfClass:[NSPipe class]])
    startupInfo.hStdError=[(NSFileHandle_win32 *)[standardError fileHandleForWriting] fileHandle];
   else
    startupInfo.hStdError=[standardError fileHandle];

   ZeroMemory(& _processInfo,sizeof(_processInfo));

   if(!CreateProcess([[self launchPath] fileSystemRepresentation],
    (char *)[[self _argumentsData] bytes],
    NULL,NULL,TRUE,CREATE_NO_WINDOW,NULL,
    [currentDirectoryPath fileSystemRepresentation],
    &startupInfo,&_processInfo)){
    [NSException raise:NSInvalidArgumentException
                format:@"CreateProcess(%@,%@,%@) failed", launchPath,[arguments componentsJoinedByString:@" "], currentDirectoryPath];
    return;
   }

   if([standardInput isKindOfClass:[NSPipe class]])
    [[standardInput fileHandleForReading] closeFile];
   if([standardOutput isKindOfClass:[NSPipe class]])
    [[standardOutput fileHandleForWriting] closeFile];
   if([standardError isKindOfClass:[NSPipe class]])
    [[standardError fileHandleForWriting] closeFile];

   isRunning=YES;
   _monitor=[[NSHandleMonitor_win32 allocWithZone:NULL] initWithHandle:_processInfo.hProcess];
   [_monitor setDelegate:self];
   [[NSRunLoop currentRunLoop] addInputSource:_monitor forMode: NSDefaultRunLoopMode];
}

-(void)terminate {
   TerminateProcess(_processInfo.hProcess,0);
   Win32Assert("TerminateProcess");
}

-(void)handleMonitorIndicatesSignaled:(NSHandleMonitor_win32 *)monitor {
   GetExitCodeProcess(_processInfo.hProcess,&_exitCode);

   if(_exitCode!=STILL_ACTIVE){
    NSNotification *note=[NSNotification notificationWithName: NSTaskDidTerminateNotification object:self];

    isRunning=NO;

    [[NSRunLoop currentRunLoop] removeInputSource:_monitor forMode: NSDefaultRunLoopMode];
    [_monitor setDelegate:nil];
    [_monitor autorelease];
    _monitor=nil;

    CloseHandle(_processInfo.hProcess);
    CloseHandle(_processInfo.hThread);

    [[NSNotificationCenter defaultCenter] postNotification:note];
   }
}

-(void)handleMonitorIndicatesAbandoned:(NSHandleMonitor_win32 *)monitor {
   NSLog(@"process abandoned ?");
}

-(int)processIdentifier {
   return _processInfo.dwProcessId;
}

@end
