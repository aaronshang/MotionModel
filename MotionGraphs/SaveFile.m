//
//  SaveFile.m
//  MotionGraphs
//
//  Created by kai.shang on 16/3/9.
//
//

#import "SaveFile.h"

@implementation SaveFile

-(NSString*) getFileName{
    
    NSDate *date = [NSDate date];

    //NSDateFormatter实现日期的输出
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [formatter stringFromDate:date];

    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *name = [NSString stringWithFormat:@"%@.json", time];
    
    return [documentsDirectory stringByAppendingPathComponent:name];
}

-(void) writeFile:(NSArray *)ary{
    
    if (!self.fileName) {
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[self toJSONData:ary]
                                                 encoding:NSUTF8StringEncoding];
    
    [jsonString writeToFile:self.fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

@end
