//
//  SaveFile.h
//  MotionGraphs
//
//  Created by kai.shang on 16/3/9.
//
//

#import <Foundation/Foundation.h>

@interface SaveFile : NSObject
@property(nonatomic, strong)NSString* fileName;

-(NSString*) getFileName;
-(void) writeFile:(NSArray *)ary;


-(NSArray*) getAryWithFile;

@end
