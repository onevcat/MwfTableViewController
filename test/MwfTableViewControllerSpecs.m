#import "SpecHelper.h"

SpecBegin(MwfTableViewController)

__block MwfTableViewController * controller = nil;
__block id                       mockController = nil;

context(@"loading features", ^{

  beforeEach(^{
    controller = [[MwfTableViewController alloc] initWithNibName:nil bundle:nil];
    mockController = [OCMockObject partialMockForObject:controller];
  });

  it(@"creates internal views", ^{

    expect(controller.view).Not.toBeNil();
    expect(controller.loadingStyle).toEqual(MwfTableViewLoadingStyleHeader);
    expect(controller.loading).toEqual(NO);
    expect(controller.loadingView).Not.toBeNil();
    expect(controller.tableHeaderTopView).Not.toBeNil();
    
  });
  
  it(@"calling method for custom view overrides", ^{
    
    [[mockController expect] createLoadingView];
    [[mockController expect] createTableHeaderTopView];
    __attribute__((__unused__)) UIView * view = controller.view;
    [mockController verify];
    
  });
  
  it(@"loading header", ^{
  
    controller.loadingStyle = MwfTableViewLoadingStyleHeader;
    
    [[mockController expect] willShowLoadingView:[OCMArg any]];
    [controller setLoading:YES];
    expect(controller.loading).toEqual(YES);
    [[mockController expect] didHideLoadingView:[OCMArg any]];
    [controller setLoading:NO];
    expect(controller.loading).toEqual(NO);
    [mockController verify];
    
  });
  
  it(@"loading footer", ^{
    
    controller.loadingStyle = MwfTableViewLoadingStyleFooter;

    [[mockController expect] willShowLoadingView:[OCMArg any]];
    [controller setLoading:YES];
    expect(controller.loading).toEqual(YES);
    [[mockController expect] didHideLoadingView:[OCMArg any]];
    [controller setLoading:NO];
    expect(controller.loading).toEqual(NO);
    [mockController verify];
    
  });
  
});

SpecEnd