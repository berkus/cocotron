/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphicsExport.h>

#import <CoreGraphics/CGGeometry.h>

typedef struct {
   float a;
   float b;
   float c;
   float d;
   float tx;
   float ty;
} CGAffineTransform;

COREGRAPHICS_EXPORT const CGAffineTransform CGAffineTransformIdentity;

COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformMake(float a,float b,float c,float d,float tx,float ty);
COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformMakeRotation(float radians);
COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformMakeScale(float scalex,float scaley);
COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformMakeTranslation(float tx,float ty);

COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformConcat(CGAffineTransform xform,CGAffineTransform append);
COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformInvert(CGAffineTransform xform);

COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformRotate(CGAffineTransform xform,float radians);
COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformScale(CGAffineTransform xform,float scalex,float scaley);
COREGRAPHICS_EXPORT CGAffineTransform CGAffineTransformTranslate(CGAffineTransform xform,float tx,float ty);

COREGRAPHICS_EXPORT CGPoint CGPointApplyAffineTransform(CGPoint point, CGAffineTransform xform);
COREGRAPHICS_EXPORT CGSize CGSizeApplyAffineTransform(CGSize size, CGAffineTransform xform);


