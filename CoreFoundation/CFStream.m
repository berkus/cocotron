#import <CoreFoundation/CFStream.h>
#import <Foundation/NSString.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSInputStream_socket.h>
#import <Foundation/NSOutputStream_socket.h>
#import <Foundation/NSHost.h>

@interface __CFStream : NSStream
@end
@interface __CFReadStream : NSInputStream
@end
@interface __CFWriteStream : NSOutputStream
@end

const CFStringRef kCFStreamPropertyFileCurrentOffset=(CFStringRef)@"kCFStreamPropertyFileCurrentOffset";
const CFStringRef kCFStreamPropertyAppendToFile=(CFStringRef)@"kCFStreamPropertyAppendToFile";
const CFStringRef kCFStreamPropertyDataWritten=(CFStringRef)@"kCFStreamPropertyDataWritten";
const CFStringRef kCFStreamPropertySocketNativeHandle=(CFStringRef)@"kCFStreamPropertySocketNativeHandle";
const CFStringRef kCFStreamPropertySocketRemoteHostName=(CFStringRef)@"kCFStreamPropertySocketRemoteHostName";
const CFStringRef kCFStreamPropertySocketRemotePortNumber=(CFStringRef)@"kCFStreamPropertySocketRemotePortNumber";

void CFStreamCreateBoundPair(CFAllocatorRef allocator,CFReadStreamRef *readStream,CFWriteStreamRef *writeStream,CFIndex bufferSize) {
   NSUnimplementedFunction();
}

void CFStreamCreatePairWithPeerSocketSignature(CFAllocatorRef allocator,const CFSocketSignature *signature,CFReadStreamRef *readStream,CFWriteStreamRef *writeStream) {
   NSUnimplementedFunction();
}

void CFStreamCreatePairWithSocket(CFAllocatorRef allocator,CFSocketNativeHandle sock,CFReadStreamRef *readStream,CFWriteStreamRef *writeStream) {
   NSUnimplementedFunction();
}


void CFStreamCreatePairWithSocketToHost(CFAllocatorRef allocator, CFStringRef hostName, CFUInteger port, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream)
{
    NSHost *host = [NSHost hostWithName:(NSString *)hostName];
    [NSStream getStreamsToHost:host port:port inputStream:readStream outputStream:writeStream];
    if (readStream != NULL) {
        [*readStream retain];
    }
    if (writeStream!=NULL) {
        [*writeStream retain];
    }
}


CFTypeID CFReadStreamGetTypeID(void) {
   NSUnimplementedFunction();
   return 0;
}

CFReadStreamRef CFReadStreamCreateWithBytesNoCopy(CFAllocatorRef allocator,const uint8_t *bytes,CFIndex length,CFAllocatorRef bytesDeallocator) {
   NSUnimplementedFunction();
   return 0;
}
CFReadStreamRef CFReadStreamCreateWithFile(CFAllocatorRef allocator,CFURLRef url) {
   NSUnimplementedFunction();
   return 0;
}


Boolean CFReadStreamSetClient(CFReadStreamRef self, CFOptionFlags events, CFReadStreamClientCallBack callback, CFStreamClientContext *context)
{
    if ([self isKindOfClass:[NSInputStream_socket class]]) {
        [(NSInputStream_socket *)self setClientEvents:events callBack:callback context:context];
        return TRUE;
    } else {
        NSUnimplementedFunction();
        return 0;
    }
}


CFTypeRef CFReadStreamCopyProperty(CFReadStreamRef self, CFStringRef key)
{
    return [[self propertyForKey:(NSString *)key] copy];
}


Boolean CFReadStreamSetProperty(CFReadStreamRef self, CFStringRef key, CFTypeRef value)
{
   return [self setProperty:(id)value forKey:(NSString *)key];
}


const uint8_t * CFReadStreamGetBuffer(CFReadStreamRef self,CFIndex limit,CFIndex *available) {
   NSUnimplementedFunction();
   return 0;
}


Boolean CFReadStreamOpen(CFReadStreamRef self)
{
    [self open];
    return TRUE;
}


void CFReadStreamClose(CFReadStreamRef self)
{
    [self close];
}


Boolean CFReadStreamHasBytesAvailable(CFReadStreamRef self)
{
    return [self hasBytesAvailable];
}


CFIndex CFReadStreamRead(CFReadStreamRef self, uint8_t *bytes, CFIndex length)
{
    return [self read:bytes maxLength:length];
}


CFErrorRef CFReadStreamCopyError(CFReadStreamRef self) {
   NSUnimplementedFunction();
   return 0;
}

CFStreamError CFReadStreamGetError(CFReadStreamRef self) {
   CFStreamError error={0,0};
   NSUnimplementedFunction();
   return error;
}

CFStreamStatus CFReadStreamGetStatus(CFReadStreamRef self) {
   NSUnimplementedFunction();
   return 0;
}


void CFReadStreamScheduleWithRunLoop(CFReadStreamRef self, CFRunLoopRef runLoop, CFStringRef mode)
{
    [self scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode];
}


void CFReadStreamUnscheduleFromRunLoop(CFReadStreamRef self, CFRunLoopRef runLoop, CFStringRef mode)
{
    [self removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode];
}


CFTypeID CFWriteStreamGetTypeID(void) {
   NSUnimplementedFunction();
   return 0;
}

CFWriteStreamRef CFWriteStreamCreateWithAllocatedBuffers(CFAllocatorRef allocator,CFAllocatorRef bufferAllocator) {
   NSUnimplementedFunction();
   return 0;
}
CFWriteStreamRef CFWriteStreamCreateWithBuffer(CFAllocatorRef allocator,uint8_t *bytes,CFIndex capacity) {
   NSUnimplementedFunction();
   return 0;
}
CFWriteStreamRef CFWriteStreamCreateWithFile(CFAllocatorRef allocator,CFURLRef url) {
   NSUnimplementedFunction();
   return 0;
}


Boolean CFWriteStreamSetClient(CFWriteStreamRef self, CFOptionFlags events, CFWriteStreamClientCallBack callback, CFStreamClientContext *context)
{
    if ([self isKindOfClass:[NSOutputStream_socket class]]) {
        [(NSOutputStream_socket *)self setClientEvents:events callBack:callback context:context];
        return TRUE;
    } else {
        NSUnimplementedFunction();
        return 0;
    }
}


CFTypeRef CFWriteStreamCopyProperty(CFWriteStreamRef self, CFStringRef key)
{
    return [[self propertyForKey:(NSString *)key] copy];
}


Boolean CFWriteStreamSetProperty(CFWriteStreamRef self, CFStringRef key, CFTypeRef value)
{
    return [self setProperty:(id)value forKey:(NSString *)key];
}


Boolean CFWriteStreamOpen(CFWriteStreamRef self)
{
    [self open];
    return TRUE;
}


void CFWriteStreamClose(CFWriteStreamRef self)
{
    [self close];
}


Boolean CFWriteStreamCanAcceptBytes(CFWriteStreamRef self)
{
    return [self hasSpaceAvailable];
}


CFIndex CFWriteStreamWrite(CFWriteStreamRef self, const uint8_t *bytes, CFIndex length)
{
    return [self write:bytes maxLength:length];
}


CFErrorRef CFWriteStreamCopyError(CFReadStreamRef self) {
   NSUnimplementedFunction();
   return 0;
}

CFStreamError CFWriteStreamGetError(CFWriteStreamRef self) {
   CFStreamError error={0,0};
   NSUnimplementedFunction();
   return error;
}

CFStreamStatus CFWriteStreamGetStatus(CFWriteStreamRef self) {
   NSUnimplementedFunction();
   return 0;
}


void CFWriteStreamScheduleWithRunLoop(CFWriteStreamRef self, CFRunLoopRef runLoop, CFStringRef mode)
{
    [self scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode];
}


void CFWriteStreamUnscheduleFromRunLoop(CFWriteStreamRef self, CFRunLoopRef runLoop, CFStringRef mode)
{
    [self removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode];
}
