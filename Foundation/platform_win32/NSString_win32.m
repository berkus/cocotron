/* Copyright (c) 2006 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import <Foundation/NSString_win32.h>
#import <Foundation/NSData.h>

NSString *NSStringFromNullTerminatedUnicode(const unichar *characters) {
   unsigned length=0;

   while(characters[length]!=0x0000)
    length++;

   return [NSString stringWithCharacters:characters length:length];
}

const unichar *NSNullTerminatedUnicodeFromString(NSString *string) {
   unsigned length=[string length];
   unichar  buffer[length+1];

   [string getCharacters:buffer];
   buffer[length]=0x0000;

   return [[NSData dataWithBytes:buffer length:(length+1)*sizeof(unichar)] bytes];
}

NSData *NSTaskArgumentDataFromString(NSString *string) {
   unsigned       i,length=[string length],resultLength=0;
   unichar        buffer[length];
   unsigned char  result[1+length*2+1];

   [string getCharacters:buffer];

   result[resultLength++]='\"';
   for(i=0;i<length;i++){
    if(buffer[i]<=' '){
     result[resultLength++]=' ';
    }
    else if(buffer[i]=='\"'){
     result[resultLength++]='\\';
     result[resultLength++]='\"';
    }
    else
     result[resultLength++]=buffer[i];
   }
   result[resultLength++]='\"';

   return [NSData dataWithBytes:result length:resultLength];
}
