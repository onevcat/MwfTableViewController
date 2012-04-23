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

