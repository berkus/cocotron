/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSPlatform.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSZombieObject.h>
#import <Foundation/NSPlatform_win32.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread-Private.h>

#import <windows.h>
#import <process.h>

NSUInteger NSPageSize(void) {
   SYSTEM_INFO info;

   GetSystemInfo(&info);

   return info.dwPageSize;
}

void *NSAllocateMemoryPages(NSUInteger byteCount) {
   return VirtualAlloc(NULL,byteCount,MEM_RESERVE|MEM_COMMIT,PAGE_READWRITE);
}

void NSDeallocateMemoryPages(void *pointer,NSUInteger byteCount) {
   VirtualFree(pointer,byteCount,MEM_RELEASE|MEM_DECOMMIT);
}

void NSCopyMemoryPages(const void *src,void *dst,NSUInteger byteCount) {
   const uint8_t *srcb=src;
   uint8_t       *dstb=dst;
   NSUInteger     i;

   for(i=0;i<byteCount;i++)
    dstb[i]=srcb[i];
}

NSUInteger NSRealMemoryAvailable(void) {
   MEMORYSTATUS status;

   status.dwLength=sizeof(status);

   GlobalMemoryStatus(&status);

   return status.dwTotalPhys;
}

static DWORD Win32ThreadStorageIndex() {
   static DWORD tlsIndex=TLS_OUT_OF_INDEXES;

   if(tlsIndex==TLS_OUT_OF_INDEXES)
    tlsIndex=TlsAlloc();

   if(tlsIndex==TLS_OUT_OF_INDEXES)
    Win32Assert("TlsAlloc");

   return tlsIndex;
}

NSZone *NSCreateZone(NSUInteger startSize,NSUInteger granularity,BOOL canFree){
   return NULL;
}

NSZone *NSDefaultMallocZone(void){
   return NULL;
}

void NSRecycleZone(NSZone *zone) {
}

void NSSetZoneName(NSZone *zone,NSString *name){

}

NSString *NSZoneName(NSZone *zone) {
   return @"zone";
}

NSZone *NSZoneFromPointer(void *pointer){
   return NULL;
}

void *NSZoneCalloc(NSZone *zone,NSUInteger numElems,NSUInteger numBytes){
   return calloc(numElems,numBytes);
}

void NSZoneFree(NSZone *zone,void *pointer){
   free(pointer);
}

void *NSZoneMalloc(NSZone *zone,NSUInteger size){
   return malloc(size);
}

void *NSZoneRealloc(NSZone *zone,void *pointer,NSUInteger size){
   if(pointer==NULL)
    return malloc(size);
   else
    return realloc(pointer,size);
}


void NSPlatformSetCurrentThread(NSThread *thread) {
	TlsSetValue(Win32ThreadStorageIndex(),thread);
}


NSThread *NSPlatformCurrentThread() {
    NSThread *thread=TlsGetValue(Win32ThreadStorageIndex());
	
	if(!thread) {
		// maybe NSThread is not +initialize'd
		[NSThread class];
		thread=TlsGetValue(Win32ThreadStorageIndex());
                if(!thread) {
                  thread = [NSThread alloc];
                  if(thread) {
                    NSPlatformSetCurrentThread(thread);
                    {
                      NSAutoreleasePool *pool = [NSAutoreleasePool new];
                      [thread init];
                      [pool release];
                    }
                  }
                }
		if(!thread)	{
			[NSException raise:NSInternalInconsistencyException format:@"No current thread"];
		}
	}

    return thread;
}

/* Create a new thread of execution. */
NSUInteger NSPlatformDetachThread(unsigned (*__stdcall func)(void *arg), void *arg) {
	uint32_t	threadId = 0;
	HANDLE win32Handle = (HANDLE)_beginthreadex(NULL, 0, func, arg, 0, &threadId);
	
	if (!win32Handle) {
		threadId = 0; // just to be sure
	}
	
	CloseHandle(win32Handle);
	return threadId;
}



void FoundationThreadCleanup()
{
  NSThread *thread = TlsGetValue(Win32ThreadStorageIndex());

  if(thread){
    [thread setExecuting:NO];
    [thread setFinished:YES];
    [thread release];
    NSPlatformSetCurrentThread(nil);
  }
}
