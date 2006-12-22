/* Copyright (c) 2006 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSPipe_win32.h>
#import <Foundation/NSFileHandle_win32.h>

@implementation NSPipe_win32

-(NSFileHandle *)fileHandleForReading {
   return _fileHandleForReading;
}

-(NSFileHandle *)fileHandleForWriting {
   return _fileHandleForWriting;
}

-init {
   HANDLE readHandle,writeHandle;
   SECURITY_ATTRIBUTES sa;

   sa.nLength=sizeof(SECURITY_ATTRIBUTES);
   sa.lpSecurityDescriptor=NULL;
   sa.bInheritHandle=TRUE;

   if(!CreatePipe(&readHandle,&writeHandle,&sa,0)){
    [self dealloc];
    return nil;
   }

   _fileHandleForReading=[[NSFileHandle_win32 alloc] initWithHandle:readHandle closeOnDealloc:YES];
   _fileHandleForWriting=[[NSFileHandle_win32 alloc] initWithHandle:writeHandle closeOnDealloc:YES];

   return self;
}

-(void)dealloc {
   [_fileHandleForReading release];
   [_fileHandleForWriting release];
   [super dealloc];
}

@end
