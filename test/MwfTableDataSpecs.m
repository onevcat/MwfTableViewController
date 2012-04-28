#import "SpecHelper.h"

#define $ip(_section,_row) \
  [NSIndexPath indexPathForRow:(_row) inSection:(_section)]

SpecBegin(MwfTableData)

__block MwfTableData * data = nil;
__block NSIndexPath  * ip   = nil;
__block NSException  * e    = nil;
__block NSUInteger     sidx = -1;

describe(@"no section", ^{

  beforeEach(^{
    data = [MwfTableData createTableData];
  });
  
  it(@"tests init state", ^{
    
    expect(data).Not.toBeNil();
    expect(data.numberOfRows).toEqual(0);
    
  });
  
  it(@"tests insert and delete", ^{
  
    // INSERTS
    id obj = [[NSObject alloc] init];
    
    ip = [data addRow:[OCMArg any]];
    expect(ip).toEqual($ip(0,0));
    expect([data updateRow:[OCMArg any] atIndexPath:$ip(0,0)]).toEqual($ip(0,0));
    expect([data updateSection:[OCMArg any] atIndex:0]).toEqual(NSNotFound);
    expect([data updateRow:nil atIndexPath:$ip(0,0)]).toBeNil();
    
    ip = [data addRow:nil];
    expect(ip).toBeNil();
    
    ip = [data insertRow:nil atIndexPath:$ip(0, 0)];
    expect(ip).toBeNil();
    
    ip = [data insertRow:nil atIndexPath:$ip(0,10)];
    expect(ip).toBeNil();
    
    expect(data.numberOfRows).toEqual(1);
    
    ip = [data addRow:obj];
    expect(ip).toEqual($ip(0,1));
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,1));
    
    ip = [data insertRow:[OCMArg any] atIndex:1];
    expect(ip).toEqual($ip(0,1));
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,2));
    
    ip = [data insertRow:[OCMArg any] atIndex:2];
    expect(ip).toEqual($ip(0,2));
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,3));
    
    // array index out of bound
    e = nil;
    @try {
      ip = [data insertRow:[OCMArg any] atIndex:5];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    e = nil;
    @try {
      __attribute__((__unused__)) NSUInteger sidx = [data addSection:[OCMArg any]];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();

    e = nil;
    @try {
      ip = [data insertRow:[OCMArg any] atIndexPath:$ip(1,0)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    ip = [data insertRow:[OCMArg any] atIndex:4];
    expect(ip).toEqual($ip(0,4));
    
    expect(data.numberOfRows).toEqual(5);
    
    // DELETES
    ip = [data removeRowAtIndexPath:$ip(0,1)];
    expect(ip).toEqual($ip(0,1));

    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,2));
    
    e = nil;
    @try {
      ip = [data removeRowAtIndexPath:$ip(0,4)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    e = nil;
    @try {
      ip = [data removeRowAtIndexPath:$ip(1,0)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    e = nil;
    @try {
      __attribute__((__unused__)) NSUInteger sidx = [data removeSectionAtIndex:0];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
  
    // non-existent object
    id neobject = [[NSObject alloc] init];
    ip = [data indexPathForRow:neobject];
    expect(ip).toBeNil();
    
    // trying to add section
    e = nil;
    @try {
      [data insertSection:[OCMArg any] atIndex:1];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();

    e = nil;
    @try {
      [data addSection:[OCMArg any]];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    // trying to remove section
    e = nil;
    @try {
      [data removeSectionAtIndex:0];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    expect([data objectForSectionAtIndex:0]).toBeNil();
  });
  
});

describe(@"with sections", ^{

  beforeEach(^{
    data = [MwfTableData createTableDataWithSections];
  });
  
  it(@"tests init state", ^{
  
    expect(data).Not.toBeNil();
    expect(data.numberOfSections).toEqual(0);
    
  });
  
  it(@"tests insert and delete", ^{
    
    NSObject * section = [[NSObject alloc] init];
    NSObject * obj = [[NSObject alloc] init];
  
    // insert section
    sidx = [data insertSection:section atIndex:0];
    expect(sidx).toEqual(0);
    
    sidx = [data indexForSection:section];
    expect(sidx).toEqual(0);
    expect([data objectForSectionAtIndex:0]).toEqual(section);

    // insert first object
    ip = [data insertRow:obj atIndexPath:$ip(0,0)];
    expect(ip).toEqual($ip(0,0));
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,0));
    
    expect([data updateSection:section atIndex:0]).toEqual(0);
    expect([data updateSection:nil atIndex:0]).toEqual(NSNotFound);
    expect([data updateRow:obj atIndexPath:$ip(0,0)]).toEqual($ip(0,0));
    expect([data updateRow:nil atIndexPath:$ip(0,0)]).toBeNil();
    
    // insert nil
    sidx = [data insertSection:nil atIndex:0];
    expect(sidx).toEqual(NSNotFound);
    
    sidx = [data insertSection:nil atIndex:10];
    expect(sidx).toEqual(NSNotFound);
    
    ip = [data insertRow:nil atIndexPath:$ip(0,0)];
    expect(ip).toEqual(nil);
    
    ip = [data insertRow:nil atIndexPath:$ip(5,0)];
    expect(ip).toEqual(nil);
    
    // insert second object
    ip = [data insertRow:[OCMArg any] atIndexPath:$ip(0,0)];
    expect(ip).toEqual($ip(0,0));

    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,1));
    
    // insert third object
    ip = [data insertRow:[OCMArg any] atIndexPath:$ip(0,1)];
    expect(ip).toEqual($ip(0,1));

    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,2));
    
    // insert fourth object
    ip = [data insertRow:[OCMArg any] atIndex:3];
    expect(ip).toEqual($ip(0,3));
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(0,2));
    
    // array index out of bound
    e = nil;
    @try {
      ip = [data insertRow:[OCMArg any] atIndex:5];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    e = nil;
    @try {
      ip = [data insertRow:[OCMArg any] atIndexPath:$ip(0,5)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    // insert new section at index 0
    sidx = [data insertSection:[OCMArg any] atIndex:0];
    expect(sidx).toEqual(0);
    
    sidx = [data indexForSection:section];
    expect(sidx).toEqual(1);
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(1,2));
    
    // insert new section at index 2
    sidx = [data insertSection:[OCMArg any] atIndex:2];
    expect(sidx).toEqual(2);
    
    sidx = [data indexForSection:section];
    expect(sidx).toEqual(1);
    
    // insert some rows
    ip = [data insertRow:[OCMArg any] atIndexPath:$ip(1,0)];
    expect(ip).toEqual($ip(1,0));
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(1,3));
    
    ip = [data insertRow:[OCMArg any] atIndexPath:$ip(2,0)];
    expect(ip).toEqual($ip(2,0));
    
    expect(data.numberOfRows).toEqual(0);
    expect([data numberOfRowsInSection:0]).toEqual(0);
    expect([data numberOfRowsInSection:1]).toEqual(5);
    expect([data numberOfRowsInSection:2]).toEqual(1);
    
    // array index out of bound (for section)
    e = nil;
    @try {
      ip = [data insertRow:[OCMArg any] atIndexPath:$ip(0,1)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();

    e = nil;
    @try {
      ip = [data insertRow:[OCMArg any] atIndexPath:$ip(1,6)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();

    e = nil;
    @try {
      ip = [data insertRow:[OCMArg any] atIndexPath:$ip(3,0)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    // delete rows
    ip = [data removeRowAtIndexPath:$ip(1,0)];
    expect(ip).toEqual($ip(1,0));
    
    ip = [data indexPathForRow:obj];
    expect(ip).toEqual($ip(1,2));
    
    e = nil;
    @try {
      ip = [data removeRowAtIndexPath:$ip(1,5)];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    // delete sections
    sidx = [data removeSectionAtIndex:0];
    expect(sidx).toEqual(0);
    
    sidx = [data indexForSection:section];
    expect(sidx).toEqual(0);
    
    sidx = [data removeSectionAtIndex:1];
    expect(sidx).toEqual(1);
    
    expect(data.numberOfSections).toEqual(1);
    
    e = nil;
    @try {
      sidx = [data removeSectionAtIndex:1];
    }
    @catch (NSException * excp) {
      e = excp;
    }
    expect(e).Not.toBeNil();
    
    ip = [data indexPathForRow:[[NSObject alloc] init]];
    expect(ip).toBeNil();
    
    sidx = [data indexForSection:[[NSObject alloc] init]];
    expect(sidx).toEqual(NSNotFound);
    
  });
});

SpecEnd