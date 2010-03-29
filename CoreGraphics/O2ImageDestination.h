#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import "O2DataConsumer.h"
#import "O2Image.h"
#import "O2ImageSource.h"
#import <stdbool.h>

typedef struct _O2ImageDestination *O2ImageDestinationRef;

const CFStringRef kO2ImageDestinationLossyCompressionQuality;
const CFStringRef kO2ImageDestinationBackgroundColor;

@interface O2ImageDestination : NSObject {
@public
   O2DataConsumerRef _consumer;
   CFStringRef       _type;
   size_t            _imageCount;
   CFDictionaryRef   _options;
   void             *_encoder;
}

@end

CFTypeID O2ImageDestinationGetTypeID(void);

CFArrayRef O2ImageDestinationCopyTypeIdentifiers(void);

O2ImageDestinationRef O2ImageDestinationCreateWithData(CFMutableDataRef data,CFStringRef type,size_t imageCount,CFDictionaryRef options);
O2ImageDestinationRef O2ImageDestinationCreateWithDataConsumer(O2DataConsumerRef dataConsumer,CFStringRef type,size_t imageCount,CFDictionaryRef options);
O2ImageDestinationRef O2ImageDestinationCreateWithURL(CFURLRef url,CFStringRef type,size_t imageCount,CFDictionaryRef options);

void O2ImageDestinationSetProperties(O2ImageDestinationRef self,CFDictionaryRef properties);

void O2ImageDestinationAddImage(O2ImageDestinationRef self,O2ImageRef image,CFDictionaryRef properties);
void O2ImageDestinationAddImageFromSource(O2ImageDestinationRef self,O2ImageSourceRef imageSource,size_t index,CFDictionaryRef properties);

bool O2ImageDestinationFinalize(O2ImageDestinationRef self);

