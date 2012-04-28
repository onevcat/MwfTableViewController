#import "SpecHelper.h"

#define $ip(_section,_row) [NSIndexPath indexPathForRow:(_row) inSection:(_section)]

SpecBegin(MwfTableDataBulkUpdates)

__block MwfTableData * tableData = nil;
__block MwfTableDataUpdates * updates = nil;
__block NSArray * reloadRows = nil;
__block NSArray * deleteRows = nil;
__block NSArray * insertRows = nil;
__block NSIndexSet * reloadSections = nil;
__block NSIndexSet * deleteSections = nil;
__block NSIndexSet * insertSections = nil;

context(@"no section", ^{

  it(@"tests bulk updates", ^{
  
    tableData = [MwfTableData createTableData];
    updates = [tableData performUpdates:NULL];
    expect(updates).toBeNil();
    
    void(^prepare)(MwfTableData *) = ^(MwfTableData * tableData) {
      [tableData addRow:@"Arizona"];
      [tableData addRow:@"California"];
      [tableData addRow:@"Delaware"];
      [tableData addRow:@"New Jersey"];
      [tableData addRow:@"Washington"];
    };
    
    tableData = [MwfTableData createTableData];
    prepare(tableData);
    
    updates = [tableData performUpdates:^(MwfTableData * data){
      
      [data updateRow:@"Arizona" atIndexPath:$ip(0,0)];
      
      // (0) Arizona, (1) California, (2) Delaware, (3) New Jersey, (4) Washington
      [data insertRow:@"Alaska" atIndex:0];
      // (0) Alaska, (1) Arizona, (2) California, (3) Delaware, (4) New Jersey, (5) Washington
      [data insertRow:@"Georgia" atIndex:4];
      // (0) Alaska, (1) Arizona, (2) California, (3) Delaware, (4) Georgia, (5) New Jersey, (6) Washington
      [data insertRow:@"Virginia" atIndex:7];
      // (0) Alaska, (1) Arizona, (2) California, (3) Delaware, (4) Georgia, (5) New Jersey, (6) Washington, (7) Virginia

      [data updateRow:@"Arizona" atIndexPath:$ip(0,1)];
      [data updateRow:@"Delaware" atIndexPath:$ip(0,3)];
      
      [data removeRowAtIndexPath:$ip(0,3)]; // Delaware
      [data removeRowAtIndexPath:$ip(0,5)]; // Washington
      
      [data updateRow:@"New Jersey" atIndexPath:$ip(0,4)];
      [data updateRow:@"Georgia" atIndexPath:$ip(0,3)];
      
    }];
    
    // ending rows: Alaska, Arizona, California, Georgia, New Jersey, Virginia
    
    expect(tableData.numberOfRows).toEqual(6);
    expect([tableData objectForRowAtIndexPath:$ip(0,0)]).toEqual(@"Alaska");
    expect([tableData objectForRowAtIndexPath:$ip(0,1)]).toEqual(@"Arizona");
    expect([tableData objectForRowAtIndexPath:$ip(0,2)]).toEqual(@"California");
    expect([tableData objectForRowAtIndexPath:$ip(0,3)]).toEqual(@"Georgia");
    expect([tableData objectForRowAtIndexPath:$ip(0,4)]).toEqual(@"New Jersey");
    expect([tableData objectForRowAtIndexPath:$ip(0,5)]).toEqual(@"Virginia");
    
    reloadRows = updates.reloadRows;
    expect(reloadRows.count).toEqual(2);
    expect([reloadRows objectAtIndex:0]).toEqual($ip(0,0));
    expect([reloadRows objectAtIndex:1]).toEqual($ip(0,3));
    
    deleteRows = updates.deleteRows;
    expect(deleteRows.count).toEqual(2);
    expect([deleteRows objectAtIndex:0]).toEqual($ip(0,2));
    expect([deleteRows objectAtIndex:1]).toEqual($ip(0,4));
    
    insertRows = updates.insertRows;
    expect(insertRows.count).toEqual(3);
    expect([insertRows objectAtIndex:0]).toEqual($ip(0,0));
    expect([insertRows objectAtIndex:1]).toEqual($ip(0,3));
    expect([insertRows objectAtIndex:2]).toEqual($ip(0,5));
    
    tableData = [MwfTableData createTableData];
    prepare(tableData);
    
    updates = [tableData performUpdates:^(MwfTableData * data){

      [data removeRowAtIndexPath:$ip(0,4)]; // Washington
      [data removeRowAtIndexPath:$ip(0,2)]; // Delaware
      [data insertRow:@"Alaska" atIndex:0];
      [data insertRow:@"Georgia" atIndex:3];
      [data insertRow:@"Virginia" atIndex:5];
      
    }];
    
    // ending rows: Alaska, Arizona, California, Georgia, New Jersey, Virginia
    
    expect(tableData.numberOfRows).toEqual(6);
    expect([tableData objectForRowAtIndexPath:$ip(0,0)]).toEqual(@"Alaska");
    expect([tableData objectForRowAtIndexPath:$ip(0,1)]).toEqual(@"Arizona");
    expect([tableData objectForRowAtIndexPath:$ip(0,2)]).toEqual(@"California");
    expect([tableData objectForRowAtIndexPath:$ip(0,3)]).toEqual(@"Georgia");
    expect([tableData objectForRowAtIndexPath:$ip(0,4)]).toEqual(@"New Jersey");
    expect([tableData objectForRowAtIndexPath:$ip(0,5)]).toEqual(@"Virginia");
    
    deleteRows = updates.deleteRows;
    expect(deleteRows.count).toEqual(2);
    expect([deleteRows objectAtIndex:0]).toEqual($ip(0,2));
    expect([deleteRows objectAtIndex:1]).toEqual($ip(0,4));
    
    insertRows = updates.insertRows;
    expect(insertRows.count).toEqual(3);
    expect([insertRows objectAtIndex:0]).toEqual($ip(0,0));
    expect([insertRows objectAtIndex:1]).toEqual($ip(0,3));
    expect([insertRows objectAtIndex:2]).toEqual($ip(0,5));
  });
  
});

context(@"with sections", ^{
  
  it(@"test bulk updates", ^{

    // Original Rows
    // -------------------
    // United States
    // - Arizona
    // - California
    // - Washington
    // Europe
    // - Germany
    // - United Kingdom
    // South East Asia
    // - Singapore
    
    // Ending Rows
    // --------------------
    // Asia Pacific
    // - Australia
    // United States
    // - Alaska
    // - California
    // - Virginia
    // Europe
    // - France
    // - Germany
    // - United Kingdom
    // Africa
    
    void(^prepare)(MwfTableData *) = ^ (MwfTableData * data) {
      [data addSection:@"United States"];
      [data addSection:@"Europe"];
      [data addSection:@"South East Asia"];
      
      [data addRow:@"Arizona" inSection:0];
      [data addRow:@"California" inSection:0];
      [data addRow:@"Washington" inSection:0];
      
      [data addRow:@"Germany" inSection:1];
      [data addRow:@"United Kingdom" inSection:1];
      
      [data addRow:@"Singapore" inSection:2];
    };
        
    tableData = [MwfTableData createTableDataWithSections];
    prepare(tableData);
    
    updates = [tableData performUpdates:^(MwfTableData * data) {

      [data updateRow:@"Arizona" atIndexPath:$ip(0,0)]; // will be ignored
      [data updateRow:@"California" atIndexPath:$ip(0,1)]; // will be logged
      
      [data insertRow:@"Alaska" atIndexPath:$ip(0,0)];
      [data insertRow:@"Virginia" atIndexPath:$ip(0,3)];
      
      [data updateRow:@"California" atIndexPath:$ip(0,2)]; // will be ignored
      [data updateRow:@"Alaska" atIndexPath:$ip(0,0)]; // will be ignored
      
      [data removeRowAtIndexPath:$ip(0, 1)]; // Arizona
      [data removeRowAtIndexPath:$ip(0, 3)]; // Washington
      
      [data updateRow:@"California" atIndexPath:$ip(0,1)]; // will be ignored
      
      [data addSection:@"Africa"];
      
      [data updateSection:@"South East Asia" atIndex:2]; // will be ignored
      
      [data removeRowAtIndexPath:$ip(2,0)]; // Singapore
      [data removeSectionAtIndex:2];        // South East Asia
      
      [data insertSection:@"Asia Pacific" atIndex:0];
      [data addRow:@"Australia" inSection:0];
      
      [data updateSection:@"Asia Pacific" atIndex:0]; // will be ignored
      [data updateSection:@"United States" atIndex:1]; // will be logged
      
      [data insertRow:@"France" atIndexPath:$ip(2,0)];
      
    }];
    expect(tableData.numberOfSections).toEqual(4);
    expect([tableData numberOfRowsInSection:0]).toEqual(1);
    expect([tableData numberOfRowsInSection:1]).toEqual(3);
    expect([tableData numberOfRowsInSection:2]).toEqual(3);
    expect([tableData numberOfRowsInSection:3]).toEqual(0);
    
    expect([tableData objectForSectionAtIndex:0]).toEqual(@"Asia Pacific");
    expect([tableData objectForSectionAtIndex:1]).toEqual(@"United States");
    expect([tableData objectForSectionAtIndex:2]).toEqual(@"Europe");
    expect([tableData objectForSectionAtIndex:3]).toEqual(@"Africa");
    
    expect([tableData objectForRowAtIndexPath:$ip(0,0)]).toEqual(@"Australia");

    expect([tableData objectForRowAtIndexPath:$ip(1,0)]).toEqual(@"Alaska");
    expect([tableData objectForRowAtIndexPath:$ip(1,1)]).toEqual(@"California");
    expect([tableData objectForRowAtIndexPath:$ip(1,2)]).toEqual(@"Virginia");
    
    expect([tableData objectForRowAtIndexPath:$ip(2,0)]).toEqual(@"France");
    expect([tableData objectForRowAtIndexPath:$ip(2,1)]).toEqual(@"Germany");
    expect([tableData objectForRowAtIndexPath:$ip(2,2)]).toEqual(@"United Kingdom");
    
    reloadRows = updates.reloadRows;
    deleteRows = updates.deleteRows;
    insertRows = updates.insertRows;
    reloadSections = updates.reloadSections;
    deleteSections = updates.deleteSections;
    insertSections = updates.insertSections;
    
    // reload rows
    expect(reloadRows.count).toEqual(1);
    expect([reloadRows objectAtIndex:0]).toEqual($ip(0,1));
    
    // delete rows
    expect(deleteRows.count).toEqual(3);
    expect([deleteRows objectAtIndex:0]).toEqual($ip(0,0));
    expect([deleteRows objectAtIndex:1]).toEqual($ip(0,2));
    expect([deleteRows objectAtIndex:2]).toEqual($ip(2,0));
    
    // reload sections
    expect(reloadSections.count).toEqual(1);
    expect([reloadSections containsIndex:0]).toEqual(YES);
    
    // delete sections
    expect([deleteSections containsIndex:0]).toEqual(NO);
    expect([deleteSections containsIndex:1]).toEqual(NO);
    expect([deleteSections containsIndex:2]).toEqual(YES);
    
    // insert sections
    expect([insertSections containsIndex:0]).toEqual(YES);
    expect([insertSections containsIndex:1]).toEqual(NO);
    expect([insertSections containsIndex:2]).toEqual(NO);
    expect([insertSections containsIndex:3]).toEqual(YES);
    
    // insert rows
    expect(insertRows.count).toEqual(4);
    expect([insertRows objectAtIndex:0]).toEqual($ip(0,0));
    expect([insertRows objectAtIndex:1]).toEqual($ip(1,0));
    expect([insertRows objectAtIndex:2]).toEqual($ip(1,2));
    expect([insertRows objectAtIndex:3]).toEqual($ip(2,0));
    
  });
  
});

SpecEnd