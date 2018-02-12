//
//  ViewController.m
//  AudioUintRecordPCM
//
//  Created by Yzh on 12/02/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import "ViewController.h"
#import "MyAudioUintRecorder.h"

@interface ViewController ()
{
    BOOL isRecording;
}
@property (nonatomic, strong) MyAudioUintRecorder * recorder;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recorder = [[MyAudioUintRecorder alloc]init];
    isRecording = FALSE;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecord:(id)sender {
    if(self->isRecording){
        [_recorder stopRecording];
        [sender setTitle:@"开始录制" forState:UIControlStateNormal];
        self->isRecording = FALSE;
    }else{
        [_recorder startRecording];
        [sender setTitle:@"停止录制" forState:UIControlStateNormal];
        self->isRecording = TRUE;
    }
}

@end
