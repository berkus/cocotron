/*------------------------------------------------------------------------
 *
 * Derivative of the OpenVG 1.0.1 Reference Implementation
 * -------------------------------------
 *
 * Copyright (c) 2007 The Khronos Group Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and /or associated documentation files
 * (the "Materials "), to deal in the Materials without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Materials,
 * and to permit persons to whom the Materials are furnished to do so,
 * subject to the following conditions: 
 *
 * The above copyright notice and this permission notice shall be included 
 * in all copies or substantial portions of the Materials. 
 *
 * THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE MATERIALS OR
 * THE USE OR OTHER DEALINGS IN THE MATERIALS.
 *
 *-------------------------------------------------------------------*/

#import <Foundation/NSObject.h>

#import "KGImage.h"

#import "VGmath.h"

typedef unsigned int	RIuint32;
typedef short			RIint16;
typedef unsigned int VGbitfield;

typedef enum {
  VG_TILE_FILL,
  VG_TILE_PAD,
  VG_TILE_REPEAT,
} VGTilingMode;

typedef enum {
   VG_DRAW_IMAGE_NORMAL,
   VG_DRAW_IMAGE_MULTIPLY,
   VG_DRAW_IMAGE_STENCIL,
} KGSurfaceMode;

typedef enum {
  VG_RED                                      = (1 << 3),
  VG_GREEN                                    = (1 << 2),
  VG_BLUE                                     = (1 << 1),
  VG_ALPHA                                    = (1 << 0)
} KGSurfaceChannel;

typedef enum {
  VG_CLEAR_MASK                               = 0x1500,
  VG_FILL_MASK                                = 0x1501,
  VG_SET_MASK                                 = 0x1502,
  VG_UNION_MASK                               = 0x1503,
  VG_INTERSECT_MASK                           = 0x1504,
  VG_SUBTRACT_MASK                            = 0x1505
} VGMaskOperation;


typedef struct {
	int			x;
	int			y;
	int			width;
	int			height;
} KGIntRect;

static inline KGIntRect KGIntRectInit(int x,int y,int width,int height) {
   KGIntRect result={x,y,width,height};
   return result;
}

#define RI_INT32_MAX  (0x7fffffff)
#define RI_INT32_MIN  (-0x7fffffff-1)
static inline int RI_INT_ADDSATURATE(int a, int b)	{ RI_ASSERT(b >= 0); int r = a + b; return (r >= a) ? r : RI_INT32_MAX; }

static inline KGIntRect KGIntRectIntersect(KGIntRect self,KGIntRect other) {
		if(self.width >= 0 && other.width >= 0 && self.height >= 0 && other.height >= 0)
		{
			int xmin = RI_INT_MIN(RI_INT_ADDSATURATE(self.x, self.width), RI_INT_ADDSATURATE(other.x, other.width));
			self.x = RI_INT_MAX(self.x, other.x);
			self.width = RI_INT_MAX(xmin - self.x, 0);

			int ymin = RI_INT_MIN(RI_INT_ADDSATURATE(self.y, self.height), RI_INT_ADDSATURATE(other.y, other.height));
			self.y = RI_INT_MAX(self.y, other.y);
			self.height = RI_INT_MAX(ymin - self.y, 0);
		}
		else
		{
			self.x = 0;
			self.y = 0;
			self.width = 0;
			self.height = 0;
		}
        return self;
}

/*-------------------------------------------------------------------*//*!
* \brief	A class representing color for processing and converting it
*			to and from various surface formats.
*//*-------------------------------------------------------------------*/


typedef struct VGColor {
	CGFloat		r;
	CGFloat		g;
	CGFloat		b;
	CGFloat		a;
	VGColorInternalFormat	m_format;
} VGColor;

static inline VGColor VGColorFromRGBAffff(KGRGBAffff rgba,VGColorInternalFormat format){
   VGColor result;
   
   result.r=rgba.r;
   result.g=rgba.g;
   result.b=rgba.b;
   result.a=rgba.a;
   result.m_format=format;
   
   return result;
}

static inline KGRGBAffff KGRGBAffffFromColor(VGColor color){
   KGRGBAffff result;
   result.r=color.r;
   result.g=color.g;
   result.b=color.b;
   result.a=color.a;
   return result;
}


static inline VGColor VGColorZero(){
   VGColor result;
   
   result.r=0;
   result.g=0;
   result.b=0;
   result.a=0;
   result.m_format=VGColor_lRGBA;
   
   return result;
}

static inline VGColor VGColorRGBA(CGFloat cr, CGFloat cg, CGFloat cb, CGFloat ca, VGColorInternalFormat cs){
   VGColor result;
   
   RI_ASSERT(cs == VGColor_lRGBA || cs == VGColor_sRGBA || cs == VGColor_lRGBA_PRE || cs == VGColor_sRGBA_PRE || cs == VGColor_lLA || cs == VGColor_sLA || cs == VGColor_lLA_PRE || cs == VGColor_sLA_PRE);
   
   result.r=cr;
   result.g=cg;
   result.b=cb;
   result.a=ca;
   result.m_format=cs;
   return result;
}

static inline VGColor VGColorMultiplyByFloat(VGColor c,CGFloat f){
   return VGColorRGBA(c.r*f, c.g*f, c.b*f, c.a*f, c.m_format);
}

static inline VGColor VGColorAdd(VGColor c0,VGColor c1){
   RI_ASSERT(c0.m_format == c1.m_format);
   return VGColorRGBA(c0.r+c1.r, c0.g+c1.g, c0.b+c1.b, c0.a+c1.a, c0.m_format);
}

static inline VGColor VGColorSubtract(VGColor result,VGColor c1){
   RI_ASSERT(result.m_format == c1.m_format);
   result.r -= c1.r;
   result.g -= c1.g;
   result.b -= c1.b;
   result.a -= c1.a;
   return result;
}

//clamps nonpremultiplied colors and alpha to [0,1] range, and premultiplied alpha to [0,1], colors to [0,a]
static inline VGColor VGColorClamp(VGColor result){
   result.a = RI_CLAMP(result.a,0.0f,1.0f);
   CGFloat u = (result.m_format & VGColorPREMULTIPLIED) ? result.a : (CGFloat)1.0f;
   result.r = RI_CLAMP(result.r,0.0f,u);
   result.g = RI_CLAMP(result.g,0.0f,u);
   result.b = RI_CLAMP(result.b,0.0f,u);
   return result;
}

static inline VGColor VGColorPremultiply(VGColor result){
   if(!(result.m_format & VGColorPREMULTIPLIED)) {
     result.r *= result.a; result.g *= result.a; result.b *= result.a; result.m_format = (VGColorInternalFormat)(result.m_format | VGColorPREMULTIPLIED);
    }
    return result;
}


static inline VGColor VGColorUnpremultiply(VGColor result){
   if(result.m_format & VGColorPREMULTIPLIED) {
    CGFloat ooa = (result.a != 0.0f) ? 1.0f/result.a : (CGFloat)0.0f;
    result.r *= ooa; result.g *= ooa; result.b *= ooa;
    result.m_format = (VGColorInternalFormat) (result.m_format & ~VGColorPREMULTIPLIED);
   }
   return result;
}

VGColor VGColorConvert(VGColor result,VGColorInternalFormat outputFormat);

static inline void KGRGBAffffConvertSpan(KGRGBAffff *span,int length,VGColorInternalFormat fromFormat,VGColorInternalFormat toFormat){
   if(fromFormat!=toFormat){
    int i;
   
    for(i=0;i<length;i++)
     span[i]=KGRGBAffffFromColor(VGColorConvert(VGColorFromRGBAffff(span[i],fromFormat),toFormat));
   }
}


@class KGSurface;

typedef void (*KGSurfaceWriteSpan_RGBA8888)(KGSurface *self,int x,int y,KGRGBA8888 *span,int length);
typedef void (*KGSurfaceWriteSpan_RGBAffff)(KGSurface *self,int x,int y,KGRGBAffff *span,int length);

@interface KGSurface : KGImage {
   unsigned char              *_pixelBytes;
   KGSurfaceWriteSpan_RGBA8888 _writeRGBA8888;
   KGSurfaceWriteSpan_RGBAffff _writeRGBAffff;
   
	BOOL           m_ownsData;
	VGPixelDecode	m_desc;
} 

-initWithBytes:(void *)bytes width:(size_t)width height:(size_t)height bitsPerComponent:(size_t)bitsPerComponent bytesPerRow:(size_t)bytesPerRow colorSpace:(KGColorSpace *)colorSpace bitmapInfo:(CGBitmapInfo)bitmapInfo;

-(NSData *)pixelData;
-(void *)pixelBytes;

-(void)setWidth:(size_t)width height:(size_t)height reallocateOnlyIfRequired:(BOOL)roir;


BOOL KGSurfaceIsValidFormat(int format);

void KGSurfaceClear(KGSurface *self,VGColor clearColor, int x, int y, int w, int h);
void KGSurfaceBlit(KGSurface *self,KGSurface * src, int sx, int sy, int dx, int dy, int w, int h, BOOL dither);
void KGSurfaceMask(KGSurface *self,KGSurface* src, VGMaskOperation operation, int x, int y, int w, int h);
VGColor KGSurfaceReadPixel(KGImage *self,int x, int y);

void KGSurfaceWritePixel(KGSurface *self,int x, int y, VGColor c);
void KGSurfaceWriteSpan_lRGBA8888_PRE(KGSurface *self,int x,int y,KGRGBA8888 *span,int length);
void KGSurfaceWriteSpan_lRGBAffff_PRE(KGSurface *self,int x,int y,KGRGBAffff *span,int length);

void KGSurfaceWriteFilteredPixel(KGSurface *self,int x, int y, VGColor c, VGbitfield channelMask);

void KGSurfaceWriteMaskPixel(KGSurface *self,int x, int y, CGFloat m);	//can write only to VG_A_8

typedef struct KGGaussianKernel *KGGaussianKernelRef;

KGGaussianKernelRef KGCreateGaussianKernelWithDeviation(CGFloat stdDeviation);
KGGaussianKernelRef KGGaussianKernelRetain(KGGaussianKernelRef kernel);
void KGGaussianKernelRelease(KGGaussianKernelRef kernel);


void KGSurfaceColorMatrix(KGSurface *self,KGSurface * src, const CGFloat* matrix, BOOL filterFormatLinear, BOOL filterFormatPremultiplied, VGbitfield channelMask);
void KGSurfaceConvolve(KGSurface *self,KGSurface * src, int kernelWidth, int kernelHeight, int shiftX, int shiftY, const RIint16* kernel, CGFloat scale, CGFloat bias, VGTilingMode tilingMode, VGColor edgeFillColor, BOOL filterFormatLinear, BOOL filterFormatPremultiplied, VGbitfield channelMask);
void KGSurfaceSeparableConvolve(KGSurface *self,KGSurface * src, int kernelWidth, int kernelHeight, int shiftX, int shiftY, const RIint16* kernelX, const RIint16* kernelY, CGFloat scale, CGFloat bias, VGTilingMode tilingMode, VGColor edgeFillColor, BOOL filterFormatLinear, BOOL filterFormatPremultiplied, VGbitfield channelMask);
void KGSurfaceGaussianBlur(KGSurface *self,KGImage * src, KGGaussianKernelRef kernel);
void KGSurfaceLookup(KGSurface *self,KGSurface * src, const uint8_t * redLUT, const uint8_t * greenLUT, const uint8_t * blueLUT, const uint8_t * alphaLUT, BOOL outputLinear, BOOL outputPremultiplied, BOOL filterFormatLinear, BOOL filterFormatPremultiplied, VGbitfield channelMask);
void KGSurfaceLookupSingle(KGSurface *self,KGSurface * src, const RIuint32 * lookupTable, KGSurfaceChannel sourceChannel, BOOL outputLinear, BOOL outputPremultiplied, BOOL filterFormatLinear, BOOL filterFormatPremultiplied, VGbitfield channelMask);

@end
