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
