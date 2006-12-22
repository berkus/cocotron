/* Copyright (c) 2006 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSEvent.h>

#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0400

#import <windows.h>

@class NSEvent, NSColor, Win32EventInputSource, Win32SplashPanel, Win32DeviceContext;

@interface Win32Display : NSDisplay {
   Win32SplashPanel      *_splashPanel;

   Win32DeviceContext    *_deviceContextOnPrimaryScreen;

   Win32EventInputSource *_eventInputSource;

   NSPasteboard          *_generalPasteboard;
   NSMutableDictionary   *_pasteboards;

   NSMutableDictionary   *_nameToColor;

   id                     _cursor;
   int                    _cursorDisplayCount;
   NSMutableDictionary   *_cursorCache;
   HCURSOR                _lastCursor;

   int                    _clickCount;
   DWORD                  _lastTickCount;
   LPARAM                 _lastPosition;
}

+(Win32Display *)currentDisplay;

-(Win32DeviceContext *)deviceContextOnPrimaryScreen;

-(NSArray *)screens;

-(NSPasteboard *)pasteboardWithName:(NSString *)name;

-(NSDraggingManager *)draggingManager;

-(void)invalidateSystemColors;
-(NSColor *)colorWithName:(NSString *)colorName;

-(NSString *)menuFontNameAndSize:(float *)pointSize;

-(void)hideCursor;
-(void)unhideCursor;

// Arrow, IBeam, HorizontalResize, VerticalResize
-(id)cursorWithName:(NSString *)name;
-(void)setCursor:(id)cursor;

-(void)stopWaitCursor;
-(void)startWaitCursor;

-(BOOL)postMSG:(MSG)msg;

-(void)beep;

@end
