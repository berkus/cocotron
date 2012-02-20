/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSObject.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSHashTable.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSString.h>
#import <Foundation/NSAutoreleasePool-private.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSRaise.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "forwarding.h"


BOOL NSObjectIsKindOfClass(id object, Class kindOf)
{
#if defined(GCC_RUNTIME_3) || defined(APPLE_RUNTIME_4)
    Class class = object_getClass(object);
#else
    struct objc_class *class = object->isa;
#endif

#if defined(GCC_RUNTIME_3) || defined(APPLE_RUNTIME_4)
    for (;class != 0; class = class_getSuperclass(class)) {
#else
    for (;class != 0; class = class->super_class) {
#endif
        if (kindOf == class) {
            return YES;
        }
#if defined(GCC_RUNTIME_3) || defined(APPLE_RUNTIME_4)
        if (object_getClass(object_getClass(class)) == class) {
#else
        if (class->isa->isa == class) {
#endif
            break;
        }
    }

    return NO;
}


@interface NSInvocation(private)
+(NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)signature arguments:(void *)arguments;
@end

@implementation NSObject

+(NSInteger)version {
   return class_getVersion(self);
}


+(void)setVersion:(NSInteger)version {
   class_setVersion(self,version);
}

+(void)load {
}


+(void)initialize {
#ifdef GCC_RUNTIME_3
    __objc_msg_forward2 = objc_msg_forward;
#else
    objc_setForwardHandler(objc_msgForward,objc_msgForward_stret);
#endif
}

+(Class)superclass {
   return class_getSuperclass(self);
}


+(Class)class {
   return self;
}

+(BOOL)isSubclassOfClass:(Class)cls {
    Class       myClass;
    
    myClass = (Class)self;
    while (myClass != Nil) {
        if (myClass == cls) {
            return YES;
        }
        myClass = [myClass superclass];
    }
    
    return NO;
}

+(BOOL)instancesRespondToSelector:(SEL)selector {
   return class_respondsToSelector(self,selector);
}

+(BOOL)conformsToProtocol:(Protocol *)protocol {
   return class_conformsToProtocol(self,protocol);
}


+(IMP)methodForSelector:(SEL)selector {
   return class_getMethodImplementation(object_getClass(self),selector);
}

+(IMP)instanceMethodForSelector:(SEL)selector {
   return class_getMethodImplementation(self,selector);
}

+(NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)selector {
   Method      method=class_getInstanceMethod(self,selector);
   const char *types=method_getTypeEncoding(method);

   return (types==NULL)?(NSMethodSignature *)nil:[NSMethodSignature signatureWithObjCTypes:types];
}

+(BOOL)resolveClassMethod:(SEL)selector {
   // do nothing
   return NO;
}

+(BOOL)resolveInstanceMethod:(SEL)selector {
   // do nothing
   return NO;
}

+copyWithZone:(NSZone *)zone {
   return self;
}


+mutableCopyWithZone:(NSZone *)zone {
   NSInvalidAbstractInvocation();
   return nil;
}

+ (void)poseAsClass:(Class)aClass
{
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    NSUnimplementedMethod();
    [pool release];
}


+(NSString *)description {
   return NSStringFromClass(self);
}

+alloc {
   return [self allocWithZone:NULL];
}


+allocWithZone:(NSZone *)zone {
   return NSAllocateObject([self class],0,zone);
}


-(void)dealloc {
   NSDeallocateObject(self);
}

-(void)finalize {
   // do nothing
}

-init {
   return self;
}


+new {
   return [[self allocWithZone:NULL] init];
}


+(void)dealloc {
}


-copy {
   return [(id <NSCopying>)self copyWithZone:NULL];
}


-mutableCopy {
   return [(id <NSMutableCopying>)self mutableCopyWithZone:NULL];
}

-(Class)classForCoder {
   return isa;
}

-(Class)classForArchiver {
   return [self classForCoder];
}

-(Class)classForKeyedArchiver {
	return [self classForCoder];
}

-replacementObjectForCoder:(NSCoder *)coder {
   return self;
}


-awakeAfterUsingCoder:(NSCoder *)coder {
   return self;
}

-(IMP)methodForSelector:(SEL)selector {
   return class_getMethodImplementation(isa,selector);
}

-(void)doesNotRecognizeSelector:(SEL)selector {
   [NSException raise:NSInvalidArgumentException
     format:@"%c[%@ %@]: selector not recognized", class_isMetaClass(isa)?'+':'-',
      NSStringFromClass(isa),NSStringFromSelector(selector)];
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
   Method      method=class_getInstanceMethod(isa,selector);
   const char *types=method_getTypeEncoding(method);

   return (types==NULL)?(NSMethodSignature *)nil:[NSMethodSignature signatureWithObjCTypes:types];
}

-(void)forwardInvocation:(NSInvocation *)invocation {
   [self doesNotRecognizeSelector:[invocation selector]];
}

-(NSUInteger)_frameLengthForSelector:(SEL)selector {
   NSMethodSignature *signature=[self methodSignatureForSelector:selector];

   return [signature frameLength];
}

-(id)forwardSelector:(SEL)selector arguments:(void *)arguments {
   NSMethodSignature *signature=[self methodSignatureForSelector:selector];

   if(signature==nil){
    [self doesNotRecognizeSelector:selector];
    return nil;
   }
   else {
    NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:signature arguments:arguments];
   // char          result[[signature methodReturnLength]];
    id              result;

    [self forwardInvocation:invocation];
    [invocation getReturnValue:&result];

   // __builtin_return(result); Can we use __builtin_return like this? It still doesn't seem to work on float/doubles ?
    return result;
   }
}



-(NSUInteger)hash {
   return (NSUInteger)self>>4;
}


-(BOOL)isEqual:object {
   return (self==object)?YES:NO;
}


-self {
   return self;
}


-(Class)class {
   return isa;
}


-(Class)superclass {
   return class_getSuperclass(isa);
}


-(NSZone *)zone {
   return NSZoneFromPointer(self);
}


- performSelector:(SEL)selector
{
#if defined(GCC_RUNTIME_3) || defined(APPLE_RUNTIME_4)
    IMP imp = class_getMethodImplementation(object_getClass(self), selector);
#else
    IMP imp = objc_msg_lookup(self, selector);
#endif
    return imp(self, selector);
}


- performSelector:(SEL)selector withObject:object0
{
#if defined(GCC_RUNTIME_3) || defined(APPLE_RUNTIME_4)
    IMP imp = class_getMethodImplementation(object_getClass(self), selector);
#else
    IMP imp = objc_msg_lookup(self, selector);
#endif
    return imp(self, selector, object0);
}

- performSelector:(SEL)selector withObject:object0 withObject:object1
{
#if defined(GCC_RUNTIME_3) || defined(APPLE_RUNTIME_4)
    IMP imp = class_getMethodImplementation(object_getClass(self), selector);
#else
    IMP imp = objc_msg_lookup(self, selector);
#endif
    return imp(self, selector, object0, object1);
}


-(BOOL)isProxy {
   return NO;
}


-(BOOL)isKindOfClass:(Class)class {
   return NSObjectIsKindOfClass(self,class);
}


-(BOOL)isMemberOfClass:(Class)class {
   return (isa==class);
}


-(BOOL)conformsToProtocol:(Protocol *)protocol {
   return [isa conformsToProtocol:protocol];
}


-(BOOL)respondsToSelector:(SEL)selector {
   return class_respondsToSelector(isa,selector);
}


-autorelease {
   return NSAutorelease(self);
}


+autorelease {
   return self;
}


-(oneway void)release {
   if(NSDecrementExtraRefCountWasZero(self))
    [self dealloc];
}


+(oneway void)release {
}


-retain {
   NSIncrementExtraRefCount(self);
   return self;
}


+retain {
   return self;
}


-(NSUInteger)retainCount {
   return NSExtraRefCount(self);
}

+(NSString *)className {
   return NSStringFromClass(self);
}

-(NSString *)className {
   return NSStringFromClass(isa);
}

-(NSString *)description {
   return [NSString stringWithFormat:@"<%@ 0x%08x>",[self class],self];
}

@end

#import <Foundation/NSCFTypeID.h>

@implementation NSObject (CFTypeID)

- (unsigned) _cfTypeID
{
   return kNSCFTypeObject;
}

@end
