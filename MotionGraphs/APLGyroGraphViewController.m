
/*
     File: APLGyroGraphViewController.m
 Abstract: View controller to manage display of output from the gyroscope.

  Version: 1.0.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "APLGyroGraphViewController.h"
#import "APLAppDelegate.h"
#import "APLGraphView.h"
#import "SaveFile.h"
#import "SWAI.h"

static const NSTimeInterval gyroMin = 0.1;

@interface APLGyroGraphViewController ()

@property (nonatomic, weak) IBOutlet APLGraphView *graphView;
@property (nonatomic, strong) NSMutableArray *mMAry;
@property (nonatomic, assign) NSInteger sample;
@property (nonatomic, strong) SaveFile *saveFile;
@property (nonatomic, assign) NSInteger state;//1，启动；2，停止

@property (nonatomic, assign) BOOL isCreateFile;//是否创建了文件

@property(nonatomic, strong) SWAI *swAI;
@property(nonatomic, assign) BOOL playbackMode;
@end


@implementation APLGyroGraphViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.mMAry) {
        self.mMAry = [[NSMutableArray alloc] initWithCapacity:10];
    }
    self.sample = 0;
    self.saveFile = [[SaveFile alloc] init];
    
    [self.fileBtn addTarget:self action:@selector(operateFile) forControlEvents:UIControlEventTouchUpInside];
    self.isCreateFile = NO;
    
    self.swAI = [[SWAI alloc] init];
    
    _playbackMode  = NO;
}

-(void) operateFile{
    
    if (!self.isCreateFile) {
        
        //创建文件
        self.saveFile.fileName = [self.saveFile getFileName];
        self.isCreateFile = YES;
        [self.fileBtn setTitle:@"关闭文件" forState:UIControlStateNormal];
    }else{
        
        //关闭文件
        [self.saveFile writeFile:self.mMAry];
        
        [self.fileBtn setTitle:@"创建文件" forState:UIControlStateNormal];
        self.isCreateFile = NO;
    }
}


- (void)startUpdatesWithSliderValue:(int)sliderValue
{
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = gyroMin + delta * sliderValue;

    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    APLGyroGraphViewController * __weak weakSelf = self;
    if ([mManager isAccelerometerAvailable] == YES) {
        [mManager setAccelerometerUpdateInterval:updateInterval];
        [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            
            if (self.playbackMode) {
                return ;
            }
            
            
            [weakSelf.graphView addX:accelerometerData.acceleration.x y:accelerometerData.acceleration.y z:accelerometerData.acceleration.z];
            [weakSelf setLabelValueX:accelerometerData.acceleration.x y:accelerometerData.acceleration.y z:accelerometerData.acceleration.z];
            
            weakSelf.sample++;
            
            ESuyWayState curState = [weakSelf.swAI getStateWithX:accelerometerData.acceleration.x withY:accelerometerData.acceleration.y];
            
            [weakSelf.mMAry addObject:@{@"interval":@(updateInterval),
                                        @"x":@(accelerometerData.acceleration.x),
                                        @"y":@(accelerometerData.acceleration.y),
                                        @"z":@(accelerometerData.acceleration.z),
                                        @"sample":@(_sample),
                                        @"state":@(_state),
                                        @"sk_judge":@(curState)}];
            
            if (_state!=0) {
                _state = 0;
            }
            
            if (curState == ESW_Start  || curState == ESW_Stop) {
                [weakSelf showCarState:curState];
            }
        }];
    }
    
    
    self.updateIntervalLabel.text = [NSString stringWithFormat:@"%.2f", updateInterval];
}


- (void)stopUpdates
{
    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    if ([mManager isGyroActive] == YES) {
        [mManager stopGyroUpdates];
    }
}

-(void) showCarState:(ESuyWayState) state{
    
    NSDate *curDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    NSString *timeStr = [formatter stringFromDate:curDate];
    
    if (state == ESW_Start) {
        self.carStateLabel.text = [NSString stringWithFormat:@"%@ 起动",timeStr];
    }else if(state == ESW_Stop){
        self.carStateLabel.text = [NSString stringWithFormat:@"%@ 到站",timeStr];
    }
    
    if (self.playbackMode) {
        [self.carStateLabel setTextColor:[UIColor redColor]];
    }else{
        [self.carStateLabel setTextColor:[UIColor blackColor]];
    }
}

-(IBAction) carStart:(id)sender{

    NSLog(@"car start");
    self.state = 4;
}

-(IBAction) carStop:(id)sender{

    NSLog(@"car stop");
    self.state = -4;
}

-(IBAction) reportError:(id)sender{
    
    self.state = 8;
}

-(IBAction) runing:(id)sender{
    
    NSLog(@"running");
    self.state = 1;
}

-(IBAction) playback:(id)sender{

    if (self.playbackMode) {
        
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"回放中" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [aler show];
        return;
    }
    
    self.playbackMode = YES;
    
    self.swAI = [[SWAI alloc] init];
    
    __block long startTimes = 0;
    __block long stopTimes = 0;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *unitAry = [self.saveFile getAryWithFile];
        
        for (NSDictionary *dic in unitAry) {
            
            double x = [dic[@"x"] doubleValue];
            double y = [dic[@"y"] doubleValue];
            double z = [dic[@"z"] doubleValue];
            
            ESuyWayState state =  [self.swAI getStateWithX:x withY:y];
            if (state == ESW_Start) {
                startTimes ++;
            }else if(state == ESW_Stop){
                stopTimes ++;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showCarState:state];
                [self setLabelValueX:x y:y z:z];
            });
        
            usleep(10000);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.carStateLabel.text = [NSString stringWithFormat:@"start %ld; stop %ld", startTimes, stopTimes];
        });
        
        sleep(5);
        self.playbackMode = NO;
    });
    
   
}


@end
