//
//  ViewController.m
//  AudioUnitPlayPCM
//
//  Created by Yzh on 12/02/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import "ViewController.h"
#import "MyAudioUintPlayback.h"

@interface ViewController ()
{
    BOOL isPlaying;
}
@property (nonatomic, strong) MyAudioUintPlayback * player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = [[MyAudioUintPlayback alloc]init];
    isPlaying = FALSE;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playBack:(id)sender {
    if(self->isPlaying){
        [_player stopPlayback];
        [sender setTitle:@"开始播放" forState:UIControlStateNormal];
        self->isPlaying = FALSE;
    }else{
        [_player startPlayback];
        [sender setTitle:@"停止播放" forState:UIControlStateNormal];
        self->isPlaying = TRUE;
    }
}

@end
