/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/NSPopUpButtonCell.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSGraphicsStyle.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSPopUpWindow.h>
#import <Foundation/NSKeyedArchiver.h>
#import <AppKit/NSRaise.h>

@implementation NSPopUpButtonCell

-init {
   self = [super init];
   _pullsDown = NO;
   _menu = [[[NSMenu alloc] init] retain];
   _selectedIndex=-1;
   _arrowPosition = NSPopUpArrowAtCenter;
   _preferredEdge = NSMaxYEdge;
   return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
   NSUnimplementedMethod();
}

-initWithCoder:(NSCoder *)coder {
   [super initWithCoder:coder];

   if([coder allowsKeyedCoding]){ 
    _pullsDown=[coder decodeBoolForKey:@"NSPullDown"];
    _menu=[[coder decodeObjectForKey:@"NSMenu"] retain];
    _selectedIndex=[coder decodeIntForKey:@"NSSelectedIndex"];
    _arrowPosition = [coder decodeIntForKey: @"NSArrowPosition"];
    _preferredEdge = [coder decodeIntForKey: @"NSPreferredEdge"];
    _usesItemFromMenu=[coder decodeBoolForKey:@"NSUsesItemFromMenu"];
    
    [self synchronizeTitleAndSelectedItem];
   }
   else {
    [NSException raise:NSInvalidArgumentException format:@"%@ can not initWithCoder:%@",isa,[coder class]];
   }
   return self;
}

-copyWithZone:(NSZone *)zone {
   NSPopUpButtonCell *copy = [super copyWithZone:zone];

   copy->_menu = [_menu copy];

   return copy;
}

-initTextCell:(NSString *)string pullsDown:(BOOL)pullDown {
   [super initTextCell:string];
   _menu = [[NSMenu alloc] initWithTitle:string];
   [_menu addItemWithTitle:string action:[self action] keyEquivalent:@""];
   _arrowPosition = NSPopUpArrowAtCenter;
   _preferredEdge = NSMaxYEdge;
   _pullsDown=pullDown;
   return self;
}

-(void)dealloc {
   [_menu release];
   [super dealloc];
}

-(BOOL)isOpaque {
   return NO;
}

-(BOOL)pullsDown {
   return _pullsDown;
}

-(NSMenu *)menu {
   return _menu;
}

-(BOOL)autoenablesItems {
   return _autoenablesItems;
}

-(NSRectEdge)preferredEdge {
   return _preferredEdge;
}

-(NSArray *)itemArray {
   return [_menu itemArray];
}

-(NSInteger)numberOfItems {
   return [_menu numberOfItems];
}

-(NSMenuItem *)itemAtIndex:(NSInteger)index {
   return [_menu itemAtIndex:index];
}

-(NSMenuItem *)itemWithTitle:(NSString *)title {
   return [_menu itemWithTitle:title];
}

-(NSMenuItem *)lastItem {
   if([_menu numberOfItems]==0)
    return nil;
    
   return [_menu itemAtIndex:[_menu numberOfItems]-1];
}

-(NSInteger)indexOfItem:(NSMenuItem *)item {
   return [_menu indexOfItem:item];
}

-(NSInteger)indexOfItemWithTitle:(NSString *)title {
   return [_menu indexOfItemWithTitle:title];
}

-(NSInteger)indexOfItemWithTag:(NSInteger)tag {
   return [_menu indexOfItemWithTag:tag];
}

-(NSInteger)indexOfItemWithRepresentedObject:object {
   return [_menu indexOfItemWithRepresentedObject:object];
}

-(NSInteger)indexOfItemWithTarget:target andAction:(SEL)action {
   return [_menu indexOfItemWithTarget:target andAction:action];
}

-(NSMenuItem *)selectedItem {
  if(_selectedIndex<0)
   return nil;
   
  return [_menu itemAtIndex:_selectedIndex];
}

-(NSString *)titleOfSelectedItem {
   return [[self selectedItem] title];
}

-(NSInteger)indexOfSelectedItem {
   return _selectedIndex;
}

-(void)setPullsDown:(BOOL)flag {
    _pullsDown = flag;
}

-(void)setMenu:(NSMenu *)menu {
   menu=[menu retain];
   [_menu release];
   _menu = menu;
   
   if([_menu numberOfItems]>0)
    _selectedIndex=0;
   else
    _selectedIndex=-1;

   [self synchronizeTitleAndSelectedItem];
}

-(void)setAutoenablesItems:(BOOL)value {
   _autoenablesItems=value?YES:NO;
}

-(void)setPreferredEdge:(NSRectEdge)edge {
   edge=_preferredEdge;
}

-(void)_addItemWithTitle:(NSString *)title {
   NSMenuItem *check=[_menu itemWithTitle:title];
   
   if(check!=nil)
    [_menu removeItem:check];
   
   [_menu addItemWithTitle:title action:NULL keyEquivalent:nil];

   if(_selectedIndex<0)
    _selectedIndex=0;
}

-(void)addItemWithTitle:(NSString *)title {
   [self _addItemWithTitle:title];
   [self synchronizeTitleAndSelectedItem];
}

-(void)addItemsWithTitles:(NSArray *)titles {
   NSInteger i,count=[titles count];

   for(i=0;i<count;i++)
    [self _addItemWithTitle:[titles objectAtIndex:i]];
    
   [self synchronizeTitleAndSelectedItem];
}

-(void)removeAllItems {
   [_menu removeAllItems];
	_selectedIndex = -1;
}

-(void)removeItemAtIndex:(NSInteger)index {
   [_menu removeItemAtIndex:index];
}

-(void)removeItemWithTitle:(NSString *)title {
   NSInteger index=[self indexOfItemWithTitle:title];
   [self removeItemAtIndex:index];
}

-(void)insertItemWithTitle:(NSString *)title atIndex:(NSInteger)index {
   [_menu insertItemWithTitle:title action:NULL keyEquivalent:nil atIndex:index];
}

-(void)selectItem:(NSMenuItem *)item {
   [self willChangeValueForKey:@"selectedItem"];

   if(item==nil)
    _selectedIndex=-1;
   else {
    NSInteger check=[[_menu itemArray] indexOfObjectIdenticalTo:item];
    
    _selectedIndex=(check==NSNotFound)?-1:check;
   }
      
   [self didChangeValueForKey:@"selectedItem"];

   [self synchronizeTitleAndSelectedItem];
}

-(void)selectItemAtIndex:(NSInteger)index {
   NSMenuItem *item=(index<0)?nil:[self itemAtIndex:index];

   [self selectItem:item];
}

-(void)selectItemWithTitle:(NSString *)title {
   [self selectItemAtIndex:[self indexOfItemWithTitle:title]];
}

-(BOOL)selectItemWithTag:(NSInteger)tag {   
   NSInteger index=[self indexOfItemWithTag:tag];
   
   if(index<0)
    return NO;

   [self selectItemAtIndex:index];
   return YES;
}

-(NSString *)itemTitleAtIndex:(NSInteger)index {
   return [[self itemAtIndex:index] title];
}

-(NSArray *)itemTitles {
   NSMutableArray *result=[NSMutableArray array];
   NSArray *array=[self itemArray];
   NSInteger i,count=[array count];
   
   for(i=0;i<count;i++)
    [result addObject:[[array objectAtIndex:i] title]];
   
   return result;
}

-(void)synchronizeTitleAndSelectedItem {
   NSArray    *itemArray=[_menu itemArray];
   NSMenuItem *item=nil;
   
   if(_selectedIndex<0 || _pullsDown){
    if([itemArray count]>0)
     item=[itemArray objectAtIndex:0];
   }
   else {
    item=[itemArray objectAtIndex:_selectedIndex];
   }
   
   [super setTitle:[item title]];
}


-(NSImage *)arrowImage {
   if(_pullsDown)
    return [NSImage imageNamed:@"NSPopUpButtonCellPullDown"];
   else
    return [NSImage imageNamed:@"NSPopUpButtonCellPopUp"];
}

-(void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {

	[super drawBezelWithFrame: frame inView: controlView];

	NSImage * arrowImage = ( _arrowPosition != NSPopUpNoArrow ) ? [self arrowImage] : NULL;
	
	if (arrowImage == NULL) return;
	
	// Now draw the arrow
    if( _arrowPosition != NSPopUpNoArrow )
	{
		// Scale down the arrows so they look proportional to the control size
		float sizeFactor = 0;
		switch ([self controlSize]) {
			case NSRegularControlSize:
				sizeFactor = 0;
				break;
			case NSSmallControlSize:
				sizeFactor = 1;
				break;
			case NSMiniControlSize:
				sizeFactor = 2;
				break;
		}
		NSRect otherFrame = frame;
		NSSize arrowSize = [arrowImage size];
		otherFrame.origin.x += otherFrame.size.width - ( arrowSize.width + (4 - sizeFactor) );
		otherFrame.origin.y += ( otherFrame.size.height - arrowSize.height ) / 2;
		otherFrame.size =  arrowSize;
		
		otherFrame = NSInsetRect(otherFrame, sizeFactor, sizeFactor);
		[[controlView graphicsStyle] drawButtonImage:arrowImage inRect:otherFrame enabled:YES mixed:YES];
	}
}

-(NSSize)cellSize  {
   NSSize result=[super cellSize];
   
   switch([self controlSize]){
   
    case NSRegularControlSize:
     result.height=22;
     break;
			
    case NSSmallControlSize:
     result.height=19;
     break;
			
    case NSMiniControlSize:
     result.height=15;
     break;
   }

   return result;
}

-(void)setTitle:(NSString *)title {
   
   if(_pullsDown){
    // Doc.s for pulls down behavior are not correct, it just sets the title to the argument and doesn't affect the selection
    [super setTitle:title];
   }
   else {
    NSMenuItem *item=[_menu itemWithTitle:title];
   
    if(item==nil)
     [self addItemWithTitle:title];

    [self selectItemWithTitle:title];
   }
}


-(NSCellImagePosition)imagePosition {
   return NSImageRight;
}

-(NSInteger)tag {
   return [[self selectedItem] tag];
}

-(BOOL)trackMouse:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
   NSPopUpWindow *window;
   NSPoint        origin=[controlView bounds].origin;
   
#if 0
   // Note: the min options don't mean much unless we don't have room for the menu, so either way we just pop
   // up over the button itself. However, maxX and maxY *do* have special meanings
   switch( _preferredEdge )
   {
      case NSMinXEdge:
      case NSMinYEdge:
	     break;
	  case NSMaxXEdge:
		 origin.x += [controlView bounds].size.width;
	     break;
	  case NSMaxYEdge: 
         // Remember, our Y axis is flipped in Cocoa. Also, not sure why we need the -4 offset here, 
		 // can't figure out where the offset comes from, but it works			
		 origin.y -= [controlView bounds].size.height - 4;
	     break;
   }
#endif
  
   origin=[controlView convertPoint:origin toView:nil];
   origin=[[controlView window] convertBaseToScreen:origin];

   window=[[NSPopUpWindow alloc] initWithFrame:NSMakeRect(origin.x,origin.y,
     cellFrame.size.width,cellFrame.size.height)];
   [window setMenu:_menu];
   if([self font]!=nil)
    [window setFont:[self font]];

   if(_pullsDown)
    [window selectItemAtIndex:0];
   else
    [window selectItemAtIndex:_selectedIndex];

   NSInteger itemIndex=[window runTrackingWithEvent:event];
   if(itemIndex!=NSNotFound)
	[self selectItemAtIndex:itemIndex];

   [window close]; // release when closed=YES

   return YES;
}

-(void)moveUp:sender {
   NSInteger index = [self indexOfSelectedItem];
    
   if (index > 0)
    [self selectItemAtIndex:index-1];
}

-(void)moveDown:sender {
   NSInteger index = [self indexOfSelectedItem];
    
   if (index < [self numberOfItems]-1)
    [self selectItemAtIndex:index+1];
}

@end
