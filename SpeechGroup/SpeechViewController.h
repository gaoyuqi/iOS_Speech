//
//  SpeechViewController.h
//  SpeechDemo
//
//  Created by 李承軒 on 2017/8/13.
//  Copyright © 2017年 anochInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

//#import <Speech/SFSpeechRecognitionResult.h>
//#import <Speech/SFSpeechRecognitionRequest.h>
//#import <Speech/SFSpeechRecognitionTask.h>
//#import <Speech/SFSpeechRecognitionTaskHint.h>
//#import <Speech/SFSpeechRecognizer.h>
//#import <Speech/SFTranscriptionSegment.h>
//#import <Speech/SFTranscription.h>

@interface SpeechViewController : UIViewController <SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *realTimeTextView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *startSpeechingButton;

@property (nonatomic) SFSpeechRecognizer *recognizer;
@property (strong, nonatomic) AVSpeechSynthesizer *speechSynthesizer;
@property (strong, nonatomic) SFSpeechRecognitionTask *currentTask;

@end
