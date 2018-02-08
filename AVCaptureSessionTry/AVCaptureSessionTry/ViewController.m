//
//  ViewController.m
//  AVCaptureSessionTry
//
//  Created by Yzh on 08/02/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CaptureSession.h"

@interface ViewController () <CaptureSessionDelegate>{
    BOOL isCapturing;
}
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) CaptureSession *captureSession;
@property (nonatomic) dispatch_queue_t sessionQueue;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionQueue = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL);
    
        _captureSession = [[CaptureSession alloc]init];
        _captureSession.delegate = self;
        
        
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession.captureSession];
        previewLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:previewLayer];
        [self.view bringSubviewToFront:self.startButton];
        self->isCapturing = false;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    NSLog(@"process Audio SampleBuffer");
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    NSLog(@"process Video SampleBuffer");
}
- (IBAction)startCapture:(UIButton *)sender {

    
        if(self->isCapturing){
            dispatch_async(self.sessionQueue, ^{
                [_captureSession stop];
            });
            [sender setTitle:@"开始录制" forState:UIControlStateNormal];
            self->isCapturing = FALSE;
        }else{
            dispatch_async(self.sessionQueue, ^{
                [_captureSession start];
            });
            [sender setTitle:@"停止录制" forState:UIControlStateNormal];
            self->isCapturing = TRUE;
        }

    
}


@end

