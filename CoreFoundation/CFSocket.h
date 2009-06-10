/* Copyright (c) 2008-2009 Christopher J. W. Lloyd

Permission is hereby granted,free of charge,to any person obtaining a copy of this software and associated documentation files (the "Software"),to deal in the Software without restriction,including without limitation the rights to use,copy,modify,merge,publish,distribute,sublicense,and/or sell copies of the Software,and to permit persons to whom the Software is furnished to do so,subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS",WITHOUT WARRANTY OF ANY KIND,EXPRESS OR IMPLIED,INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,DAMAGES OR OTHER LIABILITY,WHETHER IN AN ACTION OF CONTRACT,TORT OR OTHERWISE,ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFDate.h>
#import <CoreFoundation/CFRunLoop.h>

typedef struct __NSSocket *CFSocketRef;

typedef struct  {
   CFInteger protocolFamily;
   CFInteger socketType;
   CFInteger protocol;
   CFDataRef address;
} CFSocketSignature;

typedef enum  {
   kCFSocketNoCallBack     =0,
   kCFSocketReadCallBack   =1,
   kCFSocketAcceptCallBack =2,
   kCFSocketDataCallBack   =3,
   kCFSocketConnectCallBack=4,
   kCFSocketWriteCallBack  =8,
} CFSocketCallBackType;

enum {
   kCFSocketAutomaticallyReenableReadCallBack  =1,
   kCFSocketAutomaticallyReenableAcceptCallBack=2,
   kCFSocketAutomaticallyReenableDataCallBack  =3,
   kCFSocketAutomaticallyReenableWriteCallBack =8,
   kCFSocketCloseOnInvalidate                  =128,
};

typedef enum  {
   kCFSocketSuccess = 0,
   kCFSocketError   =-1,
   kCFSocketTimeout =-2,
} CFSocketError;

typedef void (*CFSocketCallBack)(CFSocketRef self,CFSocketCallBackType callbackType,CFDataRef address,const void *data,void *info);

typedef struct  {
   CFIndex                            version;
   void                              *info;
   CFAllocatorRetainCallBack          retain;
   CFAllocatorReleaseCallBack         release;
   CFAllocatorCopyDescriptionCallBack copyDescription;
} CFSocketContext;

typedef int CFSocketNativeHandle;

CFTypeID CFSocketGetTypeID();

CFSocketRef CFSocketCreate(CFAllocatorRef allocator,CFInteger protocolFamily,CFInteger socketType,CFInteger protocol,CFOptionFlags flags,CFSocketCallBack callback,const CFSocketContext *context);
CFSocketRef CFSocketCreateConnectedToSocketSignature(CFAllocatorRef allocator,const CFSocketSignature *signature,CFOptionFlags flags,CFSocketCallBack callback,const CFSocketContext *context,CFTimeInterval timeout);

CFSocketRef          CFSocketCreateWithNative(CFAllocatorRef allocator,CFSocketNativeHandle native,CFOptionFlags flags,CFSocketCallBack callback,const CFSocketContext *context);
CFSocketRef          CFSocketCreateWithSocketSignature(CFAllocatorRef allocator,const CFSocketSignature *signature,CFOptionFlags flags,CFSocketCallBack callback,const CFSocketContext *context);

CFSocketError        CFSocketConnectToAddress(CFSocketRef self,CFDataRef address,CFTimeInterval timeout);
CFDataRef            CFSocketCopyAddress(CFSocketRef self);
CFDataRef            CFSocketCopyPeerAddress(CFSocketRef self);
CFRunLoopSourceRef   CFSocketCreateRunLoopSource(CFAllocatorRef allocator,CFSocketRef self,CFIndex order);
void                 CFSocketDisableCallBacks(CFSocketRef self,CFOptionFlags flags);
void                 CFSocketEnableCallBacks(CFSocketRef self,CFOptionFlags flags);
void                 CFSocketGetContext(CFSocketRef self,CFSocketContext *context);
CFSocketNativeHandle CFSocketGetNative(CFSocketRef self);
CFOptionFlags        CFSocketGetSocketFlags(CFSocketRef self);

void                 CFSocketInvalidate(CFSocketRef self);
Boolean              CFSocketIsValid(CFSocketRef self);
CFSocketError        CFSocketSendData(CFSocketRef self,CFDataRef address,CFDataRef data,CFTimeInterval timeout);
CFSocketError        CFSocketSetAddress(CFSocketRef self,CFDataRef address);
void                 CFSocketSetSocketFlags(CFSocketRef self,CFOptionFlags flags);

