//
//  CaptureSession.m
//  OpenGLESFirst
//
//  Created by Yzh on 17/01/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import "CaptureSession.h"


@interface CaptureSession()<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureDevice *inputCamera;
@property (strong, nonatomic) AVCaptureDevice *inputMicphone;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureDeviceInput *audioInput;
@property (strong, nonatomic) AVCaptureAudioDataOutput *audioDataOutput;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) AVCaptureSessionPreset capturePresent;
@end

@implementation CaptureSession

-(instancetype)init{
    if((self = [super init])){
        
        dispatch_queue_t videoCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_queue_t audioCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        
        _captureSession = [[AVCaptureSession alloc]init];
        if([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]){
            [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
            _capturePresent = AVCaptureSessionPreset640x480;
        }
        
        
        [_captureSession beginConfiguration];
        //get an AVCaptureDevice instance , here we want camera
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for(AVCaptureDevice *device in devices){
            if(device.position == AVCaptureDevicePositionBack){
                _inputCamera = device;
            }
        }
        
        NSError *error = nil;
        //initialize an AVCaptureDeviceInput with camera (AVCaptureDevice)
        _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_inputCamera error:&error];
        if(error){
            NSLog(@"Camera error");
            return nil;
        }
        
        //add video input to AVCaptureSession
        if([self.captureSession canAddInput:_videoInput]){
            [self.captureSession addInput:_videoInput];
        }
        
        //initialize an AVCaptureVideoDataOuput instance
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:NO];
        [self.videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [self.videoDataOutput setSampleBufferDelegate:self queue:videoCaptureQueue];
        
        //add video data output to capture session
        if([self.captureSession canAddOutput:self.videoDataOutput]){
            [self.captureSession addOutput:self.videoDataOutput];
        }
        
        //setting orientaion
        AVCaptureConnection *connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        connection.videoScaleAndCropFactor = connection.videoMaxScaleAndCropFactor;
        
        
        error = nil;
        //get an AVCaptureDevice for audio, here we want micphone
        _inputMicphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        
        //intialize the AVCaputreDeviceInput instance with micphone device
        _audioInput =[[AVCaptureDeviceInput alloc]initWithDevice:_inputMicphone error:&error];
        if(error){
            NSLog(@"micphone error");
        }
        
        //add audio device input to capture session
        if([self.captureSession canAddInput:_audioInput]){
            [self.captureSession addInput:_audioInput];
        }
        
        //initliaze an AVCaptureAudioDataOutput instance and set to 
        self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        if([self.captureSession canAddOutput:self.audioDataOutput]){
            [self.captureSession addOutput:self.audioDataOutput];
        }
        
        [self.audioDataOutput setSampleBufferDelegate:self queue:audioCaptureQueue];
        [self.captureSession commitConfiguration];
    }
    return self;
}

-(void)start{
    [self.captureSession startRunning];
}

-(void)stop{
    [self.captureSession stopRunning];
}

-(void) captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if(output == self.videoDataOutput){
        if(self.delegate && [self.delegate respondsToSelector:@selector(processVideoSampleBuffer:)]){
            [self.delegate processVideoSampleBuffer:sampleBuffer];
        }
    }else if(output == self.audioDataOutput){
        if(self.delegate &&[self.delegate respondsToSelector:@selector(processAudioSampleBuffer:)]){
            [self.delegate processAudioSampleBuffer:sampleBuffer];
        }
    }
}
@end
