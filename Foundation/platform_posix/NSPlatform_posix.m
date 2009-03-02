/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/ObjectiveC.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSSelectInputSourceSet.h>
#import <Foundation/NSPlatform_posix.h>
#import <Foundation/NSFileHandle_posix.h>
#import <Foundation/NSFileManager_posix.h>
#import <Foundation/NSLock_posix.h>
#import <Foundation/NSConditionLock_posix.h>
#import <Foundation/NSPersistantDomain_posix.h>
#import <Foundation/NSTask_posix.h>
#import <Foundation/NSPipe_posix.h>

#import <pwd.h>
#import <unistd.h>
#import <rpc/types.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/param.h>
#include <fcntl.h>
#include <netdb.h>
#include <time.h>
#include <stdio.h>
#include <poll.h>

@implementation NSPlatform_posix

-(NSInputSourceSet *)synchronousInputSourceSet {
   return [[[NSSelectInputSourceSet alloc] init] autorelease];
}

-(NSString *)fileManagerClassName {
   return @"NSFileManager_posix";
}

-(Class)taskClass {
   return [NSTask_posix class];
}

-(Class)pipeClass {
   return [NSPipe_posix class];
}

-(Class)lockClass {
   return [NSLock_posix class];
}

-(Class)conditionLockClass {
   return [NSConditionLock_posix class];
}

-(Class)persistantDomainClass {
   return [NSPersistantDomain_posix class];
}

static struct passwd *pwent = NULL;

-(void)_checkAndGetPWEnt {
   if (pwent == NULL) {
      pwent = getpwuid(getuid());
      if (pwent == NULL)
         NSRaiseException(NSInternalInconsistencyException, self, _cmd, @"Can't obtain user's information from system");
   }
}

-(NSString *)userName {
    [self _checkAndGetPWEnt];
    return [NSString stringWithCString:pwent->pw_name];
}

-(NSString *)fullUserName {
    [self _checkAndGetPWEnt];
    return [NSString stringWithCString:pwent->pw_gecos];
}

-(NSString *)homeDirectory {
    [self _checkAndGetPWEnt];
    return [NSString stringWithCString:pwent->pw_dir];
}

-(NSString *)temporaryDirectory {
   return @"/tmp";
}

-(NSArray *)arguments {
    extern int                NSProcessInfoArgc;
    extern const char *const *NSProcessInfoArgv;
    NSMutableArray *result=[NSMutableArray array];
    int             i;

    for(i=0;i<NSProcessInfoArgc;i++)
        [result addObject:[NSString stringWithCString:NSProcessInfoArgv[i]]];

    return result;
}

-(NSDictionary *)environment {
   id      *objects,*keys;
   unsigned count;

   char **env;
   char  *keyValue;
   int    i,len,max;

   env = NSPlatform_environ();

   max=0;
   for(count=0;env[count];count++)
    if((len=strlen(env[count]))>max)
     max=len;

   keyValue=__builtin_alloca(max+1);
   objects=__builtin_alloca(sizeof(id)*count);
   keys=__builtin_alloca(sizeof(id)*count);

   for(count=0;env[count];count++){
    len=strlen(strcpy(keyValue,env[count]));

    for(i=0;i<len;i++)
     if(keyValue[i]=='=')
      break;
    keyValue[i]='\0';

    objects[count]=[NSString stringWithCString:keyValue+i+1];
    keys[count]=[NSString stringWithCString:keyValue];
    
    [self checkEnvironmentKey:keys[count] value:objects[count]];
   }

   return [[NSDictionary allocWithZone:NULL] initWithObjects:objects forKeys:keys
     count:count];
}

// silly me, we need microsecond granularity!
-(NSTimeInterval)timeIntervalSinceReferenceDate {
    NSTimeInterval result;
    struct timeval tp;

    gettimeofday(&tp, NULL);
    result  = (((NSTimeInterval)tp.tv_sec)  - NSTimeIntervalSince1970);
    result += (((NSTimeInterval)tp.tv_usec) / ((NSTimeInterval)1000000.0));

    return result;
}

-(unsigned)processID {
    return getpid();
}

-(unsigned)threadID {
    return pthread_self();
}

-(NSArray *)addressesForDNSHostName:(NSString *)name {
    NSMutableArray *result=[NSMutableArray array];
    char            cString[MAXHOSTNAMELEN+1];
    struct hostent *hp;

    [name getCString:cString maxLength:MAXHOSTNAMELEN];

    if((hp=gethostbyname(cString))==NULL) {
        return nil;
    }
    else {
        unsigned long **addr_list=(unsigned long **)hp->h_addr_list;
        int             i;

        for(i=0;addr_list[i]!=NULL;i++){
            struct in_addr addr;
            NSString      *string;

            addr.s_addr=*addr_list[i];

            string=[NSString stringWithCString:(char *)inet_ntoa(addr)];

            [result addObject:string];
        }

        return result;
    }
}

-(void)logString:(NSString *)string {
    fprintf(stderr, "%s\n", [string UTF8String]);
}

-(void *)contentsOfFile:(NSString *)path length:(unsigned *)lengthp {
    int fd = open([path fileSystemRepresentation], O_RDONLY);
    char *buf;
    off_t pos, total = 0;

    *lengthp = 0;

    if (fd == -1)
        return NULL;

    pos = lseek(fd, 0, SEEK_END);
    if (pos == -1)
        return NULL;
    
    if (lseek(fd, 0, SEEK_SET) == -1)
        return NULL;

    if ((buf = malloc(pos)) == NULL)
        return NULL;

    do {
        off_t bytesRead = read(fd, buf+total, pos);

        if (bytesRead == -1) {
            close(fd);
            return NULL;
        }

        total += bytesRead;
    } while (total < pos);

    close(fd);

    *lengthp = pos;

    return buf;
}

/*
        SVr4, POSIX.1b (formerly POSIX.4), 4.4BSD.  Svr4 documents
       additional error codes ENXIO and ENODEV.
 */
-(void *)mapContentsOfFile:(NSString *)path length:(unsigned *)lengthp {
    int fd = open([path fileSystemRepresentation], O_RDONLY);
    void *result;

    *lengthp = 0;
    if (fd == -1)
        return NULL;

    *lengthp = lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);

    result = mmap(NULL, *lengthp, PROT_READ, MAP_SHARED, fd, 0);
    if (result == MAP_FAILED)
        result = NULL;

    close(fd);

    return result;
}

-(void)unmapAddress:(void *)ptr length:(unsigned)length {
    if(length>0){
        if (munmap(ptr, length) == -1)
            NSRaiseException(NSInvalidArgumentException, self, _cmd, @"munmap() returned -1");
    }
}

-(BOOL)writeContentsOfFile:(NSString *)path bytes:(const void *)bytes length:(unsigned)length atomically:(BOOL)atomically {
    NSString *atomic = nil;
    int fd;
    unsigned total = 0;

    if (atomically) {
        do {
            atomic = [path stringByAppendingString:@"1"];
        } while ([[NSFileManager defaultManager] fileExistsAtPath:atomic] == YES);
                
        fd = open([atomic fileSystemRepresentation], O_WRONLY|O_CREAT, FOUNDATION_FILE_MODE);
        if (fd == -1)
            return NO;
    }
    else {
        fd = open([path fileSystemRepresentation], O_WRONLY|O_CREAT, FOUNDATION_FILE_MODE);
        if (fd == -1)
            return NO;
    }

    do {
        int written = write(fd, bytes+total, length);

        if (written == -1) {
            close(fd);
            return NO;
        }

        total += written;
    } while (total < length);

    close(fd);

    if (atomically)
        if (rename([atomic fileSystemRepresentation], [path fileSystemRepresentation]) == -1)
            return NO;

    return YES;
}
@end


