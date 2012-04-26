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

#define $ip(_section_,_row_) [NSIndexPath indexPathForRow:(_row_) inSection:(_section_)]

#pragma mark - MwfTableData
@interface MwfTableDataWithSections : MwfTableData
@end

@implementation MwfTableData
- (id)init {
  self = [super init];
  if (self) {
    _dataArray = [[NSMutableArray alloc] init];
  }
  return self;
}
// Creating instance
+ (MwfTableData *) createTableData;
{
  return [[MwfTableData alloc] init];
}
+ (MwfTableData *) createTableDataWithSections;
{
  return [[MwfTableDataWithSections alloc] init];
}
// Accessing data
- (NSUInteger) numberOfSections;
{
  return 1;
}
- (NSUInteger) numberOfRowsInSection:(NSUInteger)section;
{
  NSUInteger rowsCount = NSNotFound;
  if (section == 0) {
    rowsCount = _dataArray.count;
  }
  return rowsCount;
}
- (NSUInteger) numberOfRows;
{
  return [self numberOfRowsInSection:0];
}

- (id)objectForRowAtIndexPath:(mwf_ip)ip;
{
  id object = nil;
  if (ip && ip.section == 0) {
    object = [_dataArray objectAtIndex:ip.row];
  } else if (ip.section != 0) {
    [NSException raise:@"UnsupportedOperation" format:@"Accessing object of non-0 section is not supported."];
  }
  return object;
}
- (mwf_ip) indexPathForRow:(id)object;
{
  NSUInteger idx = NSNotFound;
  if (object) {
    idx = [_dataArray indexOfObject:object];
  }
  mwf_ip ip = nil;
  if (idx != NSNotFound) ip = $ip(0,idx);
  return ip;
}
- (NSUInteger) indexForSection:(id)sectionObject;
{
  return NSNotFound;
}
// Inserting data
- (NSUInteger)addSection:(id)sectionObject;
{
  return [self insertSection:sectionObject atIndex:0];
}
- (NSUInteger)insertSection:(id)sectionObject atIndex:(NSUInteger)sectionIndex;
{
  [NSException raise:@"UnsupportedOperation" format:@"Adding section is not supported."];
  return NSNotFound;
}
- (mwf_ip)addRow:(id)object atSection:(NSUInteger)sectionIndex;
{
  mwf_ip ip = nil;
  if (object && sectionIndex == 0) {
    [_dataArray addObject:object];
    ip = $ip(0,[_dataArray count]-1);
  }
  return ip;
}
- (mwf_ip)insertRow:(id)object atIndexPath:(mwf_ip)indexPath;
{
  mwf_ip ip = nil;
  if (object && indexPath.section == 0) {
    [_dataArray insertObject:object atIndex:indexPath.row];
    ip = indexPath;
  } else if (indexPath.section != 0) {
    [NSException raise:@"UnsupportedOperation" format:@"Adding row in non-0 section is not supported."];
  }
  return ip;
}
- (mwf_ip)addRow:(id)object;
{
  return [self addRow:object atSection:0];
}
- (mwf_ip)insertRow:(id)object atIndex:(NSUInteger)index;
{
  return [self insertRow:object atIndexPath:$ip(0,index)];
}

// Deleting data
- (NSUInteger)removeSectionAtIndex:(NSUInteger)sectionIndex;
{
  [NSException raise:@"UnsupportedOperation" format:@"Removing section is not supported."];
  return NSNotFound;
}
- (mwf_ip)removeRowAtIndexPath:(mwf_ip)indexPath;
{
  mwf_ip ip = nil;
  if (indexPath && indexPath.section == 0) {
    [_dataArray removeObjectAtIndex:indexPath.row];
    ip = indexPath;
  } else if (indexPath.section != 0) {
    [NSException raise:@"UnsupportedOperation" format:@"Removing row in non-0 section is not supported."];
  }
  return ip;
}
// Bulk Updates
- (void)performUpdates:(void(^)(MwfTableData *))updates;
{
  
}
@end

#pragma mark - MwfTableDataWithSections
@implementation MwfTableDataWithSections
// Private Mehos
- (NSMutableArray *) $section:(NSUInteger)section;
{
  return (NSMutableArray *) [_dataArray objectAtIndex:section];
}

// Init
- (id)init {
  self = [super init];
  if (self) {
    _sectionArray = [[NSMutableArray alloc] init];
  }
  return self;
}

// Accessing data
- (NSUInteger) numberOfSections;
{
  return [_dataArray count];
}
- (NSUInteger) numberOfRowsInSection:(NSUInteger)section;
{
  return [self $section:section].count;
}
- (NSUInteger) numberOfRows;
{
  return [self numberOfRowsInSection:0];
}
- (id)objectForRowAtIndexPath:(mwf_ip)ip;
{
  id object = nil;
  if (ip) {
    object = [[self $section:ip.section] objectAtIndex:ip.row];
  }
  return object;
}
- (mwf_ip) indexPathForRow:(id)object;
{
  NSUInteger section = 0;
  NSUInteger idx = NSNotFound;
  if (object) {
    for (NSArray * arr in _dataArray) {
      idx = [arr indexOfObject:object];
      if (idx != NSNotFound) break;
      section++;
    }
  }
  mwf_ip ip = nil;
  if (idx != NSNotFound) ip = $ip(section,idx);
  return ip;
}
- (NSUInteger) indexForSection:(id)sectionObject;
{
  return [_sectionArray indexOfObject:sectionObject];
}

// Inserting data
- (NSUInteger)addSection:(id)sectionObject;
{
  NSUInteger section = NSNotFound;
  if (sectionObject) {
    [_sectionArray addObject:sectionObject];
    section = [_sectionArray count]-1;
    [_dataArray addObject:[[NSMutableArray alloc] init]];
  }
  return section;
}
- (NSUInteger)insertSection:(id)sectionObject atIndex:(NSUInteger)sectionIndex;
{
  NSUInteger section = NSNotFound;
  if (sectionObject) {
    [_sectionArray insertObject:sectionObject atIndex:sectionIndex];
    [_dataArray insertObject:[[NSMutableArray alloc] init] atIndex:sectionIndex];
    section = sectionIndex;
  }
  return section;
}
- (mwf_ip)addRow:(id)object atSection:(NSUInteger)sectionIndex;
{
  mwf_ip ip = nil;
  if (object) {
    NSMutableArray * arr = [self $section:sectionIndex];
    [arr addObject:object];
    ip = $ip(sectionIndex, [arr count]-1);
  }
  return ip;
}
- (mwf_ip)insertRow:(id)object atIndexPath:(mwf_ip)indexPath;
{
  mwf_ip ip = nil;
  if (object && indexPath) {
    NSMutableArray * arr = [self $section:indexPath.section];
    [arr insertObject:object atIndex:indexPath.row];
    ip = indexPath;
  }
  return ip;
}
- (mwf_ip)addRow:(id)object;
{
  return [self addRow:object atSection:0];
}
- (mwf_ip)insertRow:(id)object atIndex:(NSUInteger)index;
{
  return [self insertRow:object atIndexPath:$ip(0,index)];
}

// Deleting data
- (NSUInteger)removeSectionAtIndex:(NSUInteger)sectionIndex;
{
  NSUInteger section = NSNotFound;
  [_sectionArray removeObjectAtIndex:sectionIndex];
  [_dataArray removeObjectAtIndex:sectionIndex];
  section = sectionIndex;
  return section;
}
- (mwf_ip)removeRowAtIndexPath:(mwf_ip)indexPath;
{
  mwf_ip ip = nil;
  if (indexPath) {
    NSMutableArray * arr = [self $section:indexPath.section];
    [arr removeObjectAtIndex:indexPath.row];
    ip = indexPath;
  }
  return ip;
}
// Bulk Updates
- (void)performUpdates:(void(^)(MwfTableData *))updates;
{
  
}
@end

#pragma mark - MwfDefaultTableLoadingView
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

#pragma mark - MwfTableViewController
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
