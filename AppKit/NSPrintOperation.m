/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <AppKit/NSPrintOperation.h>
#import <AppKit/NSPrintInfo.h>
#import <AppKit/NSPrintPanel.h>
#import <AppKit/NSView.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSGraphicsContext.h>

enum {
   NSPrintOperationPDFInRect,
   NSPrintOperationEPSInRect,
   NSPrintOperationPrinter,
};

@implementation NSPrintOperation

static NSPrintOperation *_currentOperation=nil;

+(NSPrintOperation *)currentOperation {
   return _currentOperation;
}

-initWithView:(NSView *)view printInfo:(NSPrintInfo *)printInfo insideRect:(NSRect)rect toData:(NSMutableData *)data type:(int)type {
   _view=[view retain];
   _printInfo=[printInfo copy];
   if(type==NSPrintOperationPDFInRect || type==NSPrintOperationEPSInRect)
    [_printInfo setPaperSize:rect.size];
   _printPanel=[[NSPrintPanel printPanel] retain];
   _showsPrintPanel=YES;
   _currentPage=0;
   _insideRect=rect;
   _mutableData=[data retain];
   _type=type;
   return self;
}

-initWithView:(NSView *)view printInfo:(NSPrintInfo *)printInfo {
   return [self initWithView:view printInfo:printInfo insideRect:[view bounds] toData:nil type:NSPrintOperationPrinter];
}

-(void)dealloc {
   [_view release];
   [_printInfo release];
   [_printPanel release];
   [_context release];
   [_mutableData release];
   [super dealloc];
}


+(NSPrintOperation *)printOperationWithView:(NSView *)view {
   return [[[self alloc] initWithView:view printInfo:[NSPrintInfo sharedPrintInfo]] autorelease];
}

+(NSPrintOperation *)printOperationWithView:(NSView *)view printInfo:(NSPrintInfo *)printInfo {
   return [[[self alloc] initWithView:view printInfo:printInfo] autorelease];
}

+(NSPrintOperation *)PDFOperationWithView:(NSView *)view insideRect:(NSRect)rect toData:(NSMutableData *)data {
   return [self PDFOperationWithView:view insideRect:rect toData:data printInfo:[NSPrintInfo sharedPrintInfo]];
}

+(NSPrintOperation *)PDFOperationWithView:(NSView *)view insideRect:(NSRect)rect toData:(NSMutableData *)data printInfo:(NSPrintInfo *)printInfo {
   return [[[self alloc] initWithView:view printInfo:printInfo insideRect:rect toData:data type:NSPrintOperationPDFInRect] autorelease];
}

+(NSPrintOperation *)EPSOperationWithView:(NSView *)view insideRect:(NSRect)rect toData:(NSMutableData *)data {
   return [self EPSOperationWithView:view insideRect:rect toData:data printInfo:[NSPrintInfo sharedPrintInfo]];
}

+(NSPrintOperation *)EPSOperationWithView:(NSView *)view insideRect:(NSRect)rect toData:(NSMutableData *)data printInfo:(NSPrintInfo *)printInfo {
   return [[[self alloc] initWithView:view printInfo:printInfo insideRect:rect toData:data type:NSPrintOperationEPSInRect] autorelease];
}

-(BOOL)isCopyingOperation {
   return NO;
}

-(void)setAccessoryView:(NSView *)view {
   view=[view retain];
   [_accessoryView release];
   _accessoryView=view;
}

-(NSView *)view {
   return _view;
}

-(NSPrintInfo *)printInfo {
   return _printInfo;
}

-(NSPrintPanel *)printPanel {
   return _printPanel;
}

-(BOOL)showsPrintPanel {
   return _showsPrintPanel;
}

-(void)setShowsPrintPanel:(BOOL)flag {
   _showsPrintPanel=flag;
}

-(int)currentPage {
   return _currentPage;
}


-(void)_autopaginatePageRange:(NSRange)pageRange actualPageRange:(NSRange *)rangep context:(CGContextRef)context {
   NSRange result=NSMakeRange(1,0);
   NSRect  bounds=[_view bounds];
   NSRect  imageableRect=[_printInfo imageablePageBounds];
   BOOL    isFlipped=[_view isFlipped];
   float   top=isFlipped?NSMinY(bounds):NSMaxY(bounds);
   NSPrintingOrientation orientation=[_printInfo orientation];
   
   while(YES) {
    float heightAdjustLimit=[_view heightAdjustLimit];
    float widthAdjustLimit=[_view widthAdjustLimit];
    float left=NSMinX(bounds);
    float right=left+imageableRect.size.width;
    float rightLimit=left+imageableRect.size.width*widthAdjustLimit;
    float bottom=isFlipped?top+imageableRect.size.height:top-imageableRect.size.height;
    float bottomLimit=isFlipped?top+imageableRect.size.height*heightAdjustLimit:top-imageableRect.size.height*heightAdjustLimit;
    
    if(orientation==NSLandscapeOrientation){
     // FIX
    }
    
    if(isFlipped){
     if(bottom>NSMaxY(bounds))
      bottom=NSMaxY(bounds);
    }
    else {
     if(bottom<NSMinY(bounds))
      bottom=NSMinY(bounds);
    }

    [_view adjustPageWidthNew:&right left:left right:right limit:rightLimit];
    [_view adjustPageHeightNew:&bottom top:top bottom:bottom limit:bottomLimit];
             
    if(context!=nil && (pageRange.location==NSNotFound || NSLocationInRange(NSMaxRange(result),pageRange))){
     NSRect  rect=NSMakeRect(left,top,right-left,bottom-top);
     NSPoint location=[_view locationOfPrintRect:rect];

     [_view beginPageInRect:rect atPlacement:location];
     [_view drawRect:rect];
     [_view endPage];
     _currentPage++;
    }
    
    result.length++;
    
    top=bottom;
    
    if(isFlipped){
     if(top>=NSMaxY(bounds))
      break;
    }
    else {
     if(top<=NSMinY(bounds))
      break;
    }
   }
   
   *rangep=result;
}

-(void)_paginateWithPageRange:(NSRange)pageRange context:(CGContextRef)context {
   int i;

   for(i=0,_currentPage=pageRange.location;i<pageRange.length;i++,_currentPage++){
    NSRect  rect=[_view rectForPage:_currentPage];
    NSPoint location=[_view locationOfPrintRect:rect];

    [_view beginPageInRect:rect atPlacement:location];
    [_view drawRect:rect];
    [_view endPage];
   }
}

-(NSGraphicsContext *)createContext {
   CGContextRef context;
   
   if(_type==NSPrintOperationPrinter){
    if(_showsPrintPanel){
     NSPrintPanel *printPanel=[self printPanel];
     int           panelResult;

		// We can't assume that there are valid titles on every window
		NSString* title = [[_view window] title];
		if (title == nil) {
			title = @"Printing View";
		}
		
     [[_printInfo dictionary] setObject:_view forKey:@"_NSView"];
     [[_printInfo dictionary] setObject: title forKey:@"_title"];
     panelResult=[printPanel runModal];
     [[_printInfo dictionary] removeObjectForKey:@"_NSView"];
     [[_printInfo dictionary] removeObjectForKey:@"_title"];
   
     if(panelResult!=NSOKButton)
      return NO;
    }
    else {
     NSLog(@"Printing not implemented without print panel yet");
     return NO;
    }
   
    if((context=(CGContextRef)[[_printInfo dictionary] objectForKey:@"_KGContext"])==nil)
     return nil;
   }
   else if(_type==NSPrintOperationPDFInRect){
    NSDictionary *auxiliaryInfo=[NSDictionary dictionaryWithObject:[[_view window] title] forKey:(NSString *)kCGPDFContextTitle];
    
    CGDataConsumerRef consumer=CGDataConsumerCreateWithCFData((CFMutableDataRef)_mutableData);
    
    context=CGPDFContextCreate(consumer,&_insideRect,(CFDictionaryRef)auxiliaryInfo);
    [(id)context autorelease];
    
    CGDataConsumerRelease(consumer);
   }
   else
    return nil;
    
   return [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
}

-(void)destroyContext {
   if(_type==NSPrintOperationPrinter){
    [[_printInfo dictionary] removeObjectForKey:@"_KGContext"];
   }
}

// FIX, drawRect: should be changed to displayRect: and displayRect:/NSView should be print aware

-(BOOL)runOperation {
   NSRange            pageRange=NSMakeRange(NSNotFound,NSNotFound);
   BOOL               knowsPageRange;
   NSGraphicsContext *graphicsContext;
   CGContextRef      context;
   
   _currentOperation=self;
   
   knowsPageRange=[_view knowsPageRange:&pageRange];

   if(knowsPageRange){
    [[_printInfo dictionary] setObject:[NSNumber numberWithInt:pageRange.location] forKey:NSPrintFirstPage];
    [[_printInfo dictionary] setObject:[NSNumber numberWithInt:NSMaxRange(pageRange)-1] forKey:NSPrintLastPage];
   }
   else {
    [[_printInfo dictionary] setObject:[NSNumber numberWithInt:1] forKey:NSPrintFirstPage];
    [[_printInfo dictionary] setObject:[NSNumber numberWithInt:1] forKey:NSPrintLastPage];
   }
   
   graphicsContext=[self createContext];
   context=[graphicsContext graphicsPort];
   
   [_printInfo setUpPrintOperationDefaultValues];

   [NSGraphicsContext saveGraphicsState];
   [NSGraphicsContext setCurrentContext:graphicsContext];
   [_view beginDocument];

   if(_type==NSPrintOperationPDFInRect){     
    [_view beginPageInRect:_insideRect atPlacement:NSMakePoint(0,0)];
    [_view drawRect:_insideRect];
    [_view endPage];
   }
   else{
    if(knowsPageRange)
     [self _paginateWithPageRange:pageRange context:context];
    else
     [self _autopaginatePageRange:pageRange actualPageRange:&pageRange context:context];
   }
    
   [_view endDocument];
   CGPDFContextClose(context);
   [NSGraphicsContext restoreGraphicsState];
   
   [self destroyContext];
   
   _currentOperation=nil;

   return YES;
}

@end
