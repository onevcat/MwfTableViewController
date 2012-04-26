//
//  MwfTableViewController.h
//  MwfTableViewController
//
//  Created by Meiwin Fu on 23/4/12.
//  Copyright (c) 2012 –MwF. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - MwfTableData
#define mwf_ip NSIndexPath*
@interface MwfTableData : NSObject {
  NSMutableArray * _sectionArray;
  NSMutableArray * _dataArray;
}
// Creating instance
+ (MwfTableData *) createTableData;
+ (MwfTableData *) createTableDataWithSections;

// Accessing data
- (NSUInteger) numberOfSections;
- (NSUInteger) numberOfRowsInSection:(NSUInteger)section;
- (NSUInteger) numberOfRows;
- (id) objectForRowAtIndexPath:(mwf_ip)ip;
- (mwf_ip) indexPathForRow:(id)object;
- (NSUInteger) indexForSection:(id)sectionObject;

// Inserting data
- (NSUInteger)addSection:(id)sectionObject;
- (NSUInteger)insertSection:(id)sectionObject atIndex:(NSUInteger)sectionIndex;
- (mwf_ip)addRow:(id)object atSection:(NSUInteger)sectionIndex;
- (mwf_ip)insertRow:(id)object atIndexPath:(mwf_ip)indexPath;
- (mwf_ip)addRow:(id)object;
- (mwf_ip)insertRow:(id)object atIndex:(NSUInteger)index;

// Deleting data
- (mwf_ip)removeRowAtIndexPath:(mwf_ip)indexPath;
- (NSUInteger)removeSectionAtIndex:(NSUInteger)sectionIndex;

// Bulk Updates
- (void)performUpdates:(void(^)(MwfTableData *))updates;
@end

#pragma mark - MwfTableViewController
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

@interface MwfTableViewController (InsertDeleteOperations)
/**
 * http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9
 *
 * To insert and delete a group of rows and sections in a table view, first prepare the array (or arrays) that are the source of data for 
 * the sections and rows. After rows and sections are deleted and inserted, the resulting rows and sections are populated from this data 
 * store.
 * 
 * Next, call the beginUpdates method, followed by invocations of insertRowsAtIndexPaths:withRowAnimation:, deleteRowsAtIndexPaths:
 * withRowAnimation:, insertSections:withRowAnimation:, or deleteSections:withRowAnimation:. Conclude the animation block by calling 
 * endUpdates. Listing 7-8 illustrates this procedure.
 *
 */
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
