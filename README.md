# MwfTableViewController

Extension to UITableViewController in attempt to provide additional features that are reusable in most scenarios.

## Features

### Show Loading

Configure the loading style, currently support header and footer.

  ```objective-c
  - (void)viewDidLoad
  {
    [super viewDidLoad];
    theTableViewController.loadingStyle = MwfTableViewLoadingStyleFooter; // default is MwfTableViewLoadingStyleHeader
  }
  ```

Programmatically trigger loading animation

  ```objective-c
  [theTableViewController setLoading:YES animated:YES];
  ```
  
Programmatically stop loading animation  
    
  ```objective-c
  [theTableViewController setLoading:YES animated:NO];
  ```
  
If you need to, you can override few methods to provide custom look and feel for your app.

  ```objective-c
  - (UIView *)createLoadingView
  {
    // ... construct your custom loading view
    return yourAwesomeCustomLoadingView;
  }
  
  - (void)willShowLoadingView:(UIView *)loadingView
  {
    // cast to your implementation
    YourAwesomeLoadingView * view = (YourAwesomeLoadingView *)loadingView;
    // ... do something about it, e.g. start animating the activity indicator view
  }
  
  - (void)didHideLoadingView:(UIView *)loadingView
  {
    // cast to your implementation
    YourAwesomeLoadingView * view = (YourAwesomeLoadingView *)loadingView;
    // ... do something about it, e.g. stop animating the activity indicator view
  }
  ```  

### Table Data

A class `MwfTableData` is provided to manage your table backing store.
Instead of using `NSArray`, this class provides all the convenience you need working with table view.

_Creating Table Data_

* `+ (MwfTableData *) createTableData;`
* `+ (MwfTableData *) createTableDataWithSections;`

_Accessing data_

* `- (NSUInteger) numberOfSections;`
* `- (NSUInteger) numberOfRowsInSection:(NSUInteger)section;`
* `- (NSUInteger) numberOfRows;`
* `- (id) objectForSectionAtIndex:(NSUInteger)section;`
* `- (id) objectForRowAtIndexPath:(mwf_ip)ip;`
* `- (mwf_ip) indexPathForRow:(id)object;`
* `- (NSUInteger) indexForSection:(id)sectionObject;`

_Inserting data_

* `- (NSUInteger)addSection:(id)sectionObject;`
* `- (NSUInteger)insertSection:(id)sectionObject atIndex:(NSUInteger)sectionIndex;`
* `- (mwf_ip)addRow:(id)object inSection:(NSUInteger)sectionIndex;`
* `- (mwf_ip)insertRow:(id)object atIndexPath:(mwf_ip)indexPath;`
* `- (mwf_ip)addRow:(id)object;`
* `- (mwf_ip)insertRow:(id)object atIndex:(NSUInteger)index;`

_Deleting data_

* `- (mwf_ip)removeRowAtIndexPath:(mwf_ip)indexPath;`
* `- (NSUInteger)removeSectionAtIndex:(NSUInteger)sectionIndex;`

_Updating data_

* `- (NSUInteger)updateSection:(id)object atIndex:(NSUInteger)section;`
* `- (mwf_ip)updateRow:(id)object atIndexPath:(mwf_ip)indexPath;`

### Using `MwfTableData` in MwfTableViewController subclasses

_Override `createAndInitTableData`_

In this method, you can create `MwfTableData` instance using one of the creation methods (with or without section) and initialize with some data.

   ```objective-c
   - (MwfTableData *)createAndInitTableData;
   {
     MwfTableData * tableData = [MwfTableData createTableData];
     [tableData addRow:$data(@"Row 1")];
     [tableData addRow:$data(@"Row 2")];
     [tableData addRow:$data(@"Row 3")];
     [tableData addRow:$data(@"Load More")];
     return tableData;
   }
   ```

_Performing bulk updates_

`MwfTableViewController` provides method `performUpdates:(void(^)(MwfTableData *))updatesBlock` which you can call to perform bulk updates to your table view (add,remove,update sections/rows). This method will update the backing store as well as updating the table view (using `UITableViewRowAnimationAutomatic` for row animation). This method frees you from tracking the changed index sets and paths, and lets you focus on the application logic that updates your table.

  ```objective-c
  - (void)loadMoreData {
     
     [self performUpdates:^(MwfTableData * data) {
     
        // ... call the insert/delete/update method of MwfTableData
        
     }];
  }
  ```
  
_Reload table view_

Setting table data via `tableData` property of `MwfTableViewController` will trigger tableView's `reloadData`.

   ```objective-c
   - (void)reloadEntireTable { // a method in your MwfTableViewController subclass
   
      MwfTableData * tableData = [MwfTableData createTableDataWithSections];
      [tableData addSection:@"Section 1"];
      [tableData addRow:@"Row 1" inSection:0];
      [tableData addRow:@"Row 2" inSection:0];
      self.tableData = tableData;
   }
   ```

## Licensing

MwfTableViewController is licensed under MIT License
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

