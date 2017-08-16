//
//  SpeechViewController.m
//  SpeechDemo
//
//  Created by 李承軒 on 2017/8/13.
//  Copyright © 2017年 anochInfo. All rights reserved.
//

#import "SpeechViewController.h"

@interface SpeechViewController () {
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
    
    SFSpeechAudioBufferRecognitionRequest *request2;
    AVAudioInputNode *inputNode;
}

@end

@implementation SpeechViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.realTimeTextView.layer.cornerRadius = 7.5;
    self.realTimeTextView.layer.masksToBounds = YES;
    
    self.inputTextView.layer.cornerRadius = 7.5;
    self.inputTextView.layer.masksToBounds = YES;
    
    [self.startSpeechingButton addTarget:self action:@selector(startAudioRecording) forControlEvents:UIControlEventTouchDown];
    [self.startSpeechingButton addTarget:self action:@selector(stopAudioRecording) forControlEvents:UIControlEventTouchUpInside];
    
    [self.startSpeechingButton setBackgroundColor:[UIColor greenColor]];
    
    self.startSpeechingButton.layer.cornerRadius = 35;
    self.startSpeechingButton.layer.masksToBounds = YES;

    //        _recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    _recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_TW"]];
    _recognizer.delegate = self;
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus authStatus) {
        switch (authStatus) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                //User gave access to speech recognition
                NSLog(@"Authorized");
                break;
                
            case SFSpeechRecognizerAuthorizationStatusDenied:
                //User denied access to speech recognition
                NSLog(@"SFSpeechRecognizerAuthorizationStatusDenied");
                break;
                
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                //Speech recognition restricted on this device
                NSLog(@"SFSpeechRecognizerAuthorizationStatusRestricted");
                break;
                
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                //Speech recognition not yet authorized
                
                break;
                
            default:
                NSLog(@"Default");
                break;
        }
    }];
    
    audioEngine = [[AVAudioEngine alloc] init];
    _speechSynthesizer  = [[AVSpeechSynthesizer alloc] init];
    [_speechSynthesizer setDelegate:self];
}

- (void)startAudioRecording {
    [self.startSpeechingButton setBackgroundColor:[UIColor redColor]];
    
    NSError * outError;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&outError];
    [audioSession setMode:AVAudioSessionModeMeasurement error:&outError];
    [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation  error:&outError];
    
    request2 = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    inputNode = [audioEngine inputNode];
    
    if (request2 == nil) {
        NSLog(@"Unable to created a SFSpeechAudioBufferRecognitionRequest object");
    }
    
    if (inputNode == nil) {
        
        NSLog(@"Unable to created a inputNode object");
    }
    
    request2.shouldReportPartialResults = true;
    
    _currentTask = [_recognizer recognitionTaskWithRequest:request2
                                                  delegate:self];
    
    [inputNode installTapOnBus:0 bufferSize:1024 format:[inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when){
        NSLog(@"Block tap!");
        
        [request2 appendAudioPCMBuffer:buffer];
        
    }];
    
    [audioEngine prepare];
    [audioEngine startAndReturnError:&outError];
    NSLog(@"Error %@", outError);
}

- (void)stopAudioRecording {
    [self.startSpeechingButton setBackgroundColor:[UIColor greenColor]];
    [audioEngine stop];
    [request2 endAudio];
//    _currentTask = nil;
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription {
    NSString *textString = _realTimeTextView.text;
    textString = [textString stringByReplacingOccurrencesOfString:@"請說出你要輸入的文字" withString:@""];
    textString = [textString stringByAppendingString:[transcription formattedString]];
    _realTimeTextView.text = textString;
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)result {
//    NSLog(@"speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition");
    NSString * translatedString = [[[result bestTranscription] formattedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *textString = _inputTextView.text;
    textString = [textString stringByReplacingOccurrencesOfString:@"請說出你要輸入的文字" withString:@""];
    textString = [textString stringByAppendingString:translatedString];
    _inputTextView.text = [NSString stringWithFormat:@"%@，", textString];
    
    if ([result isFinal]) {
        [audioEngine stop];
        [inputNode removeTapOnBus:0];
        _currentTask = nil;
        request2 = nil;
    }
}


@end
