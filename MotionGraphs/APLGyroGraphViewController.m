
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

static const NSTimeInterval gyroMin = 0.1;

@interface APLGyroGraphViewController ()

@property (nonatomic, weak) IBOutlet APLGraphView *graphView;
@property (nonatomic, strong) NSMutableArray *mMAry;
@property (nonatomic, assign) NSInteger sample;
@property (nonatomic, strong) SaveFile *saveFile;
@property (nonatomic, assign) NSInteger state;//1，启动；2，停止

@property (nonatomic, assign) BOOL isCreateFile;//是否创建了文件
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
    if ([mManager isGyroAvailable] == YES) {
        [mManager setGyroUpdateInterval:updateInterval];
        [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
            [weakSelf.graphView addX:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z];
            [weakSelf setLabelValueX:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z];
            
            weakSelf.sample++;
            [weakSelf.mMAry addObject:@{@"interval":@(updateInterval),
                                    @"x":@(gyroData.rotationRate.x),
                                    @"y":@(gyroData.rotationRate.y),
                                    @"z":@(gyroData.rotationRate.z),
                                    @"sample":@(_sample),
                                    @"state":@(_state)}];
            
            if (_state!=0) {
                _state = 0;
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

-(IBAction) carStart:(id)sender{

    NSLog(@"car start");
    self.state = 4;
}

-(IBAction) carStop:(id)sender{

    NSLog(@"car stop");
    self.state = -4;
}

-(IBAction) runing:(id)sender{
    
    NSLog(@"running");
    self.state = 1;
}




@end
