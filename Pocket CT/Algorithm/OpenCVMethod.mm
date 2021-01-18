//
//  OpenCVMethod.m
//  CTDemo
//
//  Created by llj on 2020/10/6.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/types_c.h>
#import "OpenCVMethod.h"

@implementation OpenCVMethod

using namespace std;

+ (NSMutableArray *)getGrayImageData: (UIImage *)image {
    
    cv::Mat mat;
    cv::Mat gray;
    cv::Mat input;
    
    UIImageToMat(image, mat);
    cv::cvtColor(mat, gray, CV_RGB2GRAY);
    cv::resize(gray, input, cv::Size(512, 512));
    
    input.convertTo(input, CV_32FC1, 1.f/255);
    int kImageHeight = input.rows;
    int kImagewidth = input.cols;
    int kImageChannels = input.channels();
    NSLog(@"rows, cols, channels: %d, %d, %d", kImageHeight, kImagewidth, kImageChannels);
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int row = 0; row < kImageHeight; row++) {
        for (int col = 0; col < kImagewidth; col++) {
            float pixel = input.at<float>(row, col);
            [arr addObject:@(pixel)];
        }
    }
    return arr;
}

+ (UIImage *)convertArrayToImage: (NSMutableArray *)imageArr {
    
    cv::Mat mat(512, 512, CV_8UC4);
    for (int i = 0; i < mat.rows; i++) {
        for (int j = 0; j < mat.cols; j++) {
            if ([imageArr[i*512+j] intValue] == 255) {
                mat.at<cv::Vec4b>(i, j)[0] = 255;
                mat.at<cv::Vec4b>(i, j)[1] = 165;
                mat.at<cv::Vec4b>(i, j)[2] = 0;
                mat.at<cv::Vec4b>(i, j)[3] = 0.5 * 255;
            } else {
                mat.at<cv::Vec4b>(i, j)[0] = 0;
                mat.at<cv::Vec4b>(i, j)[1] = 0;
                mat.at<cv::Vec4b>(i, j)[2] = 0;
                mat.at<cv::Vec4b>(i, j)[3] = 0;
            }

        }
    }
    // MatToUIImage方法的传出类型为RGBA
    UIImage *image = MatToUIImage(mat);
    return image;
}


@end
