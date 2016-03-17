//
//  SWAI.m
//  MotionGraphs
//
//  Created by kai.shang on 16/3/16.
//
//

#import "SWAI.h"

@interface SWAI()

@property(nonatomic, strong) NSMutableArray *sumUnitMAry;
@property(nonatomic, assign) double unitSum;
@property(nonatomic, assign) CGFloat startDuration; //启动时长
@property(nonatomic, assign) CGFloat sampleCount; //采样点个数
@property(nonatomic, assign) CGFloat sampleInterval; //采样点间隔
@property(nonatomic, assign) NSInteger unitSumIndex; //单元采样索引
@property(nonatomic, assign) NSInteger shun_counter_start; //启动采样点间隔规避计数
@property(nonatomic, assign) NSInteger shun_counter_stop;
@property(nonatomic, assign) CGFloat door; //判断是否为起停的门限
@end

@implementation SWAI

-(id) init{
    
    self = [super init];
    if (self) {
        _sumUnitMAry = [[NSMutableArray alloc] init];
        _startDuration = 6;
        _sampleInterval = 0.1;
        _sampleCount = _startDuration*(1/_sampleInterval);
        _unitSumIndex = -1;
        _shun_counter_start = (60/_sampleInterval); //一分钟对应的采样点个数
        _shun_counter_stop = (60/_sampleInterval);
        _door = 0.06;
    }
    return self;
}

-(ESuyWayState) getStateWithX:(double) x withY:(double) y{
    
    ESuyWayState state = ESW_Unkonwn;
    _unitSumIndex ++;
    
    //计算此时合加速度
    double a = sqrt(x*x+y*y);
    self.unitSum += a;
    
    if (_unitSumIndex>= _sampleCount) {
        self.unitSum -= [[self.sumUnitMAry firstObject] doubleValue];
        [self.sumUnitMAry removeObjectAtIndex:0];
    }
    
    [self.sumUnitMAry addObject:@(self.unitSum)];

    double current_distance = [[self.sumUnitMAry lastObject] doubleValue]-[[self.sumUnitMAry firstObject] doubleValue];
    
    
    if (_unitSumIndex < _sampleCount) {
        return state;
    }
    
    if (current_distance > _door*_sampleCount) {
        
        if (_shun_counter_start >= 600) {
            state = ESW_Start;
            _shun_counter_stop = 600;
            _shun_counter_start = 0;
        }
    }else if (current_distance < _door*_sampleCount){
        
        if (_shun_counter_stop >= 600) {
            state = ESW_Stop;
            _shun_counter_start = 600;
            _shun_counter_stop = 0;
        }
    }
    
    return state;
}

@end
