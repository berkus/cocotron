/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSView.h>
#import <AppKit/NSText.h>

@class NSCell, NSFont, NSText;

APPKIT_EXPORT NSString *NSControlTextDidBeginEditingNotification;
APPKIT_EXPORT NSString *NSControlTextDidChangeNotification;
APPKIT_EXPORT NSString *NSControlTextDidEndEditingNotification;

@interface NSControl : NSView {
   id      _cell;
   NSText *_currentEditor;
}

+(Class)cellClass;
+(void)setCellClass:(Class)aClass;

-cell;

-target;
-(SEL)action;
-(int)tag;
-(NSFont *)font;
-(NSImage *)image;
-(NSTextAlignment)alignment;
-(BOOL)isEnabled;
-(BOOL)isEditable;
-(BOOL)isSelectable;
-(BOOL)isScrollable;
-(BOOL)isBordered;
-(BOOL)isBezeled;
-(BOOL)isContinuous;
-(BOOL)refusesFirstResponder;

-objectValue;
-(NSString *)stringValue;
-(int)intValue;
-(float)floatValue;
-(double)doubleValue;

-selectedCell;
-(int)selectedTag;

-(void)setCell:(NSCell *)cell;
-(void)setTarget:target;
-(void)setAction:(SEL)action;
-(void)setTag:(int)tag;
-(void)setFont:(NSFont *)font;
-(void)setImage:(NSImage *)image;
-(void)setAlignment:(NSTextAlignment)alignment;
-(void)setFloatingPointFormat:(BOOL)fpp left:(unsigned)left right:(unsigned)right;
-(void)setEnabled:(BOOL)flag;
-(void)setEditable:(BOOL)flag;
-(void)setSelectable:(BOOL)flag;
-(void)setScrollable:(BOOL)flag;
-(void)setBordered:(BOOL)flag;
-(void)setBezeled:(BOOL)flag;
-(void)setContinuous:(BOOL)flag;
-(void)setRefusesFirstResponder:(BOOL)flag;

-(void)setObjectValue:(id <NSCopying>)value;
-(void)setStringValue:(NSString *)value;
-(void)setIntValue:(int)value;
-(void)setFloatValue:(float)value;
-(void)setDoubleValue:(double)value;
-(void)setAttributedStringValue:(NSAttributedString *)value;

-(void)takeObjectValueFrom:sender;
-(void)takeStringValueFrom:sender;
-(void)takeIntValueFrom:sender;
-(void)takeFloatValueFrom:sender;
-(void)takeDoubleValueFrom:sender;

-(void)selectCell:(NSCell *)cell;

-(void)drawCell:(NSCell *)cell;
-(void)drawCellInside:(NSCell *)cell;
-(void)updateCell:(NSCell *)cell;
-(void)updateCellInside:(NSCell *)cell;


-(void)performClick:sender;
-(BOOL)sendAction:(SEL)action to:target;

-(NSText *)currentEditor;
-(void)validateEditing;
-(BOOL)abortEditing;

-(void)calcSize;
-(void)sizeToFit;

@end

@interface NSObject(NSControl_delegate)
-(BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor;
-(BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor;
-(void)controlTextDidBeginEditing:(NSNotification *)note;
-(void)controlTextDidChange:(NSNotification *)note;
-(void)controlTextDidEndEditing:(NSNotification *)note;
@end

