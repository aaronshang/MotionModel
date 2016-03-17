//
//  SWAI.h
//  MotionGraphs
//
//  Created by kai.shang on 16/3/16.
//
//

#import <Foundation/Foundation.h>

typedef enum ESuyWayState{
    ESW_Unkonwn=0,
    ESW_Start=4,
    ESW_Stop=-4
}ESuyWayState;

@interface SWAI : NSObject

-(ESuyWayState) getStateWithX:(double) x withY:(double) y;

@end
