#import "HelloPlugin.h"
#import "OpenGLRender.h"
#import "SampleRenderWorker.h"

@interface HelloPlugin()
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, OpenGLRender *> *renders;
@property (nonatomic, strong) NSObject<FlutterTextureRegistry> *textures;
@end


@implementation HelloPlugin
- (instancetype)initWithTextures:(NSObject<FlutterTextureRegistry> *)textures {
    self = [super init];
    if (self) {
        _renders = [[NSMutableDictionary alloc] init];
        _textures = textures;
    }
    return self;
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
  methodChannelWithName:@"hello_plugin" binaryMessenger:[registrar messenger]];

  HelloPlugin* instance = [[HelloPlugin alloc] initWithTextures:[registrar textures]];
 // HelloPlugin* instance = [[HelloPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } 
  else  if ([@"create" isEqualToString:call.method]) {
        CGFloat width = [call.arguments[@"width"] floatValue];
        CGFloat height = [call.arguments[@"height"] floatValue];
        
        NSInteger __block textureId;
        id<FlutterTextureRegistry> __weak registry = self.textures;
        
        OpenGLRender *render = [[OpenGLRender alloc] initWithSize:CGSizeMake(width, height)
                                                           worker:[[SampleRenderWorker alloc] init]
                                                       onNewFrame:^{
                                                           [registry textureFrameAvailable:textureId];
                                                       }];
        
        textureId = [self.textures registerTexture:render];
        self.renders[@(textureId)] = render;
        result(@(textureId));
    } else if ([@"dispose" isEqualToString:call.method]) {
        NSNumber *textureId = call.arguments[@"textureId"];
        OpenGLRender *render = self.renders[textureId];
        [render dispose];
        [self.renders removeObjectForKey:textureId];
        result(nil);
    } 
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
