/* Copyright (c) 2008-2009 Christopher J. W. Lloyd

Permission is hereby granted,free of charge,to any person obtaining a copy of this software and associated documentation files (the "Software"),to deal in the Software without restriction,including without limitation the rights to use,copy,modify,merge,publish,distribute,sublicense,and/or sell copies of the Software,and to permit persons to whom the Software is furnished to do so,subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS",WITHOUT WARRANTY OF ANY KIND,EXPRESS OR IMPLIED,INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,DAMAGES OR OTHER LIABILITY,WHETHER IN AN ACTION OF CONTRACT,TORT OR OTHERWISE,ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFRunLoop.h>

typedef struct __NSMachPort *CFMachPortRef;

typedef void (*CFMachPortCallBack)(CFMachPortRef self,void *msg,CFIndex size,void *info);
typedef void (*CFMachPortInvalidationCallBack)(CFMachPortRef self,void *info);

typedef struct {
   CFIndex                            version;
   void                              *info;
   CFAllocatorRetainCallBack          retain;
   CFAllocatorReleaseCallBack         release;
   CFAllocatorCopyDescriptionCallBack copyDescription;
} CFMachPortContext;

COREFOUNDATION_EXPORT CFTypeID                       CFMachPortGetTypeID(void);

COREFOUNDATION_EXPORT CFMachPortRef                  CFMachPortCreate(CFAllocatorRef allocator,CFMachPortCallBack callback,CFMachPortContext *context,Boolean *callerFreeInfo);
COREFOUNDATION_EXPORT CFMachPortRef                  CFMachPortCreateWithPort(CFAllocatorRef allocator,mach_port_t port,CFMachPortCallBack callback,CFMachPortContext *context,Boolean *callerFreeInfo);

COREFOUNDATION_EXPORT mach_port_t                    CFMachPortGetPort(CFMachPortRef self);
COREFOUNDATION_EXPORT void                           CFMachPortGetContext(CFMachPortRef self,CFMachPortContext *context);
COREFOUNDATION_EXPORT CFMachPortInvalidationCallBack CFMachPortGetInvalidationCallBack(CFMachPortRef self);
COREFOUNDATION_EXPORT void                           CFMachPortSetInvalidationCallBack(CFMachPortRef self,CFMachPortInvalidationCallBack callback);

COREFOUNDATION_EXPORT CFRunLoopSourceRef             CFMachPortCreateRunLoopSource(CFAllocatorRef allocator,CFMachPortRef self,CFIndex order);
COREFOUNDATION_EXPORT void                           CFMachPortInvalidate(CFMachPortRef self);
COREFOUNDATION_EXPORT Boolean                        CFMachPortIsValid(CFMachPortRef self);

