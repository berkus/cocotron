/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - David Young <daver@geeks.org>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSOutlineMarkerCell.h>
#import <AppKit/NSInterfaceStyle.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSImageCell.h>
#import <AppKit/NSTextFieldCell.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSStringDrawing.h>
#import <AppKit/NSInterfaceGraphics.h>
#import <AppKit/NSGraphicsContextFunctions.h>
#import <AppKit/NSNibKeyedUnarchiver.h>

NSString *NSOutlineViewItemWillExpandNotification=@"NSOutlineViewItemWillExpandNotification";
NSString *NSOutlineViewItemDidExpandNotification=@"NSOutlineViewItemDidExpandNotification";
NSString *NSOutlineViewItemWillCollapseNotification=@"NSOutlineViewItemWillCollapseNotification";
NSString *NSOutlineViewItemDidCollapseNotification=@"NSOutlineViewItemDidCollapseNotification";

NSString *NSOutlineViewColumnDidMoveNotification=@"NSOutlineViewColumnDidMoveNotification";
NSString *NSOutlineViewColumnDidResizeNotification=@"NSOutlineViewColumnDidResizeNotification";

NSString *NSOutlineViewSelectionDidChangeNotification=@"NSOutlineViewSelectionDidChangeNotification";
NSString *NSOutlineViewSelectionIsChangingNotification=@"NSOutlineViewSelectionIsChangingNotification";

// We probably don't want this public, but NSOutlineView needs it, and it would prove invaluable to
// other subclasses of NSTableView.
@interface NSTableView(NSTableView_notifications)

-(BOOL)delegateShouldSelectTableColumn:(NSTableColumn *)tableColumn ;
-(BOOL)delegateShouldSelectRow:(int)row;
-(BOOL)delegateShouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)row;
-(BOOL)delegateSelectionShouldChange;
-(void)noteSelectionIsChanging;
-(void)noteSelectionDidChange;
-(void)noteColumnDidResizeWithOldWidth:(float)oldWidth;
-(id)dataSourceObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
-(BOOL)dataSourceCanSetObjectValue;
-(void)dataSourceSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

-(void)drawHighlightedSelectionForColumn:(int)column row:(int)row inRect:(NSRect)rect;

@end

@implementation NSOutlineView

static inline BOOL isItemExpanded(NSOutlineView *self,id item){
   return (BOOL)((unsigned)NSMapGet(self->_itemToExpansionState, item));
}

static inline int numberOfChildrenOfItemAndReload(NSOutlineView *self,id item,BOOL reload){
   int result;

   if(!reload)
    result=(int)NSMapGet(self->_itemToNumberOfChildren,item);
   else {
    result=[self->_dataSource outlineView:self numberOfChildrenOfItem:item];
    NSMapInsert(self->_itemToNumberOfChildren,item,(void *)result);
   }

   return result;
}

static inline id childOfItemAtIndex(NSOutlineView *self,id item,int index){
#if 1
   return [self->_dataSource outlineView:self child:index ofItem:item];
#else // broken
   if(item==nil)
    return [self->_dataSource outlineView:self child:index ofItem:item];
   else {
    int row=(int)NSMapGet(self->_itemToRow,item);

    return (id)NSMapGet(self->_rowToItem,(void *)(row+1+index));
   }
#endif
}

-(void)encodeWithCoder:(NSCoder *)coder {
    NSUnimplementedMethod();
}

-(Class)_outlineMarkerCellClass {
   if (NSInterfaceStyleForKey(nil, nil)==NSMacintoshInterfaceStyle)
    return [NSMacintoshOutlineMarkerCell class];
   else
    return [NSWindowsOutlineMarkerCell class];
}

-(void)invalidateRowCache {
    _numberOfCachedRows = 0;
}

-initWithCoder:(NSCoder *)coder {
   [super initWithCoder:coder];

   if([coder isKindOfClass:[NSNibKeyedUnarchiver class]]){
    NSNibKeyedUnarchiver *keyed=(NSNibKeyedUnarchiver *)coder;

    _rowToItem=NSCreateMapTable(NSIntMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
    _itemToRow = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);
    _itemToLevel = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);
    _itemToExpansionState = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);
    _itemToNumberOfChildren = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);

    _markerCell = [[[self _outlineMarkerCellClass] alloc] initImageCell:nil];
        
    [self setIndentationPerLevel:_rowHeight];	// square it off
        
    [self setIndentationMarkerFollowsCell:YES];
    [self setAutoresizesOutlineColumn:YES];
    [self setAutosaveExpandedItems:NO];

    _editingCellPadding = 10.0;

    [self invalidateRowCache];

    _outlineTableColumn=[[[self tableColumns] objectAtIndex:0] retain];
    [self setDrawsGrid:YES];
   }
    else {
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %s] is not implemented for coder %@",isa,SELNAME(_cmd),coder];
    }
    return self;
}

-(id)initWithFrame:(NSRect)frame {
   [super initWithFrame:frame];
    _rowToItem = NSCreateMapTable(NSIntMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
    _itemToRow = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);
    _itemToLevel = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);
    _itemToExpansionState = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);
    _itemToNumberOfChildren = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSIntMapValueCallBacks, 0);

    _markerCell = [[[self _outlineMarkerCellClass] alloc] initImageCell:nil];
        
    [self setIndentationPerLevel:_rowHeight];	// square it off
        
    [self setIndentationMarkerFollowsCell:YES];
    [self setAutoresizesOutlineColumn:YES];
    [self setAutosaveExpandedItems:NO];

    _editingCellPadding = 10.0;

    [self invalidateRowCache];

    return self;
}

-(void)dealloc {
    NSFreeMapTable(_rowToItem);
    NSFreeMapTable(_itemToRow);
    NSFreeMapTable(_itemToLevel);
    NSFreeMapTable(_itemToExpansionState);
    NSFreeMapTable(_itemToNumberOfChildren);

    [_markerCell release];
    [_outlineTableColumn release];
    
    [super dealloc];
}

- (NSTableColumn *)outlineTableColumn
{
    return _outlineTableColumn;
}

-itemAtRow:(int)row {
    return (id)NSMapGet(_rowToItem, (void *)row);
}

-(int)rowForItem:(id)item {
    return (int)NSMapGet(_itemToRow, item);
}

- (BOOL)isExpandable:(id)item
{
    return [_dataSource outlineView:self isItemExpandable:item];
}

-(int)levelForItem:(id)item {
    unsigned level = (unsigned)NSMapGet(_itemToLevel, item);
    return level;
}

-(int)levelForRow:(int)row {
    return [self levelForItem:[self itemAtRow:row]];
}

- (BOOL)isItemExpanded:(id)item
{
    return isItemExpanded(self,item);
}

-(float)indentationPerLevel {
    return _indentationPerLevel;
}

- (BOOL)autoresizesOutlineColumn
{
    return _autoresizesOutlineColumn;
}

- (BOOL)indentationMarkerFollowsCell
{
    return _indentationMarkerFollowsCell;
}

-(BOOL)autosaveExpandedItems {
    return _autosaveExpandedItems;
}

- (void)setOutlineTableColumn:(NSTableColumn *)tableColumn
{
    [_outlineTableColumn release];
    _outlineTableColumn = [tableColumn retain];
}

-(void)setIndentationPerLevel:(float)value {
    _indentationPerLevel = value;
}

- (void)setAutoresizesOutlineColumn:(BOOL)flag
{
    _autoresizesOutlineColumn = flag;
}

- (void)setIndentationMarkerFollowsCell:(BOOL)flag
{
    _indentationMarkerFollowsCell = flag;
}

-(void)setAutosaveExpandedItems:(BOOL)flag {
    _autosaveExpandedItems = flag;
}

-(BOOL)_delayResizeButExpandItem:(id)item expandChildren:(BOOL)expandChildren {
   BOOL noteNumberOfRowsChanged=NO;
    BOOL expandThisItem = YES;

    if(![self isExpandable:item])
     return YES;

    if ([_delegate respondsToSelector:@selector(outlineView:shouldExpandItem:)])
        if ([_delegate outlineView:self shouldExpandItem:item] == NO)
            expandThisItem = NO;

    if (expandThisItem) {
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:item,@"NSObject",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewItemWillExpandNotification
                                                            object:self
                                                          userInfo:userInfo];

        NSMapInsert(_itemToExpansionState, item, (void *)YES);

        [self invalidateRowCache];
        noteNumberOfRowsChanged=YES;

        [[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewItemDidExpandNotification
                                                            object:self
                                                          userInfo:userInfo];
    }

    if (expandChildren) {
        int i,numberOfChildren=numberOfChildrenOfItemAndReload(self,item,YES);

        for (i = 0; i < numberOfChildren; ++i) {
            id child = [_dataSource outlineView:self child:i ofItem:item];

            if([self _delayResizeButExpandItem:child expandChildren:YES])
             noteNumberOfRowsChanged=YES;
        }
    }

    return YES;
}

-(id)_objectValueForTableColumn:(NSTableColumn *)column byItem:(id)item {
   return [_delegate outlineView:self objectValueForTableColumn:column byItem:item];
}

-(void)_tightenUpColumn:(NSTableColumn *)column forItem:(id)item {
   float minWidth=[column width],width;
   int   rootLevel=[self levelForItem:item];
   int   i=[self rowForItem:item]+1;

   for(;i<_numberOfRows;i++) {
    NSCell *dataCell=[column dataCellForRow:i];
    id      item=[self itemAtRow:i];
    int     level=[self levelForItem:item];

    if(level<=rootLevel)
     break;

    [dataCell setObjectValue:[self _objectValueForTableColumn:column byItem:item]];

    width=[[dataCell attributedStringValue] size].width+level*_indentationPerLevel;

    if(width>minWidth)
     minWidth=width;
   }
   width = [[[column headerCell] attributedStringValue] size].width;
   if(width>minWidth)
    minWidth=width;

   [column setMinWidth:minWidth];
}

-(void)_tightenUpColumn:(NSTableColumn *)column {
   [self _tightenUpColumn:column forItem:[self itemAtRow:0]];
}


- (void)expandItem:(id)item expandChildren:(BOOL)expandChildren {
   if([self _delayResizeButExpandItem:item expandChildren:expandChildren]){
    [self noteNumberOfRowsChanged];
    if(_autoresizesOutlineColumn){
     [self _tightenUpColumn: _outlineTableColumn forItem:item];
     if([_outlineTableColumn width]<[_outlineTableColumn minWidth])
      [_outlineTableColumn setWidth:[_outlineTableColumn minWidth]];
    }
    [self setNeedsDisplay:YES];
   }
}

- (void)expandItem:(id)item
{
    [self expandItem:item expandChildren:NO];
}

- (void)collapseItem:(id)item collapseChildren:(BOOL)collapseChildren
{
    BOOL collapseThisItem = YES;
    
    if ([_delegate respondsToSelector:@selector(outlineView:shouldCollapseItem:)])
        if ([_delegate outlineView:self shouldCollapseItem:item] == NO)
            collapseThisItem = NO;

    if (collapseThisItem) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            item, @"NSObject", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewItemWillCollapseNotification
                                                            object:self
                                                          userInfo:userInfo];

        NSMapInsert(_itemToExpansionState, item, (void *)NO);

        [self invalidateRowCache];
        [self noteNumberOfRowsChanged];

        [[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewItemDidCollapseNotification
                                                            object:self
                                                          userInfo:userInfo];
    }

    if (collapseChildren) {
        int i,numberOfChildren=numberOfChildrenOfItemAndReload(self,item,YES);

        for (i = 0; i < numberOfChildren; ++i) {
            id child = [_dataSource outlineView:self child:i ofItem:item];

            [self collapseItem:child collapseChildren:YES];
        }
    }

    if (_autoresizesOutlineColumn){
     [self _tightenUpColumn: _outlineTableColumn];
    }
    [self setNeedsDisplay:YES];
}

- (void)collapseItem:(id)item {
    [self collapseItem:item collapseChildren:NO];
}

-(void)_resetMapTables {
    NSResetMapTable(_rowToItem);
    NSResetMapTable(_itemToRow);
    NSResetMapTable(_itemToLevel);
   // NSResetMapTable(_itemToExpansionState);
    NSResetMapTable(_itemToNumberOfChildren);
}

-(void)reloadData {
   [self _resetMapTables];
   [self invalidateRowCache];
   [super reloadData];
}

- (void)reloadItem:(id)item reloadChildren:(BOOL)reloadChildren {
    [self _resetMapTables];
    [self invalidateRowCache];
    [self noteNumberOfRowsChanged];
    [self setNeedsDisplay:YES];
}

-(void)reloadItem:(id)item {
    [self reloadItem:item reloadChildren:NO];
}

-(void)setDropItem:(id)item dropChildIndex:(int)index {
    NSUnimplementedMethod();
}

-(BOOL)shouldCollapseAutoExpandedItemsForDeposited:(BOOL)collapse {
    if (collapse)
        return NO;
    
    return YES;
}


// override for new outline-related selectors.
-(void)setDataSource:dataSource {
    SEL requiredSelectors[] = {
        @selector(outlineView:child:ofItem:),
        @selector(outlineView:isItemExpandable:),
        @selector(outlineView:numberOfChildrenOfItem:),
        @selector(outlineView:objectValueForTableColumn:byItem:),
        NULL};
    int i;

    for (i = 0; requiredSelectors[i] != NULL; ++i)
        if (dataSource!=nil && ![dataSource respondsToSelector:requiredSelectors[i]])
            [NSException raise:NSInternalInconsistencyException
                        format:@"NSOutlineView dataSource does not respond to %@", NSStringFromSelector(requiredSelectors[i])];

    _dataSource=dataSource;
}

-(void)setDelegate:delegate {
    struct {
        NSString *name;
        SEL selector;
    } notes [] = {
      { NSOutlineViewItemWillExpandNotification, @selector(outlineViewItemWillExpand:) },
      { NSOutlineViewItemDidExpandNotification, @selector(outlineViewItemDidExpand:) },
      { NSOutlineViewItemWillCollapseNotification, @selector(outlineViewItemWillCollapse:) },
      { NSOutlineViewItemDidCollapseNotification, @selector(outlineViewItemDidCollapse:) },
      { NSOutlineViewColumnDidMoveNotification, @selector(outlineViewColumnDidMove:) },
      { NSOutlineViewColumnDidResizeNotification, @selector(outlineViewColumnDidResize:) },
      { NSOutlineViewSelectionIsChangingNotification, @selector(outlineViewSelectionIsChanging:) },
      { NSOutlineViewSelectionDidChangeNotification, @selector(outlineViewSelectionDidChange:) },
      { nil, NULL }
    };
    int i;

    if (_delegate != nil)
        for (i = 0; notes[i].name != nil; ++i)
            [[NSNotificationCenter defaultCenter] removeObserver:_delegate name:notes[i].name object:self];

    _delegate=delegate;

    for (i = 0; notes[i].name != nil; ++i)
        if ([_delegate respondsToSelector:notes[i].selector])
            [[NSNotificationCenter defaultCenter] addObserver:_delegate
                                                     selector:notes[i].selector
                                                         name:notes[i].name
                                                       object:self];
}

static void loadItemIntoMapTables(NSOutlineView *self,id item,unsigned *rowCountPtr,unsigned recursionLevel,NSHashTable *removeItems){
    int i,numberOfChildren=numberOfChildrenOfItemAndReload(self,item,YES);

    for (i = 0; i < numberOfChildren; ++i) {
        id child = [self->_dataSource outlineView:self child:i ofItem:item];

        NSHashRemove(removeItems,child);

     //   NSLog(@"got child %@ for row %d, level %d", child, *rowCountPtr, recursionLevel);

        NSMapInsert(self->_rowToItem, (void *)(*rowCountPtr), child);
        NSMapInsert(self->_itemToRow, child, (void *)(*rowCountPtr));
        NSMapInsert(self->_itemToLevel, child, (void *)recursionLevel);

        (*rowCountPtr)++;

       if(isItemExpanded(self,child))
        loadItemIntoMapTables(self,child,rowCountPtr,recursionLevel+1,removeItems);
    }
}

-(void)loadRootItem {
   NSHashTable    *removeItems=NSCreateHashTable(NSNonOwnedPointerHashCallBacks,0);

   {
    NSMapEnumerator state=NSEnumerateMapTable(_itemToExpansionState);
    void           *key,*value;

    while(NSNextMapEnumeratorPair(&state,&key,&value))
     NSHashInsert(removeItems,key);
   }

   loadItemIntoMapTables(self,nil,&_numberOfCachedRows,0,removeItems);

   {
    NSHashEnumerator state=NSEnumerateHashTable(removeItems);
    void            *key;

    while((key= NSNextHashEnumeratorItem(&state))!=NULL)
     NSMapRemove(_itemToExpansionState,key);

   }
}

-(int)numberOfRows {
   if (_numberOfCachedRows == 0) {
    [self loadRootItem];
    return _numberOfCachedRows;
   }

   return _numberOfCachedRows;
}

// NOTE caution with the self/super distinctions as these methods call each other and/or
- (NSRect)frameOfMarkerCellAtColumn:(int)column row:(int)row level:(int)level {
    NSRect cellRect = [super frameOfCellAtColumn:column row:row];
    float indentPixels = level * _indentationPerLevel;
    
    cellRect.size.width = indentPixels;

    if (_indentationMarkerFollowsCell)
        cellRect.origin.x += cellRect.size.width;

    cellRect.size.width = _indentationPerLevel;

    return cellRect;
}

- (NSRect)_adjustedFrameOfCellAtColumn:(int)column row:(int)row objectValue:(id)objectValue {
    NSRect cellRect = [super frameOfCellAtColumn:column row:row];
    NSTableColumn *tableColumn = [_tableColumns objectAtIndex:column];

    if (tableColumn == _outlineTableColumn) {
        NSCell *dataCell = [tableColumn dataCellForRow:row];
        float indentPixels = [self levelForRow:row] * _indentationPerLevel;
        float cellWidth;
        
        cellRect.origin.x += (indentPixels + _rowHeight) + _intercellSpacing.width;

#if 0
        // this is more NSTableView-ish behavior.
        cellRect.size.width -= (indentPixels + _rowHeight);
#endif
        
        // instead, give the delegate an opportunity to provide the cell width. (i was keying on attributed
        // string value width, but this broke when i tried to use an NSBrowserCell, naturally..

        if([_delegate respondsToSelector:@selector(outlineView:widthOfCell:forTableColumn:byItem:)]){
         cellWidth = [_delegate outlineView:self widthOfCell:dataCell forTableColumn:tableColumn byItem:[self itemAtRow:row]] + _intercellSpacing.width;
        }
        else {
         [dataCell setObjectValue:objectValue];

         cellWidth=[[dataCell attributedStringValue] size].width + _intercellSpacing.width;
        }

        // since we shrink the cell frame to fit the title, when editing occurs, we need to pad
        // the frame slightly so that the entire title will be visible in the editing cell
        // (space permitting in the column)
        if (column == _editedColumn && row == _editedRow)
            cellWidth += _editingCellPadding;

        cellRect.size.width = MIN(cellWidth, cellRect.size.width - (indentPixels + _rowHeight));        
    }

    return cellRect;
}

-(NSRect)frameOfCellAtColumn:(int)column row:(int)row {
   NSTableColumn *tableColumn=[_tableColumns objectAtIndex:column];

   if(tableColumn ==_outlineTableColumn){
    id objectValue=[self _objectValueForTableColumn:tableColumn byItem:[self itemAtRow:row]];

    return [self _adjustedFrameOfCellAtColumn:column row:row objectValue:objectValue];
   }

   return [super frameOfCellAtColumn:column row:row];
}

-(void)drawHighlightedSelectionForColumn:(int)column row:(int)row inRect:(NSRect)rect
{
    if ([_tableColumns objectAtIndex:column] == _outlineTableColumn) {
        NSRect newRect = NSInsetRect(rect,1,0);
        // NSDottedFrameRect is kinda weird
        newRect.origin.y++;
        newRect.size.height--;
        [super drawHighlightedSelectionForColumn:column row:row inRect:newRect];
        NSDottedFrameRect(rect);
    }
    else
        [super drawHighlightedSelectionForColumn:column row:row inRect:rect];
}

-(void)_drawGridForItem:(id)item context:(CGContext *)context level:(int)level {
    int column = [_tableColumns indexOfObject:_outlineTableColumn];
    int row = [self rowForItem:item];
    NSRect myFrame = [self frameOfMarkerCellAtColumn:column row:row level:level];

    if (level > 0) {
        NSRect rect = myFrame;

        // it is safe to assume that all marker cells are the same size.
        rect.origin.x -= rect.size.width/2;
        rect.size.width += rect.size.width/2;
        rect.origin.y += (rect.size.height/2)-1;
        rect.size.height = 1;

        NSInterfaceDrawOutlineGrid(rect,context);
    }
    
   if (isItemExpanded(self,item)) {
    int i,numberOfChildren=numberOfChildrenOfItemAndReload(self,item,NO);
    id  lastChild=nil;

    for(i=0;i<numberOfChildren;i++){
     lastChild=childOfItemAtIndex(self,item,i);
     [self _drawGridForItem:lastChild context:context level:level+1];
    }

    if(lastChild!=nil){
     NSRect rect=myFrame;
     NSRect lastChildRect=[self frameOfMarkerCellAtColumn:column row:[self rowForItem:lastChild] level:level+1];
     float  delta=lastChildRect.origin.y - myFrame.origin.y;

         // it is safe to assume that all rows are the same height.
     rect.origin.x += (rect.size.width/2)-1;
     rect.size.width = 1;
     rect.origin.y += rect.size.height/2;
     rect.size.height = delta;

     NSInterfaceDrawOutlineGrid(rect,context);
    }
   }
}

-(void)drawGridInClipRect:(NSRect)aRect {
    // this doesn't look right at all when the indentation marker isn't set to follow the cell
    CGContext *context=NSCurrentGraphicsPort();
    BOOL temp = _indentationMarkerFollowsCell;
    int  i,count=numberOfChildrenOfItemAndReload(self,nil,NO);

    [[NSColor grayColor] set];

    [self setIndentationMarkerFollowsCell:YES];
    for(i=0;i<count;i++)
     [self _drawGridForItem:childOfItemAtIndex(self,nil,i) context:context level:0];
    [self setIndentationMarkerFollowsCell:temp];
}

-(void)drawRow:(int)row clipRect:(NSRect)rect {
    NSRange visibleColumns = [self columnsInRect:rect];
    int drawThisColumn = visibleColumns.location;

    if (row < 0 || row >= _numberOfRows)
        [NSException raise:NSInvalidArgumentException format:@"invalid row in drawRow:clipRect:"];

    while (drawThisColumn < NSMaxRange(visibleColumns)) {
        NSTableColumn *column = [_tableColumns objectAtIndex:drawThisColumn];
        NSTextFieldCell *dataCell = (NSTextFieldCell *)[column dataCellForRow:row];
        id item = [self itemAtRow:row];

        if (!(row == _editedRow && drawThisColumn == _editedColumn)) {
         id objectValue=[self _objectValueForTableColumn:column byItem:item];

            [dataCell setObjectValue:objectValue];
            
            if ([dataCell type] == NSTextCellType) {
                if ([self isRowSelected:row] || [self isColumnSelected:drawThisColumn])
                    [dataCell setTextColor:[NSColor selectedTextColor]];
                else 
                    [dataCell setTextColor:[NSColor textColor]];
            }

            // special outline behavior. we indent the entire cell so as not to rely on a custom
            // NSCell class (who knows what you might want in the outline view?)
            if ([_tableColumns objectAtIndex:drawThisColumn] == _outlineTableColumn) {
                if ([self isExpandable:item]) {
                    if (isItemExpanded(self,item))
                        [_markerCell setState:NSOnState];
                    else
                        [_markerCell setState:NSOffState];

                    if ([_delegate respondsToSelector:@selector(outlineView:willDisplayOutlineCell:forTableColumn:item:)])
                        [_delegate outlineView:self willDisplayOutlineCell:_markerCell forTableColumn:column item:item];

                    [_markerCell drawWithFrame:[self frameOfMarkerCellAtColumn:drawThisColumn row:row level:[self levelForRow:row]]
                                        inView:self];
                }
            }

            if ([_delegate respondsToSelector:@selector(outlineView:willDisplayCell:forTableColumn:item:)])
                [_delegate outlineView:self willDisplayCell:dataCell forTableColumn:column item:item];

            [dataCell drawWithFrame:NSInsetRect([self _adjustedFrameOfCellAtColumn:drawThisColumn row:row objectValue:objectValue], _intercellSpacing.width/2, _intercellSpacing.height/2)
                             inView:self];
        }
        
        drawThisColumn++;
    }
}

// intercept mouse clicks destined for the "dead space" in the indented area or the triangle.
// proper adjustment of the highlighted area in the outline column is performed elsewhere.
-(void)mouseDown:(NSEvent *)event {
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];

    _clickedColumn = [self columnAtPoint:location];
    _clickedRow = [self rowAtPoint:location];
    _clickedItem = [self itemAtRow:_clickedRow];

    if ([_tableColumns objectAtIndex:_clickedColumn] == _outlineTableColumn) {
        if (NSPointInRect(location, [self frameOfMarkerCellAtColumn:_clickedColumn row:_clickedRow level:[self levelForRow:_clickedRow]]) &&
            [self isExpandable:_clickedItem]) {
            if (isItemExpanded(self,_clickedItem) == NO)
                [self expandItem:_clickedItem];
            else
                [self collapseItem:_clickedItem];
            
            return;
        }
    }

    [super mouseDown:event];
}

//
// NSTableColumn delegate override methods
//
-(BOOL)delegateShouldSelectTableColumn:(NSTableColumn *)tableColumn {
    if ([_delegate respondsToSelector:@selector(outlineView:shouldSelectTableColumn:)])
        return [_delegate outlineView:self shouldSelectTableColumn:tableColumn];

    return YES;
}

-(BOOL)delegateShouldSelectRow:(int)row
{
    if ([_delegate respondsToSelector:@selector(outlineView:shouldSelectItem:)])
        return [_delegate outlineView:self shouldSelectItem:[self itemAtRow:row]];

    return YES;
}

- (BOOL)delegateShouldEditTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if ([_delegate respondsToSelector:@selector(outlineView:shouldEditTableColumn:item:)])
        return [_delegate outlineView:self shouldEditTableColumn:tableColumn item:[self itemAtRow:row]];

    return YES;
}

-(BOOL)delegateSelectionShouldChange
{
    if ([_delegate respondsToSelector:@selector(selectionShouldChangeInOutlineView:)])
        return [_delegate selectionShouldChangeInOutlineView:self];

    return YES;
}

-(void)noteSelectionIsChanging {
    [[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewSelectionIsChangingNotification
                                                        object:self];
}

-(void)noteSelectionDidChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewSelectionDidChangeNotification
                                                        object:self];
}

-(void)noteColumnDidResizeWithOldWidth:(float)oldWidth
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSOutlineViewColumnDidResizeNotification
            object:self
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithFloat:oldWidth], @"NSOldWidth", nil]];
}

-(BOOL)dataSourceCanSetObjectValue
{
    return [_dataSource respondsToSelector:@selector(outlineView:setObjectValue:forTableColumn:byItem:)];
}

-(void)dataSourceSetObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    [_dataSource outlineView:self setObjectValue:object forTableColumn:tableColumn byItem:[self itemAtRow:row]];
}

-(id)dataSourceObjectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    return [_dataSource outlineView:self objectValueForTableColumn:tableColumn byItem:[self itemAtRow:row]];
}

@end
