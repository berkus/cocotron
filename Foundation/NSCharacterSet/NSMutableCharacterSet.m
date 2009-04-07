/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSMutableCharacterSet.h>
#import <Foundation/NSRaise.h>
#import "NSMutableCharacterSet_bitmap.h"

@implementation NSMutableCharacterSet

+allocWithZone:(NSZone *)zone {
   if(self==objc_lookUpClass("NSMutableCharacterSet"))
    return NSAllocateObject(objc_lookUpClass("NSMutableCharacterSet_bitmap"),0,zone);

   return NSAllocateObject(self,0,zone);
}

+characterSetWithBitmapRepresentation:(NSData *)data {
   return [[[NSMutableCharacterSet_bitmap alloc] initWithData:data] autorelease];
}

+characterSetWithCharactersInString:(NSString *)string {
   return [[[NSMutableCharacterSet_bitmap alloc] initWithString:string] autorelease];
}

+characterSetWithRange:(NSRange)range {
   return [[[NSMutableCharacterSet_bitmap alloc] initWithRange:range] autorelease];
}

-(void)addCharactersInString:(NSString *)string {
   NSInvalidAbstractInvocation();
}

-(void)addCharactersInRange:(NSRange)range {
   NSInvalidAbstractInvocation();
}

-(void)formUnionWithCharacterSet:(NSCharacterSet *)set {
   NSInvalidAbstractInvocation();
}

-(void)removeCharactersInString:(NSString *)string {
   NSInvalidAbstractInvocation();
}

-(void)removeCharactersInRange:(NSRange)range {
   NSInvalidAbstractInvocation();
}

-(void)formIntersectionWithCharacterSet:(NSCharacterSet *)set {
   NSInvalidAbstractInvocation();
}

-(void)invert {
   NSInvalidAbstractInvocation();
}

@end
