//
//  ViewController.m
//  AudioUnitTry
//
//  Created by Yzh on 09/02/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import "ViewController.h"
#import "MyAudioUintRecorder.h"

@interface ViewController (){
    BOOL isRecording;
}
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic, strong) MyAudioUintRecorder *recorder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.recorder = [[MyAudioUintRecorder alloc] init];
    self->isRecording = FALSE;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startRecording:(id)sender {
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
