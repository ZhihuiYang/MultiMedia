//
//  MyAudioUintPlayback.m
//  AudioUnitTry
//
//  Created by Yzh on 09/02/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import "MyAudioUintPlayback.h"
#import <AVFoundation/AVFoundation.h>

#define INPUT_BUS 1
#define OUTPUT_BUS 0


@implementation MyAudioUintPlayback{
    AudioUnit audiounit;
    AudioBufferList *bufferList;
    FILE *file;
}


- (instancetype)init{
    self = [super init];
    
    if(self){
       [self initRemoteIO];
        NSString *documentDic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"pcm"];
        file = fopen([filePath UTF8String], "rb");
    }  
    return self;
}

- (void)dealloc{
    AudioOutputUnitStop(audiounit);
    AudioUnitUninitialize(audiounit);
    AudioComponentInstanceDispose(audiounit);
    fclose(file);
}

-(void) initRemoteIO{
    //configure AudioSession
    NSError * error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [audioSession setPreferredSampleRate:44100 error:&error];
    [audioSession setPreferredInputNumberOfChannels:1 error:&error];
    [audioSession setPreferredIOBufferDuration:0.05 error:&error];
    [audioSession setActive:YES error:&error];
    
    //get a RemoteIO Audio Uint instance
    AudioComponentDescription audioComponentDesc;
    audioComponentDesc.componentType = kAudioUnitType_Output;
    audioComponentDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioComponentDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioComponentDesc.componentFlags = 0;
    audioComponentDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioComponentDesc);
    AudioComponentInstanceNew(inputComponent, &(self->audiounit));
    
    //configure AudioUnit format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate = 44100.0f;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerFrame = 2;
    audioFormat.mBytesPerPacket = 2;
    
    //configure Audio Unit
    AudioUnitSetProperty(self->audiounit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, OUTPUT_BUS, &audioFormat, sizeof(audioFormat));
    
    
    UInt32 enableFlag = 1;
    AudioUnitSetProperty(self->audiounit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, OUTPUT_BUS, &enableFlag, sizeof(enableFlag));
    
//    UInt32 flag = 0;
//    AudioUnitSetProperty(self->audiounit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, INPUT_BUS, &flag, sizeof(flag));
//
//    //initialize bufferlist
//    self->bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
//    self->bufferList->mNumberBuffers = 1;
//    self->bufferList->mBuffers[0].mNumberChannels = 1;
//    self->bufferList->mBuffers[0].mDataByteSize = 4096 *sizeof(short);
//    self->bufferList->mBuffers[0].mData = (short *)malloc(self->bufferList->mBuffers[0].mDataByteSize);
    

    
    //set play callback
    AURenderCallbackStruct playCallback;
    playCallback.inputProc = PlayingCallback;
    playCallback.inputProcRefCon = (__bridge void *)self;
    AudioUnitSetProperty(self->audiounit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, OUTPUT_BUS, &playCallback, sizeof(playCallback));
    
    AudioUnitInitialize(self->audiounit);
    
    
}

//static  OSStatus RecordingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData){
//
//    MyAudioUintRecorder *me = (__bridge MyAudioUintRecorder *) inRefCon;
//    AudioUnitRender(me->audiounit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, me->bufferList);
//
//    short *data = (short *)me->bufferList->mBuffers[0].mData;
//    int dataSize = me->bufferList->mBuffers[0].mDataByteSize;
//
//
//    NSLog(@"get %d byts LPCM data", dataSize);
//    fwrite(data, dataSize, 1, me->file);
//    return noErr;
//}

static  OSStatus PlayingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData){
    
      MyAudioUintPlayback *me = (__bridge MyAudioUintPlayback *) inRefCon;
    //AudioUnitRender(me->audiounit, ioActionFlags, inTimeStamp, INPUT_BUS, inNumberFrames, ioData);
    ioData->mBuffers[0].mDataByteSize = fread(ioData->mBuffers[0].mData, 1,ioData->mBuffers[0].mDataByteSize, me->file);
    
    NSLog(@"try to play %d bytes PCM data", ioData->mBuffers[0].mDataByteSize);
    if(ioData->mBuffers[0].mDataByteSize <=0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [me stopPlayback];
        });
    }
    return noErr;
}


- (void) startPlayback{
    AudioOutputUnitStart(self->audiounit);
}

- (void) stopPlayback{
    AudioOutputUnitStop(self->audiounit);
}

@end
