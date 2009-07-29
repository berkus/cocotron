/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>

@class NSView;

enum {
   NSTrackingMouseEnteredAndExited   =(1<<0),
   NSTrackingMouseMoved              =(1<<1),
   NSTrackingCursorUpdate            =(1<<2),
   
   NSTrackingActiveWhenFirstResponder=(1<<4),
   NSTrackingActiveInKeyWindow       =(1<<5),
   NSTrackingActiveInActiveApp       =(1<<6),
   NSTrackingActiveAlways            =(1<<7),
   
   NSTrackingAssumeInside            =(1<<8),
   NSTrackingInVisibleRect           =(1<<9),
   NSTrackingEnabledDuringMouseDrag  =(1<<10),
};


@interface NSTrackingArea : NSObject {
   NSRect  _rect;
   NSView *_view;
   BOOL    _isFlipped;
   BOOL    _isToolTip;
   id      _owner;
   void   *_userData;
   BOOL    _mouseInside;
   int     _tag;
}

-initWithRect:(NSRect)rect view:(NSView *)view flipped:(BOOL)flipped owner:owner
   userData:(void *)userData assumeInside:(BOOL)assumeInside
   isToolTip:(BOOL)isToolTip;

-(NSView *)view;

-(int)tag;
-(void)setTag:(int)tag;

-(NSRect)rect;
-(BOOL)isFlipped;
-(BOOL)isToolTip;

-owner;
-(void *)userData;
-(BOOL)mouseInside;
-(void)setMouseInside:(BOOL)inside;

@end
