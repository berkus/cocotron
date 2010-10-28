/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURLConnection.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURLProtocol.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSRaise.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSURLError.h>
#import <Foundation/NSURLCache.h>
#import <Foundation/NSCachedURLResponse.h>
#import <Foundation/NSError.h>
#import "NSURLConnectionState.h"

@interface NSURLProtocol(private)
+(Class)_URLProtocolClassForRequest:(NSURLRequest *)request;
-(void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
-(void)unscheduleFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
@end;

@interface NSURLConnection(private) <NSURLProtocolClient>
@end

@implementation NSURLConnection

+(BOOL)canHandleRequest:(NSURLRequest *)request {
   return ([NSURLProtocol _URLProtocolClassForRequest:request]!=nil)?YES:NO;
}

+(NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)responsep error:(NSError **)errorp {
   NSURLConnectionState *state=[[[NSURLConnectionState alloc] init] autorelease];
   NSURLConnection      *connection=[[self alloc] initWithRequest:request delegate:state];
   
   if(connection==nil){
   
    if(errorp!=NULL){
     *errorp=[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil];
    }
    
    return nil;
   }

   NSString *mode=@"NSURLConnectionRequestMode";
   
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
    
	[state receiveAllDataInMode:mode];
    [connection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:mode];

   NSData *result=[[connection->_mutableData retain] autorelease];

    [connection cancel];
    
   if(errorp!=NULL)
    *errorp=[state error];

   if(responsep!=NULL)
    *responsep=[[connection->_response retain] autorelease];
    
   [connection release];
 
   return result;
}

+(NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:delegate {
   return [[[self alloc] initWithRequest:request delegate:delegate] autorelease];
}

-initWithRequest:(NSURLRequest *)request delegate:delegate startImmediately:(BOOL)startLoading {
   _request=[request copy];
   Class cls=[NSURLProtocol _URLProtocolClassForRequest:request];
   
   if((_protocol=[[cls alloc] initWithRequest:_request cachedResponse:[[NSURLCache sharedURLCache] cachedResponseForRequest:_request] client:self])==nil){
    [self dealloc];
    return nil;
   }
   
   _delegate=[delegate retain];
   
   [self retain];

   if(startLoading)
    [self start];


   return self;
}

-initWithRequest:(NSURLRequest *)request delegate:delegate {
   return [self initWithRequest:request delegate:delegate startImmediately:YES];
}

-(void)dealloc {
   [_request release];
   [_protocol release];
   [_delegate release];
   [_response release];
   [_mutableData release];
   [super dealloc];
}

-(void)start {
   [_protocol startLoading];
}

-(void)cancel {
   [_protocol stopLoading];
   }

-(void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
   [_protocol scheduleInRunLoop:runLoop forMode:mode];
}

-(void)unscheduleFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {
   [_protocol unscheduleFromRunLoop:runLoop forMode:mode];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirect {
   [_delegate connection:self willSendRequest:request redirectResponse:redirect];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  // [_delegate connection:self didReceiveAuthenticationChallenge];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  // [_delegate connection:self didCancelAuthenticationChallenge];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didReceiveResponse:(NSURLResponse *)response cacheStoragePolicy:(NSURLCacheStoragePolicy)policy {
    _response=[response retain];
    _storagePolicy=policy;
    
   if([_delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
    [_delegate connection:self didReceiveResponse:response];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol cachedResponseIsValid:(NSCachedURLResponse *)cachedResponse {
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didLoadData:(NSData *)data {

   if(_mutableData==nil)
    _mutableData=[[NSMutableData alloc] init];
    
   [_mutableData appendData:data];
   
   [_delegate connection:self didReceiveData:data];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didFailWithError:(NSError *)error {
   [_delegate connection:self didFailWithError:error];
   
   [self autorelease];
}

-(void)URLProtocolDidFinishLoading:(NSURLProtocol *)urlProtocol {
   if(_storagePolicy==NSURLCacheStorageNotAllowed){
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_request];
   }
   else {
    NSCachedURLResponse *cachedResponse=[[NSCachedURLResponse alloc] initWithResponse:_response data:_mutableData userInfo:nil storagePolicy:_storagePolicy];
   
    if([_delegate respondsToSelector:@selector(connection:willCacheResponse:)])
     cachedResponse=[_delegate connection:self willCacheResponse:cachedResponse];

    if(cachedResponse!=nil){
     [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:_request];
    }
   }
   
	if([_delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		[_delegate performSelector:@selector(connectionDidFinishLoading:) withObject:self];
        
   [self autorelease];
}


@end
