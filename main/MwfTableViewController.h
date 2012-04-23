//
//  MwfTableViewController.h
//  MwfTableViewController
//
//  Created by Meiwin Fu on 23/4/12.
//  Copyright (c) 2012 –MwF. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  MwfTableViewLoadingStyleHeader = 0, // default
  MwfTableViewLoadingStyleFooter
} MwfTableViewLoadingStyle;

@interface MwfTableViewController : UITableViewController {
  UIView * _emptyTableFooterBottomView;
}
@property (nonatomic) MwfTableViewLoadingStyle       loadingStyle;
@property (nonatomic) BOOL                           loading;
@property (nonatomic,readonly) UIView              * tableHeaderTopView;
@property (nonatomic,readonly) UIView              * loadingView;
- (void)setLoading:(BOOL)loading animated:(BOOL)animated;
@end

@interface MwfTableViewController (BackgroundLoading)
@end

@interface MwfTableViewController (OverrideForCustomView)
- (UIView *)createTableHeaderTopView;
- (UIView *)createLoadingView;
- (void)willShowLoadingView:(UIView *)loadingView;
- (void)didHideLoadingView:(UIView *)loadingView;
@end

@interface MwfDefaultTableLoadingView : UIView
@property (nonatomic,readonly) UILabel * textLabel;
@property (nonatomic,readonly) UIActivityIndicatorView * activityIndicatorView;
+ (MwfDefaultTableLoadingView *)create;
@end
