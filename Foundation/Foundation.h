/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#if !defined(__STDC_VERSION__)
  #define __STDC_VERSION__ 198900L
#elif (__STDC_VERSION__ < 199400L)
  #define __STDC_VERSION__ 199000L
#endif

#include <sys/types.h>
#import <stdlib.h>
#import <ctype.h>
#import <errno.h>
#import <float.h>
#import <limits.h>
#import <math.h>
#import <stdarg.h>
#import <stddef.h>
#import <stdio.h>
#import <string.h>
#import <assert.h>
#import <locale.h>
#import <setjmp.h>
#import <signal.h>
#import <time.h>
#if (__STDC_VERSION__ >= 199901L)
  #import <stdbool.h>
  #import <stdint.h>
  #import <inttypes.h>
#endif

#import <Foundation/FoundationErrors.h>
#import <Foundation/NSAffineTransform.h>
#import <Foundation/NSArchiver.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAssertionHandler.h>
#import <Foundation/NSAttributedString.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSByteOrder.h>
#import <Foundation/NSCachedURLResponse.h>
#import <Foundation/NSCalendar.h>
#import <Foundation/NSCalendarDate.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSClassDescription.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSCountedSet.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDateComponents.h>
#import <Foundation/NSDateFormatter.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDirectoryEnumerator.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSFormatter.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSHashTable.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSIndexPath.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSKeyedUnarchiver.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSMetadataItem.h>
#import <Foundation/NSMetadataQuery.h>
#import <Foundation/NSMetadataQueryAttributeValueTuple.h>
#import <Foundation/NSMetadataQueryResultGroup.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSMutableArray.h>
#import <Foundation/NSMutableAttributedString.h>
#import <Foundation/NSMutableCharacterSet.h>
#import <Foundation/NSMutableData.h>
#import <Foundation/NSMutableDictionary.h>
#import <Foundation/NSMutableIndexSet.h>
#import <Foundation/NSMutableSet.h>
#import <Foundation/NSMutableString.h>
#import <Foundation/NSNetServices.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSNotificationCenter.h>
#import <Foundation/NSNotificationQueue.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSNumber.h>
#import <Foundation/NSNumberFormatter.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSPipe.h>
#import <Foundation/NSPortCoder.h>
#import <Foundation/NSPredicate.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSProxy.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSSortDescriptor.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTask.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSTimer.h>
#import <Foundation/NSTimeZone.h>
#import <Foundation/NSUnarchiver.h>
#import <Foundation/NSUndoManager.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSMutableURLRequest.h>
#import <Foundation/NSURLConnection.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSValueTransformer.h>
#import <Foundation/NSXMLDocument.h>
#import <Foundation/NSXMLDTD.h>
#import <Foundation/NSXMLDTDNode.h>
#import <Foundation/NSXMLElement.h>
#import <Foundation/NSXMLNode.h>
#import <Foundation/NSXMLParser.h>
#import <Foundation/NSZone.h>

