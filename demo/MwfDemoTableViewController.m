//
//  MwfDemoTableViewController.m
//  MwfTableViewController
//
//  Created by Meiwin Fu on 23/4/12.
//  Copyright (c) 2012 –MwF. All rights reserved.
//

#import "MwfDemoTableViewController.h"

@interface MwfDemoTableViewController ()
- (void)loadMoreInTheBackground;
@end

@interface DemoData : NSObject
@property (nonatomic,retain) NSString * value;
- (id)initWithValue:(NSString *)value;
@end

@implementation DemoData
@synthesize value = _value;
- (id)initWithValue:(NSString *)value;
{
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
@end

#define $data(_val_) [[DemoData alloc] initWithValue:(_val_)]

@implementation MwfDemoTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"No Section";
    // self.loadingStyle = MwfTableViewLoadingStyleFooter;
  }
  return self;
}

- (void)loadView {
  [super loadView];
  
  UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
  [searchBar sizeToFit];
  self.tableView.tableHeaderView = searchBar;
  self.tableView.contentOffset = CGPointMake(0,searchBar.bounds.size.height);
  
  UIBarButtonItem * toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" 
                                                                    style:UIBarButtonItemStyleBordered 
                                                                   target:self 
                                                                   action:@selector(toggle:)];
  self.navigationItem.rightBarButtonItem = toggleButton;
}

- (void)viewDidLoad
{
  [super viewDidLoad];  
  __attribute__((__unused__)) UISearchDisplayController * sdc = [[UISearchDisplayController alloc] initWithSearchBar:((UISearchBar*)self.tableView.tableHeaderView) contentsController:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  cell.textLabel.text = ((DemoData *)[self.tableData objectForRowAtIndexPath:indexPath]).value;
  
  return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  return 60;
}

- (MwfTableData *)createAndInitTableData;
{
  MwfTableData * tableData = [MwfTableData createTableData];
  [tableData addRow:$data(@"Row 1")];
  [tableData addRow:$data(@"Row 2")];
  [tableData addRow:$data(@"Row 3")];
  [tableData addRow:$data(@"Load More")];
  return tableData;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  MwfTableData * tableData = self.tableData;
  DemoData * row = [tableData objectForRowAtIndexPath:indexPath];
  if ([@"Load More" isEqual:row.value]) {
    [self performUpdates:^(MwfTableData * data) {
      [data updateRow:$data(@"Loading...") atIndexPath:indexPath];
    }];
    [self loadMoreInTheBackground];
  }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
  return ((DemoData *)[self.tableData objectForSectionAtIndex:section]).value;
}
- (void)loadMoreInTheBackground;
{
  __block MwfDemoTableViewController * weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [NSThread sleepForTimeInterval:1]; // simulate loading for 1 second
    if (!_withSection) {
      [weakSelf performUpdates:^(MwfTableData * data) {
        NSUInteger lastRowIndex = [data numberOfRows]-1;
        for (int i = 0; i < 5; i++) {
          NSString * rowValue = [NSString stringWithFormat:@"Row %d", lastRowIndex+1];
          [data insertRow:$data(rowValue) atIndex:lastRowIndex++];
        }
        [data updateRow:$data(@"Load More") atIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:0]];
      }];
    } else {
      [weakSelf performUpdates:^(MwfTableData * data) {
        NSUInteger nextSection = [data numberOfSections];
        [data removeRowAtIndexPath:[NSIndexPath indexPathForRow:[data numberOfRowsInSection:nextSection-1]-1 inSection:nextSection-1]];
        NSString * sectionTitle = [NSString stringWithFormat:@"Section %d", nextSection+1];
        [data addSection:$data(sectionTitle)];
        [data addRow:$data(@"Row 1") inSection:nextSection];
        [data addRow:$data(@"Row 2") inSection:nextSection];
        [data addRow:$data(@"Row 3") inSection:nextSection];
        [data addRow:$data(@"Load More") inSection:nextSection];
      }];
    }
  });
}
- (void)toggleInBackground;
{
  _withSection = !_withSection;
  self.title = (_withSection ? @"With Section(s)" : @"No Section");
  
  __block MwfDemoTableViewController * weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
    [NSThread sleepForTimeInterval:1]; // simulate loading for 1 second
    [self setLoading:NO];
    
    MwfTableData * newTableData = nil;
    
    if (!_withSection) {
      newTableData = [MwfTableData createTableData];
    } else {
      newTableData = [MwfTableData createTableDataWithSections];
      [newTableData insertSection:$data(@"Section 1") atIndex:0];
    }
    [newTableData addRow:$data(@"Row 1")];
    [newTableData addRow:$data(@"Row 2")];
    [newTableData addRow:$data(@"Row 3")];
    [newTableData addRow:$data(@"Load More")];
    
    weakSelf.tableData = newTableData;
  });
}

- (void)toggle:(id)sender;
{
  [self setLoading:YES animated:YES];
  [self toggleInBackground];
}
@end
