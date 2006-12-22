/* Copyright (c) 2006 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - David Young <daver@geeks.org>
#import <pthread.h>

#import <Foundation/NSLock_posix.h>
#import <Foundation/Foundation.h>

@implementation NSLock_posix

- init {
    pthread_mutex_init(&_mutex, NULL);

    return self;
}

-(void)dealloc {
    pthread_mutex_destroy(&_mutex);
    [super dealloc];
}

-(void)lock {
    if (pthread_mutex_lock(&_mutex) == -1)
        NSRaiseException(NSInvalidArgumentException,
                         self, _cmd, @"pthread_mutex_lock() returned -1");
}

-(void)unlock {
    if (pthread_mutex_unlock(&_mutex) == -1)
        NSRaiseException(NSInvalidArgumentException,
                         self, _cmd, @"pthread_mutex_lock() returned -1");
}

@end
