#import <AppKit/NSViewController.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSNib.h>
#import <AppKit/NSRaise.h>

@implementation NSViewController

-initWithNibName:(NSString *)name bundle:(NSBundle *)bundle {
   _nibName=[name copy];
   _nibBundle=[bundle retain];
   return self;
}

-(NSString *)nibName {
   return _nibName;
}

-(NSBundle *)nibBundle {
   return _nibBundle;
}

-(NSView *)view {
   if(_view==nil)
    [self loadView];
    
   return _view;
}

-(NSString *)title {
   return _title;
}

-representedObject {
   return _representedObject;
}

-(void)setRepresentedObject:object {
   object=[object retain];
   [_representedObject release];
   _representedObject=object;
}

-(void)setTitle:(NSString *)value {
   value=[value retain];
   [_title release];
   _title=value;
}

-(void)setView:(NSView *)value {
   value=[value retain];
   [_view release];
   _view=value;
}

-(void)loadView {
   NSString *name=[self nibName];
   NSBundle *bundle=[self nibBundle];

   if(bundle==nil)
    bundle=[NSBundle mainBundle];

   NSString     *path=[bundle pathForResource:name ofType:@"nib"];
   NSDictionary *nameTable=[NSDictionary dictionaryWithObject:self forKey:NSNibOwner];

   if(path==nil)
    NSLog(@"NSViewController unable to find nib named %@, bundle=%@",name,bundle);    

   [bundle loadNibFile:path externalNameTable:nameTable withZone:NULL];
}

-(void)discardEditing {
   NSUnimplementedMethod();
}

-(BOOL)commitEditing {
   NSUnimplementedMethod();
   return NO;
}

-(void)commitEditingWithDelegate:delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo {
   NSUnimplementedMethod();
}

@end
