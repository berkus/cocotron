/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObject.h>
#import <CoreGraphics/CoreGraphics.h>

@class KGPDFDocument,KGPDFDictionary,KGContext;

@interface KGPDFPage : NSObject {
   KGPDFDocument   *_document;
   int                _pageNumber;
   KGPDFDictionary *_dictionary;
}

-initWithDocument:(KGPDFDocument *)document pageNumber:(int)pageNumber dictionary:(KGPDFDictionary *)dictionary;

+(KGPDFPage *)pdfPageWithDocument:(KGPDFDocument *)document pageNumber:(int)pageNumber dictionary:(KGPDFDictionary *)dictionary;

-(KGPDFDocument *)document;
-(int)pageNumber;

-(KGPDFDictionary *)dictionary;

-(BOOL)getRect:(CGRect *)rect forBox:(CGPDFBox)box;

-(int)rotationAngle;

-(CGAffineTransform)drawingTransformForBox:(CGPDFBox)box inRect:(CGRect)rect rotate:(int)degrees preserveAspectRatio:(BOOL)preserveAspectRatio;

-(void)drawInContext:(KGContext *)context;

@end
