/* Copyright (c) 2006-2009 Christopher J. W. Lloyd <cjwl@objc.net>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSParagraphStyle.h>
#import <AppKit/NSTextAttachment.h>
#import <AppKit/NSRichTextReader.h>
#import <AppKit/NSRaise.h>

NSString * const NSFontAttributeName=@"NSFontAttributeName"; 
NSString * const NSParagraphStyleAttributeName=@"NSParagraphStyleAttributeName";
NSString * const NSForegroundColorAttributeName=@"NSForegroundColorAttributeName";
NSString * const NSBackgroundColorAttributeName=@"NSBackgroundColorAttributeName";
NSString * const NSUnderlineStyleAttributeName=@"NSUnderlineStyleAttributeName";
NSString * const NSUnderlineColorAttributeName=@"NSUnderlineColorAttributeName";
NSString * const NSAttachmentAttributeName=@"NSAttachmentAttributeName";
NSString * const NSKernAttributeName=@"NSKernAttributeName";
NSString * const NSLigatureAttributeName=@"NSLigatureAttributeName";
NSString * const NSStrikethroughStyleAttributeName=@"NSStrikethroughStyleAttributeName";
NSString * const NSStrikethroughColorAttributeName=@"NSStrikethroughColorAttributeName";
NSString * const NSObliquenessAttributeName=@"NSObliquenessAttributeName";
NSString * const NSStrokeWidthAttributeName=@"NSStrokeWidthAttributeName";
NSString * const NSStrokeColorAttributeName=@"NSStrokeColorAttributeName";
NSString * const NSBaselineOffsetAttributeName=@"NSBaselineOffsetAttributeName";
NSString * const NSSuperscriptAttributeName=@"NSSuperscriptAttributeName";
NSString * const NSLinkAttributeName=@"NSLinkAttributeName";
NSString * const NSShadowAttributeName=@"NSShadowAttributeName";
NSString * const NSExpansionAttributeName=@"NSExpansionAttributeName";
NSString * const NSCursorAttributeName=@"NSCursorAttributeName";
NSString * const NSToolTipAttributeName=@"NSToolTipAttributeName";
NSString * const NSBackgroundColorDocumentAttribute=@"NSBackgroundColorDocumentAttribute";
NSString * const NSSpellingStateAttributeName=@"NSSpellingStateAttributeName"; // temporary attribute

@implementation NSAttributedString(NSAttributedString_AppKit)

+(NSArray *)textFileTypes {
   NSUnimplementedMethod();
   return nil;
}

+(NSArray *)textPasteboardTypes {
   NSUnimplementedMethod();
   return nil;
}

+(NSArray *)textUnfilteredFileTypes {
   NSUnimplementedMethod();
   return nil;
}

+(NSArray *)textUnfilteredPasteboardTypes {
   NSUnimplementedMethod();
   return nil;
}

+(NSAttributedString *)attributedStringWithAttachment:(NSTextAttachment *)attachment {
   unichar       unicode=NSAttachmentCharacter;
   NSString     *string=[NSString stringWithCharacters:&unicode length:1];
   NSDictionary *attributes=[NSDictionary dictionaryWithObject:attachment forKey:NSAttachmentAttributeName];
   
   return [[[self alloc] initWithString:string attributes:attributes] autorelease];
}

-initWithData:(NSData *)data options:(NSDictionary *)options documentAttributes:(NSDictionary **)attributes error:(NSError **)error {
   NSUnimplementedMethod();
   return nil;
}

-initWithDocFormat:(NSData *)werd documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithHTML:(NSData *)html baseURL:(NSURL *)url documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithHTML:(NSData *)html documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithHTML:(NSData *)html options:(NSDictionary *)options documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithPath:(NSString *)path documentAttributes:(NSDictionary **)attributes {
   NSAttributedString *string=[NSRichTextReader attributedStringWithContentsOfFile:path];
   if(string==nil){
    [self dealloc];
    return nil;
   }
   return [self initWithAttributedString:string];
}

-initWithRTF:(NSData *)rtf documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithRTFD:(NSData *)rtfd documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithRTFDFileWrapper:(NSFileWrapper *)wrapper documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithURL:(NSURL *)url documentAttributes:(NSDictionary **)attributes {
   NSUnimplementedMethod();
   return nil;
}

-initWithURL:(NSURL *)url options:(NSDictionary *)options documentAttributes:(NSDictionary **)attributes error:(NSError **)error {
   NSUnimplementedMethod();
   return nil;
}

-(int)itemNumberInTextList:(NSTextList *)list atIndex:(unsigned)index {
   NSUnimplementedMethod();
   return 0;
}

-(unsigned)lineBreakBeforeIndex:(unsigned)index withinRange:(NSRange)range {
   NSUnimplementedMethod();
   return 0;
}

-(unsigned)lineBreakByHyphenatingBeforeIndex:(unsigned)index withinRange:(NSRange)range {
   NSUnimplementedMethod();
   return 0;
}

-(NSRange)rangeOfTextBlock:(NSTextBlock *)block atIndex:(unsigned)index {
   NSUnimplementedMethod();
   return NSMakeRange(0,0);
}

-(NSRange)rangeOfTextList:(NSTextList *)list atIndex:(unsigned)index {
   NSUnimplementedMethod();
   return NSMakeRange(0,0);
}

-(NSRange)rangeOfTextTable:(NSTextTable *)table atIndex:(unsigned)index {
   NSUnimplementedMethod();
   return NSMakeRange(0,0);
}

-(NSFileWrapper *)RTFDFileWrapperFromRange:(NSRange)range documentAttributes:(NSDictionary *)attributes {
   NSUnimplementedMethod();
   return nil;
}

-(NSData *)RTFDFromRange:(NSRange)range documentAttributes:(NSDictionary *)attributes {
   NSUnimplementedMethod();
   return nil;
}

-(NSData *)RTFFromRange:(NSRange)range documentAttributes:(NSDictionary *)attributes {
   NSUnimplementedMethod();
   return nil;
}

-(NSDictionary *)rulerAttributesInRange:(NSRange)range {
   NSUnimplementedMethod();
   return nil;
}

-(NSRange)doubleClickAtIndex:(unsigned)location {
   NSRange   result=NSMakeRange(location,0);
   NSString *string=[self string];
   unsigned  length=[string length];
   unichar   character=[string characterAtIndex:location];
   NSCharacterSet *set;
   BOOL      expand=NO;

   set=[NSCharacterSet alphanumericCharacterSet];
   if([set characterIsMember:character])
    expand=YES;
   else {
    set=[NSCharacterSet whitespaceCharacterSet];
    if([set characterIsMember:character])
     expand=YES;
   }

   if(expand){
    for(;result.location!=0;result.location--,result.length++) {
     if(![set characterIsMember:[string characterAtIndex:result.location-1]])
      break;
    }

    for(;NSMaxRange(result)<length;result.length++){
     if(![set characterIsMember:[string characterAtIndex:NSMaxRange(result)]])
      break;
    }
   }
   else if(location<length)
    result.length=1;

   return result;
}

/* as usual, the documentation says one thing and the system behaves differently, this is the way i think it should work... (dwy 5/11/2003) */
-(unsigned)nextWordFromIndex:(unsigned)location forward:(BOOL)forward {
    NSCharacterSet *alpha = [NSCharacterSet alphanumericCharacterSet];
    NSString *string = [self string];
    int i = location, length = [self length];
    enum {
        STATE_INIT,	// skipping all whitespace
        STATE_ALNUM,	// body of word
        STATE_SPACE	// word delimiter
    } state = STATE_ALNUM;

    if (location == 0 && forward == NO) {
//        NSLog(@"sanity check: location == 0 && forward == NO");
        return location;
    }
    if (location >= [self length]) {
//        NSLog(@"sanity check: location >= [self length] && forward == YES");
        if (forward == YES)
            return [self length];
        else
            location = [self length]-1;
    }

    if (forward) {
        if (![alpha characterIsMember:[string characterAtIndex:location]])
            state = STATE_INIT;
        
        for (; i < length; ++i) {
            unichar ch = [string characterAtIndex:i];
            switch (state) {
                case STATE_INIT:
                    if (![alpha characterIsMember:ch])
                        state = STATE_ALNUM;
                    break;
                case STATE_ALNUM:
                    if ([alpha characterIsMember:ch])
                        state = STATE_SPACE;
                    break;
                case STATE_SPACE:
                    if (![alpha characterIsMember:ch])
                        return i;
            }
        }

        return length;
    }
    else {
        i--;
        if (![alpha characterIsMember:[string characterAtIndex:location]])
            state = STATE_INIT;

        for (; i >= 0; i--) {
            unichar ch = [string characterAtIndex:i];
            switch (state) {
                case STATE_INIT:
                    if (![alpha characterIsMember:ch])
                        state = STATE_ALNUM;
                    break;
                case STATE_ALNUM:
                    if ([alpha characterIsMember:ch])
                        state = STATE_SPACE;
                    break;
                case STATE_SPACE:
                    if (![alpha characterIsMember:ch])
                        return i+1;
            }
        }

        return 0;
    }

    return NSNotFound;
}

-(NSRect)boundingRectWithSize:(NSSize)size options:(NSStringDrawingOptions)options {
   NSUnimplementedMethod();
   return NSMakeRect(0,0,0,0);
}

-(BOOL)containsAttachments {
   NSUnimplementedMethod();
   return NO;
}

-(NSData *)dataFromRange:(NSRange)range documentAttributes:(NSDictionary *)attributes error:(NSError **)error {
   NSUnimplementedMethod();
   return 0;
}

-(NSData *)docFormatFromRange:(NSRange)range documentAttributes:(NSDictionary *)attributes {
   NSUnimplementedMethod();
   return 0;
}

-(NSFileWrapper *)fileWrapperFromRange:(NSRange)range documentAttributes:(NSDictionary *)attributes error:(NSError **)error {
   NSUnimplementedMethod();
   return nil;
}

-(NSDictionary *)fontAttributesInRange:(NSRange)range {
   NSUnimplementedMethod();
   return nil;
}

@end

NSFont *NSFontAttributeInDictionary(NSDictionary *dictionary) {
   NSFont *font=[dictionary objectForKey:NSFontAttributeName];

   if(font==nil)
    font=[NSFont fontWithName:@"Arial" size:12.0];

   return font;
}

NSColor *NSForegroundColorAttributeInDictionary(NSDictionary *dictionary) {
   NSColor *color=[dictionary objectForKey:NSForegroundColorAttributeName];

   if(color==nil)
    color=[NSColor blackColor];

   return color;
}

NSParagraphStyle *NSParagraphStyleAttributeInDictionary(NSDictionary *dictionary) {
   NSParagraphStyle  *style=[dictionary objectForKey:NSParagraphStyleAttributeName];

   if(style==nil)
    style=[NSParagraphStyle defaultParagraphStyle];

   return style;
}

