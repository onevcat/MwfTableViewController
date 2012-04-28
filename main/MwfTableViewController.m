//
//  MwfTableViewController.m
//  MwfTableViewController
//
//  Created by Meiwin Fu on 23/4/12.
//  Copyright (c) 2012 –MwF. All rights reserved.
//

#import "MwfTableViewController.h"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#define kAnimationDuration 0.3
#define kLvBgColor     [UIColor colorWithRed:(226/255.f) green:(231/255.f) blue:(237/255.f) alpha:1]
#define kLvTextColor   [UIColor colorWithRed:(136/255.f) green:(146/255.f) blue:(165/255.f) alpha:1]
#define kLvShadowColor [UIColor whiteColor]

#define $ip(_section_,_row_) [NSIndexPath indexPathForRow:(_row_) inSection:(_section_)]

#define $inMain(_blok_) \
  dispatch_async(dispatch_get_main_queue(), (_blok_))

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface MwfTableData (PrivateMethods)
- (NSArray *) dataArray;
- (NSArray *) sectionArray;
@end

@interface MwfTableDataUpdates (PrivateMethods)
- (void) setReloadRows:(NSArray *)reloadRows;
- (void) setDeleteRows:(NSArray *)deleteRows;
- (void) setInsertRows:(NSArray *)insertRows;
- (void) setReloadSections:(NSIndexSet *)reloadSections;
- (void) setDeleteSections:(NSIndexSet *)deleteSections;
- (void) setInsertSections:(NSIndexSet *)insertSections;
@end

@interface MwfTableDataWithSections : MwfTableData
@end

@interface MwfTableDataProxy : MwfTableData {
  MwfTableData * _proxiedTableData;
  NSArray * _originalTableData;
  NSArray * _originalTableSection;
  
  NSMutableArray * _deletedSections;
  NSMutableArray * _insertedSections;
  NSMutableArray * _reloadedSections;
  NSMutableArray * _deletedRows;
  NSMutableArray * _insertedRows;
  NSMutableArray * _reloadedRows;

  NSMutableIndexSet * _deletedSectionIndexSets;
  NSMutableIndexSet * _insertedSectionIndexSets;
  NSMutableIndexSet * _reloadedSectionIndexSets;
  NSMutableArray * _deletedRowIndexPaths;
  NSMutableArray * _insertedRowIndexPaths;
  NSMutableArray * _reloadedRowIndexPaths;
}
@property (nonatomic,readonly) NSIndexSet * deletedSectionIndexSets;
@property (nonatomic,readonly) NSIndexSet * insertedSectionIndexSets;
@property (nonatomic,readonly) NSIndexSet * reloadedSectionIndexSets;
@property (nonatomic,readonly) NSArray * deletedRowIndexPaths;
@property (nonatomic,readonly) NSArray * insertedRowIndexPaths;
@property (nonatomic,readonly) NSArray * reloadedRowIndexPaths;
- (id) initWithTableData:(MwfTableData *)tableData;
- (void) beginUpdates;
- (void) endUpdates;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@implementation MwfTableDataUpdates
@synthesize reloadRows = _reloadRows;
@synthesize deleteRows = _deleteRows;
@synthesize insertRows = _insertRows;
@synthesize reloadSections = _reloadSections;
@synthesize deleteSections = _deleteSections;
@synthesize insertSections = _insertSections;
- (void)setReloadRows:(NSArray *)reloadRows;
{
  _reloadRows = reloadRows;
}
- (void)setDeleteRows:(NSArray *)deleteRows;
{
  _deleteRows = deleteRows;
}
- (void)setInsertRows:(NSArray *)insertRows;
{
  _insertRows = insertRows;
}
- (void)setInsertSections:(NSIndexSet *)insertSections;
{
  _insertSections = insertSections;
}
- (void)setDeleteSections:(NSIndexSet *)deleteSections;
{
  _deleteSections = deleteSections;
}
- (void)setReloadSections:(NSIndexSet *)reloadSections;
{
  _reloadSections = reloadSections;
}
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
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
- (id) objectForSectionAtIndex:(NSUInteger)section;
{
  return nil;
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
- (mwf_ip)addRow:(id)object inSection:(NSUInteger)sectionIndex;
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
  return [self addRow:object inSection:0];
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
// Update data
- (NSUInteger)updateSection:(id)object atIndex:(NSUInteger)section;
{
  return NSNotFound;
}
- (mwf_ip)updateRow:(id)object atIndexPath:(mwf_ip)indexPath;
{
  mwf_ip ip = nil;
  if (object && indexPath) {
    [_dataArray removeObjectAtIndex:indexPath.row];
    [_dataArray insertObject:object atIndex:indexPath.row];
    ip = indexPath;
  }
  return ip;
}

// Bulk Updates
- (MwfTableDataUpdates *)performUpdates:(void(^)(MwfTableData *))updates;
{
  MwfTableDataUpdates * u = nil;
  if (updates != NULL) {
    MwfTableDataProxy * proxy = [[MwfTableDataProxy alloc] initWithTableData:self];
    [proxy beginUpdates];
    updates(proxy);
    [proxy endUpdates];
    u = [[MwfTableDataUpdates alloc] init];
    u.reloadSections = proxy.reloadedSectionIndexSets;
    u.deleteSections = proxy.deletedSectionIndexSets;
    u.insertSections = proxy.insertedSectionIndexSets;
    u.reloadRows = proxy.reloadedRowIndexPaths;
    u.deleteRows = proxy.deletedRowIndexPaths;
    u.insertRows = proxy.insertedRowIndexPaths;
  }
  return u;
}
// Private Methods
- (NSArray *) dataArray;
{
  return _dataArray;
}
- (NSArray *) sectionArray;
{
  return _sectionArray;
}
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
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
- (id) objectForSectionAtIndex:(NSUInteger)section;
{
  return [_sectionArray objectAtIndex:section];
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
- (mwf_ip)addRow:(id)object inSection:(NSUInteger)sectionIndex;
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
  return [self addRow:object inSection:0];
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
// Update data
- (NSUInteger)updateSection:(id)object atIndex:(NSUInteger)section;
{
  NSUInteger s = NSNotFound;
  if (object) {
    [_sectionArray removeObjectAtIndex:section];
    [_sectionArray insertObject:object atIndex:section];
    s = section;
  }
  return s;
}
- (mwf_ip)updateRow:(id)object atIndexPath:(mwf_ip)indexPath;
{
  mwf_ip ip = nil;
  if (object && indexPath) {
    NSMutableArray * rows = [_dataArray objectAtIndex:indexPath.section];
    [rows removeObjectAtIndex:indexPath.row];
    [rows insertObject:object atIndex:indexPath.row];
    ip = indexPath;
  }
  return ip;
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@implementation MwfTableDataProxy
@synthesize reloadedSectionIndexSets = _reloadedSectionIndexSets;
@synthesize deletedSectionIndexSets = _deletedSectionIndexSets;
@synthesize insertedSectionIndexSets = _insertedSectionIndexSets;
@synthesize reloadedRowIndexPaths = _reloadedRowIndexPaths;
@synthesize deletedRowIndexPaths = _deletedRowIndexPaths;
@synthesize insertedRowIndexPaths = _insertedRowIndexPaths;

- (id) initWithTableData:(MwfTableData *)tableData;
{
  self = [super init];
  if (self) {
    _proxiedTableData = tableData;
    _dataArray = nil;
    _sectionArray = nil;
  }
  return self;
}
// Updates
- (void)beginUpdates;
{
  _originalTableSection = [_proxiedTableData.sectionArray copy];
  if ([_proxiedTableData isKindOfClass:[MwfTableDataWithSections class]]) {
    NSMutableArray * originalTableData = [[NSMutableArray alloc] init];
    for (NSArray * rows in _proxiedTableData.dataArray) {
      [originalTableData addObject:[rows copy]];
    }
    _originalTableData = originalTableData;
  } else {
    _originalTableData = [_proxiedTableData.dataArray copy];
  }
  _deletedSections = [[NSMutableArray alloc] init];
  _insertedSections = [[NSMutableArray alloc] init];
  _reloadedSections = [[NSMutableArray alloc] init];
  _deletedRows = [[NSMutableArray alloc] init];
  _insertedRows = [[NSMutableArray alloc] init];
  _reloadedRows = [[NSMutableArray alloc] init];
}

- (NSUInteger) originalIndexForSection:(id)section;
{
  return [_originalTableSection indexOfObject:section];
}

- (mwf_ip) originalIndexPathForRow:(id)object;
{
  mwf_ip r = nil;
  NSUInteger section = 0;
  NSUInteger row = NSNotFound;
  if ([_proxiedTableData isKindOfClass:[MwfTableDataWithSections class]]) {
    for (NSArray * rows in _originalTableData) {
      row = [rows indexOfObject:object];
      if (row != NSNotFound) break;
      section++;
    }
  } else {
    row = [_originalTableData indexOfObject:object];
  }
  if (row != NSNotFound) {
    r = $ip(section,row);
  }
  return r;
}

- (void)endUpdates;
{
  if ([_reloadedSections count] > 0) _reloadedSectionIndexSets = [[NSMutableIndexSet alloc] init];
  if ([_deletedSections count] > 0) _deletedSectionIndexSets = [[NSMutableIndexSet alloc] init];
  if ([_insertedSections count] > 0) _insertedSectionIndexSets = [[NSMutableIndexSet alloc] init];
  if ([_reloadedRows count] > 0) _reloadedRowIndexPaths = [[NSMutableArray alloc] init];
  if ([_deletedRows count] > 0) _deletedRowIndexPaths = [[NSMutableArray alloc] init];
  if ([_insertedRows count] > 0) _insertedRowIndexPaths = [[NSMutableArray alloc] init];
  
  // reloaded rows
  for (id reloaded in _reloadedRows) {
    mwf_ip ip = [self originalIndexPathForRow:reloaded];
    if (ip && ![_reloadedRowIndexPaths containsObject:ip]) {
      [_reloadedRowIndexPaths addObject:ip];
    }
  }
  // reloaded sections
  for (id reloaded in _reloadedSections) {
    NSUInteger index = [self originalIndexForSection:reloaded];
    if (index != NSNotFound && ![_reloadedSectionIndexSets containsIndex:index]) {
      [_reloadedSectionIndexSets addIndex:index];
    }
  }
  
  // deleted rows
  for (id deleted in _deletedRows) {
    mwf_ip ip = [self originalIndexPathForRow:deleted];
    if (ip) {
      [_deletedRowIndexPaths addObject:ip];
    }
  }
  // deleted sections
  for (id deleted in _deletedSections) {
    NSUInteger index = [self originalIndexForSection:deleted];
    if (index != NSNotFound) {
      [_deletedSectionIndexSets addIndex:index];
    }
  }
  
  // inserted rows
  for (id inserted in _insertedRows) {
    mwf_ip ip = [self indexPathForRow:inserted];
    if (ip) {
      [_insertedRowIndexPaths addObject:ip];
    }
  }
  // inserted sections
  for (id inserted in _insertedSections) {
    NSUInteger index = [self indexForSection:inserted];
    if (index != NSNotFound) {
      [_insertedSectionIndexSets addIndex:index];
    }
  }
  
  // sorting the results
  NSComparisonResult(^Comparator)(mwf_ip ip1, mwf_ip ip2) = ^NSComparisonResult(mwf_ip ip1, mwf_ip ip2) {
    if (ip1.section == ip2.section) {
      return ip1.row > ip2.row ? NSOrderedDescending : NSOrderedAscending;
    }
    return ip1.section > ip2.section ? NSOrderedDescending : NSOrderedAscending;
  };
  
  [_reloadedSectionIndexSets removeIndexes:_deletedSectionIndexSets];
  [_reloadedRowIndexPaths removeObjectsInArray:_deletedRowIndexPaths];
  
  [_reloadedRowIndexPaths sortUsingComparator:Comparator];
  [_deletedRowIndexPaths sortUsingComparator:Comparator];
  [_insertedRowIndexPaths sortUsingComparator:Comparator];  

  _originalTableSection = nil;
  _originalTableData = nil;
  _deletedSections = nil;
  _insertedSections = nil;
  _reloadedSections = nil;
  _deletedRows = nil;
  _insertedRows = nil;
  _reloadedRows = nil;
 
}

// Accessing data
- (NSUInteger) numberOfSections;
{
  return _proxiedTableData.numberOfSections;
}
- (NSUInteger) numberOfRowsInSection:(NSUInteger)section;
{
  return [_proxiedTableData numberOfRowsInSection:section];
}
- (NSUInteger) numberOfRows;
{
  return _proxiedTableData.numberOfRows;
}
- (id) objectForRowAtIndexPath:(mwf_ip)ip;
{
  return [_proxiedTableData objectForRowAtIndexPath:ip];
}
- (mwf_ip) indexPathForRow:(id)object;
{
  return [_proxiedTableData indexPathForRow:object];
}
- (NSUInteger) indexForSection:(id)sectionObject;
{
  return [_proxiedTableData indexForSection:sectionObject];  
}

// Inserting data
- (NSUInteger)addSection:(id)sectionObject;
{
  NSUInteger r = [_proxiedTableData addSection:sectionObject];
  [_insertedSections addObject:sectionObject];
  return r;
}
- (NSUInteger)insertSection:(id)sectionObject atIndex:(NSUInteger)sectionIndex;
{
  NSUInteger r = [_proxiedTableData insertSection:sectionObject atIndex:sectionIndex];
  [_insertedSections addObject:sectionObject];
  return r;
}
- (mwf_ip)addRow:(id)object inSection:(NSUInteger)sectionIndex;
{
  mwf_ip r = [_proxiedTableData addRow:object inSection:sectionIndex];
  [_insertedRows addObject:object];
  return r;
}
- (mwf_ip)insertRow:(id)object atIndexPath:(mwf_ip)indexPath;
{
  mwf_ip r = [_proxiedTableData insertRow:object atIndexPath:indexPath];
  [_insertedRows addObject:object];
  return r;
}
- (mwf_ip)addRow:(id)object;
{
  mwf_ip r = [_proxiedTableData addRow:object];
  [_insertedRows addObject:object];
  return r;
}
- (mwf_ip)insertRow:(id)object atIndex:(NSUInteger)index;
{
  mwf_ip r = [_proxiedTableData insertRow:object atIndex:index];
  [_insertedRows addObject:object];
  return r;
}

// Deleting data
- (mwf_ip)removeRowAtIndexPath:(mwf_ip)indexPath;
{
  [_deletedRows addObject:[_proxiedTableData objectForRowAtIndexPath:indexPath]];
  mwf_ip r = [_proxiedTableData removeRowAtIndexPath:indexPath];
  return r;
}
- (NSUInteger)removeSectionAtIndex:(NSUInteger)sectionIndex;
{
  id deleted = [_proxiedTableData objectForSectionAtIndex:sectionIndex];
  [_deletedSections addObject:deleted];
  NSUInteger r = [_proxiedTableData removeSectionAtIndex:sectionIndex];
  return r;
}

// Update data
- (NSUInteger)updateSection:(id)object atIndex:(NSUInteger)section;
{
  id obj = [_proxiedTableData objectForSectionAtIndex:section];
  NSUInteger s = [_proxiedTableData updateSection:object atIndex:section];
  if (obj && s != NSNotFound) [_reloadedSections addObject:obj];
  return section;
}
- (mwf_ip)updateRow:(id)object atIndexPath:(mwf_ip)indexPath;
{
  id obj = [_proxiedTableData objectForRowAtIndexPath:indexPath];
  mwf_ip ip = [_proxiedTableData updateRow:object atIndexPath:indexPath];
  if (obj && ip) [_reloadedRows addObject:obj];
  return ip;
}

// Bulk Updates
- (MwfTableDataUpdates *)performUpdates:(void(^)(MwfTableData *))updates;
{
  [NSException raise:@"UnsupportedOperation" format:@"Unsupported operation"];
  return nil;
}
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
#pragma mark - MwfTableViewController
@interface MwfTableViewController ()
- (void)initialize;
@end

@implementation MwfTableViewController
@synthesize tableHeaderTopView = _tableHeaderTopView;
@synthesize loading            = _loading;
@synthesize loadingView        = _loadingView;
@synthesize loadingStyle       = _loadingStyle;
@synthesize tableData          = _tableData;

- (void)initialize;
{
  _tableData = [self createAndInitTableData];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self initialize];
  }
  return self;
}
- (id)initWithStyle:(UITableViewStyle)style;
{
  self = [super initWithStyle:style];
  if (self) {
    [self initialize];
  }
  return self;
}
- (void)awakeFromNib;
{
  [super awakeFromNib];
  [self initialize];
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

#pragma mark - Table Data
- (MwfTableData *)createAndInitTableData;
{
  return [MwfTableData createTableData];
}
- (void)setTableData:(MwfTableData *)tableData;
{
  if (tableData) {
    _tableData = tableData;
    __block MwfTableViewController * weakSelf = self;
    void(^go)(void) = ^{
      [weakSelf.tableView reloadData];
    };
    if ([NSThread isMainThread]) {
      go();
    } else {
      $inMain(go);
    }
  }
}
- (void)performUpdates:(void(^)(MwfTableData *))updates;
{
  if (updates != NULL) {
    MwfTableDataUpdates * u = [_tableData performUpdates:updates];
    if (u) {
      void(^go)(void) = ^{
        UITableViewRowAnimation rowAnimation = UITableViewRowAnimationAutomatic;
        [self.tableView beginUpdates];
        if (u.insertSections.count > 0) { 
          [self.tableView insertSections:u.insertSections withRowAnimation:rowAnimation]; 
        }
        if (u.deleteSections.count > 0) {
          [self.tableView deleteSections:u.deleteSections withRowAnimation:rowAnimation];
        }
        if (u.reloadSections.count > 0) {
          [self.tableView reloadSections:u.reloadSections withRowAnimation:rowAnimation];
        }
        if (u.deleteRows.count > 0) {
          [self.tableView deleteRowsAtIndexPaths:u.deleteRows withRowAnimation:rowAnimation];
        }
        if (u.reloadRows.count > 0) {
          [self.tableView reloadRowsAtIndexPaths:u.reloadRows withRowAnimation:rowAnimation];
        }
        if (u.insertRows.count > 0) {
          [self.tableView insertRowsAtIndexPaths:u.insertRows withRowAnimation:rowAnimation];
        }
        [self.tableView endUpdates];
      };
      if ([NSThread isMainThread]) {
        go();
      } else {
        $inMain(go);
      }
    }
  }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
  return _tableData.numberOfSections;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
  return [_tableData numberOfRowsInSection:section];
}
#pragma mark - UITableViewDelegate
@end
