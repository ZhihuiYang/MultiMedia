//
//  CaptureSession.h
//  OpenGLESFirst
//
//  Created by Yzh on 17/01/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CaptureSessionDelegate <NSObject>

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@interface CaptureSession : NSObject
@property (strong, nonatomic) id<CaptureSessionDelegate> delegate;
@property (strong, nonatomic) AVCaptureSession *captureSession;

-(instancetype)init;

-(void)start;

-(void)stop;

@end
