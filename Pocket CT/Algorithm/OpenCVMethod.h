//
//  OpenCVMethod.h
//  CTDemo
//
//  Created by llj on 2020/10/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVMethod : NSObject

+ (NSMutableArray *)getGrayImageData: (UIImage *)image;
+ (UIImage *)convertArrayToImage: (NSMutableArray *)imageArr;

@end

NS_ASSUME_NONNULL_END
