/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSText.h>
#import <AppKit/NSGraphics.h>

@class NSFont,NSImage,NSView;

typedef enum {
   NSNullCellType,
   NSTextCellType,
   NSImageCellType
} NSCellType;

enum {
   NSAnyType=0,
   NSIntType=1,
   NSPositiveIntType=2,
   NSFloatType=3,
   NSPositiveFloatType=4,
   NSDoubleType=6,
   NSPositiveDoubleType=7
};

typedef enum {
   NSNoImage,
   NSImageOnly,
   NSImageLeft,
   NSImageRight,
   NSImageBelow,
   NSImageAbove,
   NSImageOverlaps
} NSCellImagePosition;

typedef enum {
   NSMixedState=-1,
   NSOffState=0,
   NSOnState=1,
} NSCellState;

typedef enum {
   NSRegularControlSize,
   NSSmallControlSize,
   NSMiniControlSize
} NSControlSize;

typedef NSUInteger NSControlTint;

@interface NSCell : NSObject <NSCopying,NSCoding> {
   int       _state;
   NSFont   *_font;
   int       _entryType;
   id        _objectValue;
   NSImage  *_image;
   int       _textAlignment;
   NSWritingDirection _writingDirection;
   int       _cellType;
   NSFormatter *_formatter;
   id        _titleOrAttributedTitle;
   id        _representedObject;
   NSControlSize _controlSize;
   NSFocusRingType _focusRingType;

   BOOL      _isEnabled;
   BOOL      _isEditable;
   BOOL      _isSelectable;
   BOOL      _isScrollable;
   BOOL      _wraps;
   BOOL      _isBordered;
   BOOL      _isBezeled;
   BOOL      _isHighlighted;
   BOOL      _refusesFirstResponder;
   BOOL	     _isContinuous;
   BOOL      _allowsMixedState;
   BOOL      _sendsActionOnEndEditing;
}

+(NSFocusRingType)defaultFocusRingType;

-initTextCell:(NSString *)string;
-initImageCell:(NSImage *)image;

-(NSView *)controlView;
-(NSCellType)type;
-(int)state;

-target;
-(SEL)action;
-(int)tag;
-(int)entryType;
-(id)formatter;
-(NSFont *)font;
-(NSImage *)image;
-(NSTextAlignment)alignment;
-(NSWritingDirection)baseWritingDirection;
-(BOOL)wraps;
-(NSString *)title;

-(BOOL)isEnabled;
-(BOOL)isEditable;
-(BOOL)isSelectable;
-(BOOL)isScrollable;
-(BOOL)isBordered;
-(BOOL)isBezeled;
-(BOOL)isContinuous;
-(BOOL)refusesFirstResponder;
-(BOOL)isHighlighted;

-objectValue;
-(NSString *)stringValue;
-(int)intValue;
-(float)floatValue;
-(double)doubleValue;
-(NSAttributedString *)attributedStringValue;
-(id)representedObject;
-(NSControlSize)controlSize;
-(NSFocusRingType)focusRingType;

-(void)setType:(NSCellType)type;

-(void)setState:(int)value;
-(int)nextState;
-(void)setNextState;
-(BOOL)allowsMixedState;
-(void)setAllowsMixedState:(BOOL)allow;

-(void)setTarget:target;
-(void)setAction:(SEL)action;
-(void)setTag:(int)tag;
-(void)setEntryType:(int)type;
-(void)setFormatter:(NSFormatter *)formatter;
-(void)setFont:(NSFont *)font;
-(void)setImage:(NSImage *)image;
-(void)setAlignment:(NSTextAlignment)alignment;
-(void)setBaseWritingDirection:(NSWritingDirection)value;
-(void)setWraps:(BOOL)wraps;
-(void)setTitle:(NSString *)title;

-(void)setEnabled:(BOOL)flag;
-(void)setEditable:(BOOL)flag;
-(void)setSelectable:(BOOL)flag;
-(void)setScrollable:(BOOL)flag;
-(void)setBordered:(BOOL)flag;
-(void)setBezeled:(BOOL)flag;
-(void)setContinuous:(BOOL)flag;
-(void)setRefusesFirstResponder:(BOOL)flag;
-(void)setHighlighted:(BOOL)flag;

-(void)setFloatingPointFormat:(BOOL)fpp left:(unsigned)left right:(unsigned)right;

-(void)setObjectValue:(id <NSCopying>)value;
-(void)setStringValue:(NSString *)value;
-(void)setIntValue:(int)value;
-(void)setFloatValue:(float)value;
-(void)setDoubleValue:(double)value;
-(void)setAttributedStringValue:(NSAttributedString *)value;
-(void)setRepresentedObject:(id)object;
-(void)setControlSize:(NSControlSize)size;
-(void)setFocusRingType:(NSFocusRingType)focusRingType;

-(void)takeObjectValueFrom:sender;
-(void)takeStringValueFrom:sender;
-(void)takeIntValueFrom:sender;
-(void)takeFloatValueFrom:sender;

-(NSSize)cellSize;

-(NSRect)imageRectForBounds:(NSRect)rect;
-(NSRect)titleRectForBounds:(NSRect)rect;
-(NSRect)drawingRectForBounds:(NSRect)rect;

-(void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view;
-(void)drawWithFrame:(NSRect)frame inView:(NSView *)view;

-(void)highlight:(BOOL)highlight withFrame:(NSRect)frame inView:(NSView *)view;

-(BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)view;
-(BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)view;
-(void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)view mouseIsUp:(BOOL)flag;
-(BOOL)trackMouse:(NSEvent *)event inRect:(NSRect)frame ofView:(NSView *)view untilMouseUp:(BOOL)flag;

-(NSText *)setUpFieldEditorAttributes:(NSText *)editor;

-(void)editWithFrame:(NSRect)frame inView:(NSView *)view editor:(NSText *)editor delegate:(id)delegate event:(NSEvent *)event;
-(void)selectWithFrame:(NSRect)frame inView:(NSView *)view editor:(NSText *)editor delegate:(id)delegate start:(int)location length:(int)length;
-(void)endEditing:(NSText *)editor;

-(void)resetCursorRect:(NSRect)rect inView:(NSView *)view;

- (void)setSendsActionOnEndEditing:(BOOL)flag;
- (BOOL)sendsActionOnEndEditing;

@end
