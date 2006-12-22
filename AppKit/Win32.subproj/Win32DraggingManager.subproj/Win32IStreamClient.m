/* Copyright (c) 2006 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <AppKit/Win32IStreamClient.h>

@implementation Win32IStreamClient

-initWithIStream:(IStream *)stream release:(BOOL)release {
   _stream=stream;
   _release=release;
   return self;
}

-(void)dealloc {
   if(_release){
    if(_stream->lpVtbl->Release(_stream)!=S_OK){
     NSLog(@"_stream->lpVtbl->Release failed");
    }
   }
   [super dealloc];
}

-(NSData *)readDataToEndOfFile {
   NSMutableData *result;
   STATSTG  statStorage;
   ULONG    amountRead=0;

   if(_stream->lpVtbl->Stat(_stream,&statStorage,STATFLAG_NONAME)!=S_OK){
    NSLog(@"_stream->lpVtbl->Stat failed");
    return nil;
   }

   result=[NSMutableData dataWithCapacity: statStorage.cbSize.QuadPart];
   [result setLength:statStorage.cbSize.QuadPart];

   if(_stream->lpVtbl->Read(_stream,[result mutableBytes], statStorage.cbSize.QuadPart,
     &amountRead)!=S_OK){
    NSLog(@"_stream->lpVtbl->Read failed");
    return nil;
   }

   [result setLength:amountRead];

   return result;
}

@end
