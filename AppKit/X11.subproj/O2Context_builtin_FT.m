#import "O2Context_builtin_FT.h"
#import <Onyx2D/O2GraphicsState.h>
#import "O2Font_FT.h"
#import <Onyx2D/O2Paint_color.h>

@implementation O2Context_builtin_FT

+(BOOL)canInitBackingWithContext:(O2Context *)context deviceDictionary:(NSDictionary *)deviceDictionary {
   return YES;
}

static inline O2GState *currentState(O2Context *self){        
   return [self->_stateStack lastObject];
}

-initWithSurface:(O2Surface *)surface flipped:(BOOL)flipped {
   if([super initWithSurface:surface flipped:flipped]==nil)
    return nil;

   return self;
}

-(void)dealloc {

   [super dealloc];
}

-(void)establishFontStateInDeviceIfDirty {
   O2GState *gState=currentState(self);
   
   if(gState->_fontIsDirty){
    O2GStateClearFontIsDirty(gState);
   }
}

static O2Paint *paintFromColor(O2ColorRef color){
   size_t    count=O2ColorGetNumberOfComponents(color);
   const float *components=O2ColorGetComponents(color);

   if(count==2)
    return [[O2Paint_color alloc] initWithGray:components[0]  alpha:components[1]];
   if(count==4)
    return [[O2Paint_color alloc] initWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
    
   return [[O2Paint_color alloc] initWithGray:0 alpha:1];
}

static void applyCoverageToSpan_lRGBA8888_PRE(O2argb8u *dst,unsigned char *coverageSpan,O2argb8u *src,int length){
   int i;
   
   for(i=0;i<length;i++,src++,dst++){
    int coverage=coverageSpan[i];
    int oneMinusCoverage=inverseCoverage(coverage);
    O2argb8u r=*src;
    O2argb8u d=*dst;
    
    *dst=O2argb8uAdd(O2argb8uMultiplyByCoverage(r , coverage) , O2argb8uMultiplyByCoverage(d , oneMinusCoverage));
   }
}


static void drawFreeTypeBitmap(O2Context_builtin_FT *self,O2Surface *surface,FT_Bitmap *bitmap,int x,int y,O2Paint *paint){
// FIXME: clipping
   int            width=bitmap->width;
   int            row,height=bitmap->rows;
   O2argb8u      *dstBuffer=__builtin_alloca(width*sizeof(O2argb8u));
   O2argb8u      *srcBuffer=__builtin_alloca(width*sizeof(O2argb8u));
   unsigned char *coverage=bitmap->buffer;
   
   for(row=0;row<height;row++,y++){
   int        length=width;
    O2argb8u *dst=dstBuffer;
    O2argb8u *src=srcBuffer;
    
    O2argb8u *direct=surface->_read_lRGBA8888_PRE(surface,x,y,dst,length);

    if(direct!=NULL)
     dst=direct;

    while(YES){
     int chunk=O2PaintReadSpan_lRGBA8888_PRE(paint,x,y,src,length);
      
     if(chunk<0)
      chunk=-chunk;
     else {

      self->_blend_lRGBA8888_PRE(src,dst,chunk);
      
      applyCoverageToSpan_lRGBA8888_PRE(dst,coverage,src,chunk);

      if(direct==NULL)
       O2SurfaceWriteSpan_lRGBA8888_PRE(surface,x,y,dst,chunk);
     }
     coverage+=chunk;

     length-=chunk;     
     x+=chunk;
     src+=chunk;
     dst+=chunk;

     if(length==0)
      break;

    }
    x-=width;
   }
    
}

-(void)showGlyphs:(const O2Glyph *)glyphs count:(unsigned)count {
   O2AffineTransform transformToDevice=O2ContextGetUserSpaceToDeviceSpaceTransform(self);
   O2GState         *gState=currentState(self);
   O2Paint          *paint=paintFromColor(gState->_fillColor);
   O2AffineTransform Trm=O2AffineTransformConcat(gState->_textTransform,transformToDevice);
   O2Point           point=O2PointApplyAffineTransform(NSMakePoint(0,0),Trm);
   
   [self establishFontStateInDeviceIfDirty];

   O2Font_FT *font=(O2Font_FT *)gState->_font;
   FT_Face    face=[font face];

   int        i;
   FT_Error   ftError;
   
   if(face==NULL){
    NSLog(@"face is NULL");
    return;
   }

   FT_GlyphSlot slot=face->glyph;

   if(ftError=FT_Set_Char_Size(face,0,gState->_pointSize*64,72.0,72.0)){
    NSLog(@"FT_Set_Char_Size returned %d",ftError);
    return;
   }
    
   for(i=0;i<count;i++){

    ftError=FT_Load_Glyph(face,glyphs[i],FT_LOAD_DEFAULT);
    if(ftError)
     continue; 
      
    ftError=FT_Render_Glyph(face->glyph,FT_RENDER_MODE_NORMAL);
    if(ftError)
     continue;
      
    drawFreeTypeBitmap(self,_surface,&slot->bitmap,point.x+slot->bitmap_left,point.y-slot->bitmap_top,paint);

    point.x += slot->advance.x >> 6;
   }
   
   O2PaintRelease(paint);
   
   int     advances[count];
   O2Float unitsPerEm=O2FontGetUnitsPerEm(font);
   
   O2FontGetGlyphAdvances(font,glyphs,count,advances);
   
   O2Float total=0;
   
   for(i=0;i<count;i++)
    total+=advances[i];
    
   total=(total/O2FontGetUnitsPerEm(font))*gState->_pointSize;
      
   currentState(self)->_textTransform.tx+=total;
   currentState(self)->_textTransform.ty+=0;
}

@end
