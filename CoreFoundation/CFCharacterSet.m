#ifdef CF_ENABLED
#define COREFOUNDATION_INSIDE_BUILD 1
#import <CoreFoundation/CFCharacterSet.h>
#import <Foundation/NSRaise.h>

CFTypeID CFCharacterSetGetTypeID(void){
   NSUnimplementedFunction();
   return 0;
}


CFCharacterSetRef CFCharacterSetGetPredefined(CFCharacterSetPredefinedSet predefined){
   NSUnimplementedFunction();
   return 0;
}


CFCharacterSetRef CFCharacterSetCreateWithBitmapRepresentation(CFAllocatorRef allocator,CFDataRef data){
   NSUnimplementedFunction();
   return 0;
}

CFCharacterSetRef CFCharacterSetCreateWithCharactersInRange(CFAllocatorRef allocator,CFRange range){
   NSUnimplementedFunction();
   return 0;
}

CFCharacterSetRef CFCharacterSetCreateWithCharactersInString(CFAllocatorRef allocator,CFStringRef string){
   NSUnimplementedFunction();
   return 0;
}


CFCharacterSetRef CFCharacterSetCreateCopy(CFAllocatorRef allocator,CFCharacterSetRef self){
   NSUnimplementedFunction();
   return 0;
}


Boolean CFCharacterSetHasMemberInPlane(CFCharacterSetRef self,CFIndex plane){
   NSUnimplementedFunction();
   return 0;
}

Boolean CFCharacterSetIsCharacterMember(CFCharacterSetRef self,UniChar character){
   NSUnimplementedFunction();
   return 0;
}

Boolean CFCharacterSetIsLongCharacterMember(CFCharacterSetRef self,UTF32Char character){
   NSUnimplementedFunction();
   return 0;
}

Boolean CFCharacterSetIsSupersetOfSet(CFCharacterSetRef self,CFCharacterSetRef other){
   NSUnimplementedFunction();
   return 0;
}


CFDataRef CFCharacterSetCreateBitmapRepresentation(CFAllocatorRef allocator,CFCharacterSetRef self){
   NSUnimplementedFunction();
   return 0;
}

CFCharacterSetRef CFCharacterSetCreateInvertedSet(CFAllocatorRef allocator,CFCharacterSetRef self){
   NSUnimplementedFunction();
   return 0;
}


// mutable

CFMutableCharacterSetRef CFCharacterSetCreateMutable(CFAllocatorRef alloc){
   NSUnimplementedFunction();
   return 0;
}

CFMutableCharacterSetRef CFCharacterSetCreateMutableCopy(CFAllocatorRef allocator,CFCharacterSetRef self){
   NSUnimplementedFunction();
   return 0;
}


void CFCharacterSetAddCharactersInRange(CFMutableCharacterSetRef self,CFRange range){
   NSUnimplementedFunction();
}

void CFCharacterSetAddCharactersInString(CFMutableCharacterSetRef self,CFStringRef string){
   NSUnimplementedFunction();
}

void CFCharacterSetRemoveCharactersInRange(CFMutableCharacterSetRef self,CFRange range){
   NSUnimplementedFunction();
}

void CFCharacterSetRemoveCharactersInString(CFMutableCharacterSetRef self,CFStringRef string){
   NSUnimplementedFunction();
}

void CFCharacterSetIntersect(CFMutableCharacterSetRef self,CFCharacterSetRef other){
   NSUnimplementedFunction();
}

void CFCharacterSetUnion(CFMutableCharacterSetRef self,CFCharacterSetRef other){
   NSUnimplementedFunction();
}

void CFCharacterSetInvert(CFMutableCharacterSetRef self){
   NSUnimplementedFunction();
}
#endif


