//
//  MwfTableViewController.m
//  MwfTableViewController
//
//  Created by Meiwin Fu on 23/4/12.
//  Copyright (c) 2012 –MwF. All rights reserved.
//

#import "MwfTableViewController.h"

#define kAnimationDuration 0.3
#define kLvBgColor     [UIColor colorWithRed:(226/255.f) green:(231/255.f) blue:(237/255.f) alpha:1]
#define kLvTextColor   [UIColor colorWithRed:(136/255.f) green:(146/255.f) blue:(165/255.f) alpha:1]
#define kLvShadowColor [UIColor whiteColor]

@implementation MwfDefaultTableLoadingView
@synthesize textLabel = _textLabel;
@synthesize activityIndicatorView = _activityIndicatorView;
- (id)initWithFrame:(CGRect)frame;
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor clearColor];
    
    UILabel * l = [[UILabel alloc] initWithFrame:CGRectZero];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = kLvTextColor;
    l.shadowColor = kLvShadowColor;
    l.font = [UIFont boldSystemFontOfSize:18];
    [self addSubview:l];
    _textLabel = l;
    _textLabel.text = NSLocalizedString(@"Loading...", @"Loading...");

    UIActivityIndicatorView * aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aiv.backgroundColor = [UIColor clearColor];
    [self addSubview:aiv];
    _activityIndicatorView = aiv;
    [_activityIndicatorView startAnimating];
    
    [self setNeedsLayout];
    
  }
  return self;
}
- (void)layoutSubviews;
{
  [super layoutSubviews];
  
  CGSize selfSize = self.bounds.size;
  
  [_textLabel sizeToFit];
  CGFloat labelW = _textLabel.bounds.size.width;
  if (labelW > selfSize.width-40) labelW = selfSize.width-40;
  CGFloat labelH = _textLabel.bounds.size.height;
  _textLabel.frame = CGRectMake(floor(((selfSize.width-labelW)/2)), floor((selfSize.height-labelH)/2), labelW, labelH);
  
  [_activityIndicatorView sizeToFit];
  CGSize aivSize = _activityIndicatorView.bounds.size;
  CGFloat aivH = aivSize.height;
  CGFloat aivW = aivSize.width;
  _activityIndicatorView.frame = CGRectMake(_textLabel.frame.origin.x-30, floor(_textLabel.frame.origin.y+(labelH-aivH)/2), aivW, aivH);
}
+ (MwfDefaultTableLoadingView *)create;
{
  return [[MwfDefaultTableLoadingView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
}
@end


@interface MwfTableViewController ()

@end

@implementation MwfTableViewController
@synthesize tableHeaderTopView = _tableHeaderTopView;
@synthesize loading            = _loading;
@synthesize loadingView        = _loadingView;
@synthesize loadingStyle       = _loadingStyle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}
- (void)loadView;
{
  [super loadView];
  
  CGRect b = self.view.bounds;

  if (self.tableView.style == UITableViewStylePlain) {
    
    // table header top view
    _tableHeaderTopView = [self createTableHeaderTopView];
    _tableHeaderTopView.frame = CGRectMake(0, -_tableHeaderTopView.bounds.size.height,
                                           b.size.width, _tableHeaderTopView.bounds.size.height);
    _tableHeaderTopView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:_tableHeaderTopView];
    
    // table footer bottom view
    _emptyTableFooterBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, b.size.width, 0)];
    _emptyTableFooterBottomView.backgroundColor = [UIColor clearColor];
    
  }
  
  _loadingView = [self createLoadingView];
  _loadingView.hidden = YES;
}

- (void)viewDidUnload;
{
  [super viewDidUnload];
  
  _tableHeaderTopView = nil;
  _emptyTableFooterBottomView = nil;
  _loadingView = nil;
}

#pragma mark - Loading
- (void)setLoading:(BOOL)loading;
{
  [self setLoading:loading animated:NO];
}
- (void)setLoadingStyle:(MwfTableViewLoadingStyle)loadingStyle;
{
  _loadingStyle = loadingStyle;
  if (_loadingStyle != MwfTableViewLoadingStyleFooter) {
    self.tableView.tableFooterView = nil;
  } else if (_loadingStyle == MwfTableViewLoadingStyleFooter) {
    self.tableView.tableFooterView = _emptyTableFooterBottomView;
  }
}
- (void)setLoading:(BOOL)loading animated:(BOOL)animated;
{
  if (_loading != loading) {
    _loading = loading;
    
    void(^beforeBlock)(void);
    void(^animBlock)(void);
    void(^afterBlock)(BOOL finished);

    __block MwfTableViewController * weakSelf = self;
    if (_loadingStyle == MwfTableViewLoadingStyleHeader) {
      if (_loading) {
        beforeBlock = ^{ 
          _loadingView.frame = CGRectMake(0,-_loadingView.bounds.size.height,_loadingView.bounds.size.width,_loadingView.bounds.size.height);
          [weakSelf.view addSubview:_loadingView];
          [weakSelf willShowLoadingView:_loadingView];
          _loadingView.hidden = NO;
          weakSelf.tableView.contentInset = UIEdgeInsetsMake(_loadingView.bounds.size.height, 0, 0, 0);
        };
        animBlock = ^{ 
          weakSelf.tableView.contentOffset = CGPointMake(0, -_loadingView.bounds.size.height); 
        };
        afterBlock = NULL;
      } else {
        beforeBlock = NULL;
        animBlock = ^{ 
          weakSelf.tableView.contentInset = UIEdgeInsetsZero;      
          weakSelf.tableView.contentOffset = CGPointZero;
        };
        afterBlock = ^(BOOL finished) { 
          if (finished) {
            _loadingView.hidden = YES;
            [_loadingView removeFromSuperview];
            [weakSelf didHideLoadingView:_loadingView];
          }
        };
      }
    } else if (_loadingStyle == MwfTableViewLoadingStyleFooter) {
      if (_loading) {
        beforeBlock = ^{
          weakSelf.tableView.tableFooterView = _loadingView;
          [weakSelf willShowLoadingView:_loadingView];
          _loadingView.hidden = NO;
          CGFloat contentH = weakSelf.tableView.contentSize.height;
          [weakSelf.tableView scrollRectToVisible:CGRectMake(0, contentH-_loadingView.bounds.size.height,
                                                             weakSelf.tableView.bounds.size.width, _loadingView.bounds.size.height) 
                                         animated:YES];
        };
      } else {
        afterBlock = ^(BOOL finished) {
          if (finished) {
            _loadingView.hidden = YES;
            [weakSelf didHideLoadingView:_loadingView];
            weakSelf.tableView.tableFooterView = _emptyTableFooterBottomView;
          }
        };
      }
    }

    if (beforeBlock != NULL) beforeBlock();
    if (animated && animBlock != NULL) {
      [UIView animateWithDuration:kAnimationDuration animations:animBlock completion:afterBlock];
    } else {
      if (animBlock != NULL) {
        animBlock();
      }
      if (afterBlock != NULL) {
        afterBlock(YES);
      }
    }
  }
}

#pragma mark - OverrideForCustomView
- (UIView *) createTableHeaderTopView;
{
  CGRect b = self.view.bounds;
  UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, b.size.width, 1000)];
  view.backgroundColor = kLvBgColor;
  return view;
}

- (UIView *) createLoadingView;
{
  return [MwfDefaultTableLoadingView create];
}
- (void)willShowLoadingView:(UIView *)loadingView;
{
  if ([loadingView isKindOfClass:[MwfDefaultTableLoadingView class]]) {
    MwfDefaultTableLoadingView * defaultLoadingView = (MwfDefaultTableLoadingView *)loadingView;
    [defaultLoadingView.activityIndicatorView startAnimating];
  }
}
- (void)didHideLoadingView:(UIView *)loadingView;
{
  if ([loadingView isKindOfClass:[MwfDefaultTableLoadingView class]]) {
    MwfDefaultTableLoadingView * defaultLoadingView = (MwfDefaultTableLoadingView *)loadingView;
    [defaultLoadingView.activityIndicatorView stopAnimating];
  }
}
@end
