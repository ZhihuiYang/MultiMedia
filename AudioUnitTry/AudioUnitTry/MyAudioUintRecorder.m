//
//  MyAudioUintRecorder.m
//  AudioUnitTry
//
//  Created by Yzh on 09/02/2018.
//  Copyright © 2018 Yzh. All rights reserved.
//

#import "MyAudioUintRecorder.h"
#import <AVFoundation/AVFoundation.h>

#define INPUT_BUS 1
#define OUTPUT_BUS 0

@interface MyAudioUintRecorder(){
    AudioUnit audiounit;
    AudioBufferList *bufferList;
}

@end



@implementation MyAudioUintRecorder


- (instancetype)init{
    self = [super init];
    
    if(self){
       [self initRemoteIO];
    }  
    return self;
}

-(void) initRemoteIO{
    //configure AudioSession
    NSError * error;
    BOOL result = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
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
    AudioUnitSetProperty(self->audiounit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, INPUT_BUS, &audioFormat, sizeof(audioFormat));
    
    AudioUnitSetProperty(self->audiounit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, OUTPUT_BUS, &audioFormat, sizeof(audioFormat));
    
    UInt32 enableFlag = 1;
    AudioUnitSetProperty(self->audiounit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, INPUT_BUS, &enableFlag, sizeof(enableFlag));
    AudioUnitSetProperty(self->audiounit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, OUTPUT_BUS, &enableFlag, sizeof(enableFlag));
    UInt32 flag = 0;
    AudioUnitSetProperty(self->audiounit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, INPUT_BUS, &flag, sizeof(flag));
    
    //initialize bufferlist
    self->bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    self->bufferList->mNumberBuffers = 1;
    self->bufferList->mBuffers[0].mNumberChannels = 1;
    self->bufferList->mBuffers[0].mDataByteSize = 4096 *sizeof(short);
    self->bufferList->mBuffers[0].mData = (short *)malloc(self->bufferList->mBuffers[0].mDataByteSize);
    

    
    //set record callback
    AURenderCallbackStruct recordCallback;
    recordCallback.inputProc = RecordingCallback;
    recordCallback.inputProcRefCon = (__bridge void *)self;
    AudioUnitSetProperty(self->audiounit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, INPUT_BUS, &recordCallback, sizeof(recordCallback));
    
    //set play callback
    AURenderCallbackStruct playCallback;
    playCallback.inputProc = PlayingCallback;
    playCallback.inputProcRefCon = (__bridge void*)self;
    AudioUnitSetProperty(self->audiounit,kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, OUTPUT_BUS, &playCallback, sizeof(playCallback));
    AudioUnitInitialize(self->audiounit);
    
}

static  OSStatus RecordingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData){
    
    MyAudioUintRecorder *me = (__bridge MyAudioUintRecorder *) inRefCon;
    AudioUnitRender(me->audiounit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, me->bufferList);
    
    short *data = (short *)me->bufferList->mBuffers[0].mData;
    int dataSize = me->bufferList->mBuffers[0].mDataByteSize;
    
    NSLog(@"get %d byts LPCM data", dataSize);
    return noErr;
}

static  OSStatus PlayingCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData){
    
      MyAudioUintRecorder *me = (__bridge MyAudioUintRecorder *) inRefCon;
    AudioUnitRender(me->audiounit, ioActionFlags, inTimeStamp, INPUT_BUS, inNumberFrames, ioData);
    
    return noErr;
}


- (void) startRecording{
    AudioOutputUnitStart(self->audiounit);
}

- (void) stopRecording{
    AudioOutputUnitStop(self->audiounit);
}

@end
