//
//  WKPagesScrollView.m
//  WKPagesScrollView
//
//  Created by 秦 道平 on 13-11-14.
//  Copyright (c) 2013年 秦 道平. All rights reserved.
//

#import "WKPagesCollectionView.h"
@implementation WKPagesCollectionView
@dynamic maskShow;
-(id)initWithPagesFlowLayoutAndFrame:(CGRect)frame{
    WKPagesCollectionViewFlowLayout* flowLayout=[[[WKPagesCollectionViewFlowLayout alloc]init] autorelease];
    self=[super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self){
        self.contentInset=UIEdgeInsetsMake(-100.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}
-(void)dealloc{
    [_maskImageView release];
    [super dealloc];
}
-(void)setMaskShow:(BOOL)maskShow{
    _maskShow=maskShow;
    if (maskShow){
        if (!_maskImageView){
            _maskImageView=[[UIImageView alloc]initWithImage:[self makeGradientImage]];
            [self.superview addSubview:_maskImageView];
        }
        _maskImageView.hidden=NO;
    }
    else{
        _maskImageView.hidden=YES;
    }
}
-(BOOL)maskShow{
    return _maskShow;
}
-(UIImage*)makeGradientImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1.0f);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.2, 0.9};
    CGFloat components[8] = { 0.0,0.0,0.0, 0.0,  // Start color
        0.0,0.0,0.0,1.0}; // End color
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    CGPoint myStartPoint={self.bounds.size.width/2,self.bounds.size.height/2};
    CGFloat myStartRadius=0, myEndRadius=self.bounds.size.width*1.5;
    CGContextDrawRadialGradient (context, myGradient, myStartPoint,
                                 myStartRadius, myStartPoint, myEndRadius,
                                 kCGGradientDrawsAfterEndLocation);
    
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    NSLog(@"image size:%@",NSStringFromCGSize(image.size));
    return image;
}
#pragma mark - Actions
-(void)showCellToHighLightAtIndexPath:(NSIndexPath *)indexPath{
    if (_isHighLight){
        return;
    }
    self.maskShow=NO;
    self.scrollEnabled=NO;
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
            NSIndexPath* visibleIndexPath=[self indexPathForCell:cell];
            if (visibleIndexPath.row==indexPath.row){
                cell.showingState=WKPagesCollectionViewCellShowingStateHightlight;
            }
            else if (visibleIndexPath.row<indexPath.row){
                cell.showingState=WKPagesCollectionViewCellShowingStateBackToTop;
            }
            else if (visibleIndexPath.row>indexPath.row){
                cell.showingState=WKPagesCollectionViewCellShowingStateBackToBottom;
            }
            else{
                cell.showingState=WKPagesCollectionViewCellShowingStateNormal;
            }
        }];
    } completion:^(BOOL finished) {
        _isHighLight=YES;
    }];
}
///回到原来的状态
-(void)dismissFromHightLight{
    self.maskShow=YES;
    if (!_isHighLight)
        return;
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.visibleCells enumerateObjectsUsingBlock:^(WKPagesCollectionViewCell* cell, NSUInteger idx, BOOL *stop) {
            cell.showingState=WKPagesCollectionViewCellShowingStateNormal;
        }];
    } completion:^(BOOL finished) {
        self.scrollEnabled=YES;
        _isHighLight=NO;
    }];
}
#pragma mark - UIView and UICollectionView
-(void)reloadData{
    [super reloadData];
    
}
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* view=[super hitTest:point withEvent:event];
    if (!view){
        return nil;
    }
    if (view==self){
        for (WKPagesCollectionViewCell* cell in self.visibleCells) {
            if (cell.showingState==WKPagesCollectionViewCellShowingStateHightlight){
                return cell.cellContentView;///要把事件传递到这一层才可以
            }
        }
    }
    return view;
//    UIView* view=[super hitTest:point withEvent:event];
//    NSLog(@"%@,%d",NSStringFromClass([view class]),view.tag);
//    return view;
}
@end
