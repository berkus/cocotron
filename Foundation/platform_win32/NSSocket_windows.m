/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import "NSSocket_windows.h"
#import <Foundation/NSError.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>

// The treatment of SOCKET's as int's is lame, there should probably be a little more formality on the [fF]ileDescriptor methods (typedef int/SOCKET NSFileDescriptor?)
// What would be nice is enough API in NSFileHandle/NSStream to never need the fd
 
@implementation NSSocket(windows)

+allocWithZone:(NSZone *)zone {
   return NSAllocateObject([NSSocket_windows class],0,NULL);
}

@end

@implementation NSSocket_windows

static inline void byteZero(void *vsrc,int size){
   unsigned char *src=vsrc;
   int i;

   for(i=0;i<size;i++)
    src[i]=0;
}

+(void)initialize {
   DWORD   vR=MAKEWORD(2,2);
   WSADATA wsaData;
   
   WSAStartup(vR, &wsaData);
}

-initWithSocketHandle:(SOCKET)handle {
   _handle=handle;
   return self;
}

+socketWithSocketHandle:(SOCKET)handle {
   return [[[self alloc] initWithSocketHandle:handle] autorelease];
}

-(NSError *)errorForReturnValue:(int)returnValue {
   if(returnValue<0){
    return [NSError errorWithDomain:NSWINSOCKErrorDomain code:WSAGetLastError() userInfo:nil];
   }
   return nil;
}

-initTCPStream {
   NSError *error=[self errorForReturnValue:_handle=socket(PF_INET,SOCK_STREAM,IPPROTO_TCP)];
   if(error!=nil){
    [self dealloc];
    return nil;
   }
   return self;
}

-initUDPStream {
   NSError *error=[self errorForReturnValue:_handle=socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP)];
   if(error!=nil){
    [self dealloc];
    return nil;
   }
   return self;
}

-initWithFileDescriptor:(int)descriptor {
   SOCKET handle=(SOCKET)descriptor;
   u_long arg;
   
   if(ioctlsocket(handle,FIONREAD,&arg)!=0){
    [self dealloc];
    return nil;
   }
   
   return [self initWithSocketHandle:handle];
}

-(void)closeAndDealloc {
   [self close];
   [self dealloc];
}

-initConnectedToSocket:(NSSocket **)otherX {
   NSSocket_windows  *other;
   NSError           *error;
   struct sockaddr_in address;
   int                namelen;

   if([self initUDPStream]==nil)
    return nil;
    
   if((other=[[[NSSocket alloc] initUDPStream] autorelease])==nil){
    [self closeAndDealloc];
    return nil;
   }
     
   byteZero(&address,sizeof(struct sockaddr_in));
   address.sin_family=AF_INET;
   address.sin_addr.s_addr=inet_addr("127.0.0.1");
   address.sin_port=0;
   if((error=[self errorForReturnValue:bind(other->_handle,(struct sockaddr *)&address,sizeof(struct sockaddr_in))])!=nil){
    [self closeAndDealloc];
    [other closeAndDealloc];
    return nil;
   }
   
   namelen=sizeof(address);
   if((error=[self errorForReturnValue:getsockname(other->_handle,(struct sockaddr *)&address,&namelen)])!=nil){
    [self closeAndDealloc];
    [other closeAndDealloc];
    return nil;
   }

   if((error=[self errorForReturnValue:connect(_handle,(struct sockaddr *)&address,sizeof(struct sockaddr_in))])!=nil){
    [self closeAndDealloc];
    [other closeAndDealloc];
    return nil;
   }

   *otherX=other;
   return self;
}

-(int)fileDescriptor {
   return (int)_handle;
}

-(SOCKET)socketHandle {
   return _handle;
}

-(void)setSocketHandle:(SOCKET)handle {
   _handle=handle;
}

-(unsigned)hash {
   return (unsigned)_handle;
}

-(BOOL)isEqual:other {
   if(![other isKindOfClass:[NSSocket_windows class]])
    return NO;
    
   return (_handle==((NSSocket_windows *)other)->_handle)?YES:NO;
}

-(NSError *)close {
   return [self errorForReturnValue:closesocket(_handle)];
}

-(NSError *)setOperationWouldBlock:(BOOL)blocks {
   u_long onoff=blocks?NO:YES;

   return [self errorForReturnValue:ioctlsocket(_handle,FIONBIO,&onoff)];
}

-(BOOL)operationWouldBlock {
   return (WSAGetLastError()==WSAEWOULDBLOCK);
}

-(NSError *)connectToHost:(NSHost *)host port:(int)portNumber immediate:(BOOL *)immediate {
   BOOL     block=NO;
   NSArray *addresses=[host addresses];
   int      i,count=[addresses count];
   NSError *error=nil;
   
   *immediate=NO;

   if(!block){
    if((error=[self setOperationWouldBlock:NO])!=nil)
     return error;
   }
   
   for(i=0;i<count;i++){
    struct sockaddr_in try;
    NSString     *stringAddress=[addresses objectAtIndex:i];
    char          cString[[stringAddress cStringLength]+1];
    unsigned long address;
    
    [stringAddress getCString:cString];
    if((address=inet_addr(cString))==-1){
 // FIX
    }
    
    byteZero(&try,sizeof(struct sockaddr_in));
    try.sin_addr.s_addr=address;
    try.sin_family=AF_INET;
	short port=portNumber;
    try.sin_port=htons(port);

    if(connect(_handle,(struct sockaddr *)&try,sizeof(try))==0){
     if(!block){
      if((error=[self setOperationWouldBlock:YES])!=nil)
       return error;
     }
     *immediate=YES;
     return nil;
    }
    else if([self operationWouldBlock]){
     if(!block){
      if((error=[self setOperationWouldBlock:YES])!=nil)
       return error;
     }
     return nil;
    }
    else {
     error=[self errorForReturnValue:-1];
    }
   }

   if(error==nil)
    error=[NSError errorWithDomain:NSWINSOCKErrorDomain code:WSAHOST_NOT_FOUND userInfo:nil];
    
   return error;
}

-(BOOL)hasBytesAvailable {
   char buf[1];

   return (recv(_handle,buf,1,MSG_PEEK)==1)?YES:NO;
}

-(int)read:(unsigned char *)buffer maxLength:(unsigned)length {
   return recv(_handle,(void *)buffer,length,0);
}

-(int)write:(const unsigned char *)buffer maxLength:(unsigned)length {
   return send(_handle,(void *)buffer,length,0);
}

-(NSSocket *)acceptWithError:(NSError **)errorp {
   struct sockaddr addr;
   int             addrlen=sizeof(struct sockaddr);
   SOCKET          newSocket; 
   NSError        *error;
   
   error=[self errorForReturnValue:newSocket=accept(_handle,&addr,&addrlen)];
   if(*errorp!=nil)
    *errorp=error;
    
   return (error!=nil)?nil:[[[NSSocket_windows alloc] initWithSocketHandle:newSocket] autorelease];
}

@end

NSData *NSSocketAddressDataForNetworkOrderAddressBytesAndPort(const void *address,unsigned length,int port) {
#if 0
   if(length==4){ // IPV4
      char rdb[100]; // should be more than enough

          struct sockaddr_in
            ip4;
          
    memset(rdb, 0, sizeof rdb);
         // oogly
          sprintf(rdb, "%d.%d.%d.%d", rd[0], rd[1], rd[2], rd[3]);
          LOG(@"Found IPv4 <%s>", rdb);
          
          length = sizeof (struct sockaddr_in);
          memset(&ip4, 0, length);
          
          inet_pton(AF_INET, rdb, &ip4.sin_addr);
          ip4.sin_family = AF_INET;
          ip4.sin_port = htons(service->port);
          
          address = (struct sockaddr *) &ip4;
   }
   
   if(length==16){ // IPV6
#if defined( AF_INET6 )
      char rdb[INET6_ADDRSTRLEN];

          struct sockaddr_in6
            ip6;
          
    memset(rdb, 0, sizeof rdb);
          // Even more oogly
          sprintf(rdb, "%x%x:%x%x:%x%x:%x%x:%x%x:%x%x:%x%x:%x%x",
                       rd[0], rd[1], rd[2], rd[3],
                       rd[4], rd[5], rd[6], rd[7],
                       rd[8], rd[9], rd[10], rd[11],
                       rd[12], rd[13], rd[14], rd[15]);
          LOG(@"Found IPv6 <%s>", rdb);
          
          length = sizeof (struct sockaddr_in6);
          memset(&ip6, 0, length);
          
          inet_pton(AF_INET6, rdb, &ip6.sin6_addr);
#if ! defined( NOT_HAVE_SA_LEN )
          ip6.sin6_len = sizeof ip6;
#endif
          ip6.sin6_family = AF_INET6;
          ip6.sin6_port = htons(service->port);
          ip6.sin6_flowinfo = 0;
          ip6.sin6_scope_id = interfaceIndex;
          
          address = (struct sockaddr *) &ip6;
#endif
   }
#endif

   return nil;
}

