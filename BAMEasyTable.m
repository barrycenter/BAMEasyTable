//
//  BAMEasyTable.m
//
//  If you use this software in your project, a credit for Barry Murphy
//  and a link to http://barrycenter.com would be appreciated.
//
//  --------------------------------
//  Simplified BSD License (FreeBSD)
//  --------------------------------
//
//  Copyright 2011 Barry Murphy. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//     conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//     of conditions and the following disclaimer in the documentation and/or other materials
//     provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY BARRY MURPHY "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BARRY MURPHY OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Barry Murphy.

#import "BAMEasyTable.h"

@interface BAMEasyTable (Private)
- (void)setDefaultValues;
- (void)loadTable;
- (void)scrollToTop;
- (void)addSearchHeader;
- (void)createCountLabel;
- (void)addCountFooter;
- (void)addEditButton;
- (void)addButtonPressed:(id)sender;
@end


@implementation BAMEasyTable

@synthesize delegate;
@synthesize allowRemoving, allowMoving, allowSearching;
@synthesize showCountInFooter, showAddButtonWhileEditing;
@synthesize indexThreshold, sectionHeaderThreshold, sectionFooterThreshold;
@synthesize headerTitles, indexTitles, footerTitles;
@synthesize searchHeaderColor, topBoundsViewColor;
@synthesize countLabelTextSingular, countLabelTextPlural;
@synthesize textStringMethodName, detailStringMethodName, imageMethodName, searchStringMethodName;
@synthesize countLabel;
@synthesize sectionHeaderType;
@synthesize sectionFooterType;
@synthesize searchType;
@synthesize editButtonType;
@synthesize indexType;
@synthesize cellStyle;


- (id)init {
    if ((self = [super init])) {
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self setDefaultValues];
        
    }
    return self;
}

- (void)dealloc {
    [textStringMethodName release];
    [detailStringMethodName release];
    [imageMethodName release];
    [searchStringMethodName release];
    [countLabelTextSingular release];
    [countLabelTextPlural release];
    [headerTitles release];
    [indexTitles release];
    [footerTitles release];
    [source release];
    [searchResult release];
    [searchHeaderColor release];
    [topBoundsViewColor release];
    [countLabel release];
    [searchDisplayController release];
    
    [super dealloc];
}

- (void)setDefaultValues {
    indexThreshold = 50;
    sectionHeaderThreshold = 20;
    sectionFooterThreshold = 20;
    allowSearching = YES;
    allowRemoving = NO;
    allowMoving = NO;
    showCountInFooter = YES;
    showAddButtonWhileEditing = NO;
    countLabelTextSingular = @"Item";
    countLabelTextPlural = @"Items";
    sectionHeaderType = BAMEasyTableSectionHeaderTypeThreshold;
    sectionFooterType = BAMEasyTableSectionFooterTypeThreshold;
    indexType = BAMEasyTableIndexTypeThreshold;
    searchType = BAMEasyTableSearchTypeWordBeginning;
    editButtonType = BAMEasyTableEditButtonTypeNone;
    cellStyle =  UITableViewCellStyleDefault;
    
    [self createCountLabel];
}


#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addEditButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addEditButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark - Table Loading Methods

- (void)loadTableFromArray:(NSArray *)sourceArray {
    if (source != nil) {
        [source release];
        source = nil;
    }
    
    NSMutableArray *sectionArray = [[[NSMutableArray alloc] initWithArray:sourceArray] autorelease];
    source = [[NSMutableArray alloc] init];
    [source addObject:sectionArray];
    
    [self loadTable];
}

- (void)loadTableFromArrayOfArrays:(NSArray *)sourceArrayOfArrays {
    if (source != nil) {
        [source release];
        source = nil;
    }
    
    source = [[NSMutableArray alloc] initWithArray:sourceArrayOfArrays];
    
    [self loadTable];
}

- (void)loadTable {    
    if (allowSearching) [self addSearchHeader];
    if (showCountInFooter) [self addCountFooter];
    
    [self.tableView reloadData];
}


#pragma mark - Convenience Methods

- (NSUInteger)count {
    NSUInteger count = 0;
    for (NSArray *section in source) {
        count += [section count];
    }
    return count;
}

- (NSIndexPath *)indexPathForObject:(id)objectToFind {
    NSIndexPath *returnIndexPath = nil;
    for (int i=0; i < [source count]; i++) {
        NSMutableArray *section  = (NSMutableArray *)[source objectAtIndex:i];
        for (int j=0; j < [section count]; j++) {
            if ([section objectAtIndex:j] == objectToFind) returnIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
        }
    }
    return returnIndexPath;
}


#pragma mark - Table Manipulator Methods

- (void)scrollToTop {
    [self.tableView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f) animated:YES];
}

- (void)removeRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    for (NSIndexPath *indexPath in indexPaths) {
        NSObject *currentObject;
        NSMutableArray *currentSection = [[NSMutableArray alloc] initWithArray:[source objectAtIndex:indexPath.section]];
        currentObject = [currentSection objectAtIndex:indexPath.row];
        
        [currentSection removeObject:currentObject];
        
        [source replaceObjectAtIndex:indexPath.section withObject:currentSection];
        
        BOOL shouldDeleteSection = ([currentSection count] == 0);
        
        [currentSection release];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
        
        if (shouldDeleteSection && self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:canRemoveSection:)]) {
            shouldDeleteSection = [self.delegate bamEasyTable:self canRemoveSection:indexPath.section];
        }
        if (shouldDeleteSection) {
            [self removeSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:animation];
            
            if (shouldDeleteSection && self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:canRemoveSection:)]) {
                [delegate bamEasyTable:self didRemoveSection:indexPath.section];
            }
        }
    }
}

- (void)insertRowObject:(id)objectToAdd atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *currentSection = [[NSMutableArray alloc] initWithArray:[source objectAtIndex:indexPath.section]];
    
    if (indexPath.row < [currentSection count]) [currentSection insertObject:objectToAdd atIndex:indexPath.row];
    else [currentSection addObject:objectToAdd];
    
    [source replaceObjectAtIndex:indexPath.section withObject:currentSection];
    [currentSection release];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
    
    NSUInteger count = [self count];
    if (count == indexThreshold || count == sectionHeaderThreshold || count == sectionFooterThreshold) [self.tableView reloadData];
}

- (void)removeSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    NSInteger section = [sections firstIndex];
    while (section != NSNotFound) {
        [source removeObjectAtIndex:section];
        
        if (headerTitles != nil) {
            NSMutableArray *newTitles = [[NSMutableArray alloc] initWithArray:headerTitles];
            [newTitles removeObjectAtIndex:section];
            [headerTitles release];
            headerTitles = [[NSArray alloc] initWithArray:newTitles];
            [newTitles release];
        }

        if (footerTitles != nil) {
            NSMutableArray *newFooters = [[NSMutableArray alloc] initWithArray:footerTitles];
            [newFooters removeObjectAtIndex:section];
            [footerTitles release];
            footerTitles = [[NSArray alloc] initWithArray:newFooters];
            [newFooters release];
        }

        if (indexTitles != nil) {
            NSMutableArray *newIndexTitles = [[NSMutableArray alloc] initWithArray:indexTitles];
            [newIndexTitles removeObjectAtIndex:section];
            [indexTitles release];
            indexTitles = [[NSArray alloc] initWithArray:newIndexTitles];
            [newIndexTitles release];
        }
        
        section = [sections indexGreaterThanIndex: section];
    }
    
    [self.tableView deleteSections:sections withRowAnimation:animation];
}

- (void)insertSection:(NSUInteger)section withHeaderTitle:(NSString *)headerTitle indexTitle:(NSString *)indexTitle footerTitle:(NSString *)footerTitle rowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
    if (section < [source count]) [source insertObject:emptyArray atIndex:section];
    else [source addObject:emptyArray];
    [emptyArray release];
    
    if (headerTitles != nil) {
        if (headerTitle == nil) headerTitle = @"";
        NSMutableArray *newTitles = [[NSMutableArray alloc] initWithArray:headerTitles];
        if (section < [newTitles count]) [newTitles insertObject:headerTitle atIndex:section];
        else [newTitles addObject:headerTitle];
        [headerTitles release];
        headerTitles = [[NSArray alloc] initWithArray:newTitles];
        [newTitles release];
    }
    
    if (footerTitles != nil) {
        if (footerTitle == nil) footerTitle = @"";
        NSMutableArray *newFooters = [[NSMutableArray alloc] initWithArray:footerTitles];
        if (section < [newFooters count]) [newFooters insertObject:footerTitle atIndex:section];
        else [newFooters addObject:footerTitle];
        [footerTitles release];
        footerTitles = [[NSArray alloc] initWithArray:newFooters];
        [newFooters release];
    }
    
    BOOL updatedIndexTitles = NO;
    if (indexTitle != nil) {
        if (indexTitle == nil) indexTitle = @"";
        NSMutableArray *newIndexTitles = [[NSMutableArray alloc] initWithArray:indexTitles];
        if (section < [newIndexTitles count]) [newIndexTitles insertObject:indexTitle atIndex:section];
        else [newIndexTitles addObject:indexTitle];
        [indexTitles release];
        indexTitles = [[NSArray alloc] initWithArray:newIndexTitles];
        [newIndexTitles release];
        updatedIndexTitles = YES;
    }
    
    if (updatedIndexTitles || section == [source count]) [self.tableView reloadData];
    else [self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}


#pragma mark - View Manipulator and Builder Methods

- (void)addEditButton {
    // Sometimes the navigation controller interferes with the viewDidLoad: or the viewWillLoad: so this code attempts to add the edit button either way. It's very lightweight so it has almost zero impact to do it twice just for peace of mind.
    if (editButtonType == BAMEasyTableEditButtonTypeRight) self.navigationItem.rightBarButtonItem = self.editButtonItem;
    else if (editButtonType == BAMEasyTableEditButtonTypeLeft) self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)addSearchHeader {
    if (searchHeaderColor == nil) self.searchHeaderColor = [UIColor colorWithRed:185.0f/255.0f green:195.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    if (topBoundsViewColor == nil) self.topBoundsViewColor = [UIColor colorWithRed:220.0f/255.0f green:225.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView *topBoundsView = [[UIView alloc] initWithFrame:frame];
    topBoundsView.backgroundColor = topBoundsViewColor;
    topBoundsView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self.tableView addSubview:topBoundsView];
    [topBoundsView release];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 45.0f)];
    [searchBar sizeToFit];
    searchBar.tintColor = searchHeaderColor;
    
    if (searchBar != nil) searchBar.placeholder = @"Search";
    
    self.tableView.tableHeaderView = searchBar;
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    [self performSelector:@selector(setSearchDisplayController:) withObject:searchDisplayController];
}

- (void)createCountLabel {
    CGRect labelRect = CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 45.0f);
    
    countLabel = [[UILabel alloc] initWithFrame:labelRect];
    countLabel.textAlignment = UITextAlignmentCenter;
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.shadowColor = [UIColor whiteColor];
    countLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    countLabel.font = [UIFont systemFontOfSize:16.0f];
    countLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
    if (self.tableView.style == UITableViewStylePlain) countLabel.textColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
    else countLabel.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0];
}

- (void)addCountFooter {
    NSUInteger count = [self count];
    
    NSString *countLabelText;
    if (count == 1) countLabelText = countLabelTextSingular;
    else countLabelText = countLabelTextPlural;
    
    CGRect footerCellRect = CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 45.0f);
    
    countLabel.text = [[NSString stringWithFormat:@"%d %@", count, countLabelText] copy];
    
    UITableViewCell *footerCell = [[[UITableViewCell alloc] initWithFrame:footerCellRect] autorelease];
    
    if (self.tableView.tableFooterView != nil) self.tableView.tableFooterView = nil;
    footerCell.backgroundColor = [UIColor clearColor];
    [footerCell addSubview:countLabel];
    self.tableView.tableFooterView = footerCell;
}


#pragma mark - Button Response Methods

- (void)addButtonPressed:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTableAddButtonPressed:)]) {
        [self.delegate bamEasyTableAddButtonPressed:self];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate {
    [super setEditing:editing animated:animate];
    if (showAddButtonWhileEditing) {
        if(editing) {
            UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
            if (editButtonType == BAMEasyTableEditButtonTypeRight) self.navigationItem.leftBarButtonItem = addButtonItem;
            else if (editButtonType == BAMEasyTableEditButtonTypeLeft) self.navigationItem.rightBarButtonItem = addButtonItem;
            [addButtonItem release];
        }
        else {
            if (editButtonType == BAMEasyTableEditButtonTypeRight) self.navigationItem.leftBarButtonItem = nil;
            else if (editButtonType == BAMEasyTableEditButtonTypeLeft) self.navigationItem.rightBarButtonItem = nil;
        }
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([searchResult count] > 0) return 1;
        else return 0;
    } else {
        return [source count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResult count];
    } else {
        return [[source objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *currentObject;
    if (tableView == self.searchDisplayController.searchResultsTableView) currentObject = [searchResult objectAtIndex:indexPath.row];
    else currentObject = [[source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    UITableViewCell *delegateCell = nil; 
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:cellForObject:)]) {
        delegateCell = [self.delegate bamEasyTable:self cellForObject:currentObject];
    }
    if (delegateCell != nil) {
        return delegateCell;
    } else {
        static NSString *CellIdentifier = @"BAMEasyTableCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:cellForCustomization:withObject:)]) {
            [self.delegate bamEasyTable:self cellForCustomization:cell withObject:currentObject];
        }
        
        if ([currentObject isKindOfClass:[NSString class]]) cell.textLabel.text = (NSString *)currentObject;
        else cell.textLabel.text = [currentObject performSelector:NSSelectorFromString(textStringMethodName)];
        
        if (detailStringMethodName != nil) cell.detailTextLabel.text = [currentObject performSelector:NSSelectorFromString(detailStringMethodName)];
        
        if (imageMethodName != nil) cell.imageView.image = [currentObject performSelector:NSSelectorFromString(imageMethodName)];
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:canEditRowAtIndexPath:)]) {
        return [self.delegate bamEasyTable:self canEditRowAtIndexPath:indexPath];
    } else {
        if (allowRemoving || allowMoving) return YES;
        else return NO;
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (allowRemoving) return YES;
    else return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (allowRemoving) return UITableViewCellEditingStyleDelete;
    else return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:didRemoveItemAtIndexPath:)]) {
            [self.delegate bamEasyTable:self didRemoveItemAtIndexPath:indexPath];
        }

    }  
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (indexTitles == nil || tableView == self.searchDisplayController.searchResultsTableView || indexType == BAMEasyTableIndexTypeNeverShow || (indexType == BAMEasyTableIndexTypeThreshold && [self count] < indexThreshold)) {
        return nil;
    } else {
        if (allowSearching) {
            NSMutableArray *indexTitlesWithSearhIcon = [[[NSMutableArray alloc] initWithArray:indexTitles] autorelease];
            [indexTitlesWithSearhIcon insertObject:UITableViewIndexSearch atIndex:0];
            return indexTitlesWithSearhIcon;
        } else {
            return indexTitles;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (allowSearching) {
        if (index == 0) {
            [self performSelectorOnMainThread:@selector(scrollToTop) withObject:nil waitUntilDone:NO];
            return 0;
        } else {
            if ([source count] < index) return [source count] -1;
            else return index - 1;
        }
    } else {
        if ([source count] - 1 < index) return [source count] - 1;
        else return index;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section  {
    if (!(section < [headerTitles count]) || tableView == self.searchDisplayController.searchResultsTableView || sectionHeaderType == BAMEasyTableSectionHeaderTypeNeverShow || (sectionHeaderType == BAMEasyTableSectionHeaderTypeThreshold && [self count] < sectionHeaderThreshold)) return @"";
    else return [headerTitles objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section  {
    if (!(section < [footerTitles count]) || tableView == self.searchDisplayController.searchResultsTableView || sectionFooterType == BAMEasyTableSectionFooterTypeNeverShow || (sectionFooterType == BAMEasyTableSectionFooterTypeThreshold && [self count] < sectionFooterThreshold)) return @"";
    else return [footerTitles objectAtIndex:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:heightForHeaderInSection:)]) {
        return [self.delegate bamEasyTable:self heightForHeaderInSection:section];
    } else {
        return 30;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:viewForHeaderInSection:withTitle:)]) {
        if (headerTitles != nil) {
            return [self.delegate bamEasyTable:self viewForHeaderInSection:section withTitle:[headerTitles objectAtIndex:section]];
        } else {
            return [self.delegate bamEasyTable:self viewForHeaderInSection:section withTitle:nil];
        }
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:heightForFooterInSection:)]) {
        return [self.delegate bamEasyTable:self heightForFooterInSection:section];
    } else {
        return 30;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:viewForFooterInSection:withTitle:)]) {
        if (footerTitles != nil) {
            return [self.delegate bamEasyTable:self viewForFooterInSection:section withTitle:[footerTitles objectAtIndex:section]];
        } else {
            return [self.delegate bamEasyTable:self viewForFooterInSection:section withTitle:nil];
        }
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:titleForDeleteConfirmationButtonForRowWithObject:)]) {
        NSObject *selectedObject = [[source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return [self.delegate bamEasyTable:self titleForDeleteConfirmationButtonForRowWithObject:selectedObject];
    } else {
        return nil;
    }

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:accessoryButtonTappedForRowWithObject:)]) {
        NSObject *selectedObject = [[source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return [self.delegate bamEasyTable:self accessoryButtonTappedForRowWithObject:selectedObject];
    }
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:heightForCellWithObject:)]) {
        NSObject *selectedObject = [[source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return [self.delegate bamEasyTable:self heightForCellWithObject:selectedObject];
    } else {
        return self.tableView.rowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *selectedObject;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        selectedObject = [searchResult objectAtIndex:indexPath.row];
    } else {
        selectedObject = [[source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:didSelectObject:)]) {
        [self.delegate bamEasyTable:self didSelectObject:selectedObject];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *deselectedObject;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        deselectedObject = [searchResult objectAtIndex:indexPath.row];
    } else {
        deselectedObject = [[source objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:didDeselectObject:)]) {
        [self.delegate bamEasyTable:self didDeselectObject:deselectedObject];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:canMoveRowAtIndexPath:)]) {
        return [self.delegate bamEasyTable:self canMoveRowAtIndexPath:indexPath];
    } else {
        if (allowMoving) return YES;
        else return NO;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    BOOL shouldDeleteSection = NO;
    if (fromIndexPath.section != toIndexPath.section) {
        NSMutableArray *fromSection = [[NSMutableArray alloc] initWithArray:[source objectAtIndex:fromIndexPath.section]];
        NSMutableArray *toSection = [[NSMutableArray alloc] initWithArray:[source objectAtIndex:toIndexPath.section]];    
        
        [toSection insertObject:[[fromSection objectAtIndex:fromIndexPath.row] retain] atIndex:toIndexPath.row];
        [fromSection removeObjectAtIndex:fromIndexPath.row];
        
        [source replaceObjectAtIndex:fromIndexPath.section withObject:fromSection];
        [source replaceObjectAtIndex:toIndexPath.section withObject:toSection];
        
        if ([fromSection count] == 0) shouldDeleteSection = YES;
        
        [fromSection release];
        [toSection release];
    } else {
        NSMutableArray *section = [[NSMutableArray alloc] initWithArray:[source objectAtIndex:toIndexPath.section]]; 
        
        id movingObject = [section objectAtIndex:fromIndexPath.row];
        [section removeObjectAtIndex:fromIndexPath.row];
        [section insertObject:movingObject atIndex:toIndexPath.row];
        
        [source replaceObjectAtIndex:toIndexPath.section withObject:section];
        [section release];
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:movedRowFromIndexPath:toIndexPath:)]) {
        [self.delegate bamEasyTable:self movedRowFromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
    
    if (shouldDeleteSection && self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:canRemoveSection:)]) {
        shouldDeleteSection = [self.delegate bamEasyTable:self canRemoveSection:fromIndexPath.section];
    }
    if (shouldDeleteSection) {
        [self removeSections:[NSIndexSet indexSetWithIndex:fromIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        
        if (shouldDeleteSection && self.delegate != nil && [self.delegate respondsToSelector:@selector(bamEasyTable:canRemoveSection:)]) {
            [delegate bamEasyTable:self didRemoveSection:fromIndexPath.section];
        }
        
        [self.tableView reloadData];
    }
}


#pragma mark - UISearchDisplayDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    searchString = [[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSInteger searchStringLength = [searchString length];
    NSString *searchStringNewWordBeginning = [NSString stringWithFormat:@" %@", searchString];
    NSString *searchStringNewWordEnding = [NSString stringWithFormat:@"%@ ", searchString];
    
    if (searchResult == nil) searchResult = [[NSMutableArray alloc] init];
    else [searchResult removeAllObjects];
    
    BOOL searchMatchesBeginning, searchMatchesNewWordBeginning, searchMatchesSubstring = NO;
    
    for (NSMutableArray *currentSection in source) {
        for (NSObject *currentObject in currentSection) {
            NSString *stringToMatch;
            if ([currentObject isKindOfClass:[NSString class]]) stringToMatch = (NSString *)currentObject;
            else if (searchStringMethodName != nil) stringToMatch = [currentObject performSelector:NSSelectorFromString(searchStringMethodName)];
            else if (textStringMethodName != nil) stringToMatch = [currentObject performSelector:NSSelectorFromString(textStringMethodName)]; 
            
            stringToMatch = [stringToMatch lowercaseString];
            
            if ([searchString length] <= [stringToMatch length]) {
                if (searchType == BAMEasyTableSearchTypeBeginningOnly || searchType == BAMEasyTableSearchTypeWordBeginning) {
                    searchMatchesBeginning = [[stringToMatch substringToIndex:searchStringLength] isEqualToString:searchString];
                }
                if (searchType == BAMEasyTableSearchTypeWordBeginning) {
                    searchMatchesNewWordBeginning = ([stringToMatch rangeOfString:searchStringNewWordBeginning].location != NSNotFound);
                }
                if (searchType == BAMEasyTableSearchTypeEndingOnly || searchType == BAMEasyTableSearchTypeWordEnding) {
                    searchMatchesBeginning = NO;
                    NSInteger fromIndex = [stringToMatch length] - searchStringLength;
                    if (fromIndex > 0) {
                        searchMatchesBeginning = [[stringToMatch substringFromIndex:fromIndex] isEqualToString:searchString];
                    }
                }
                if (searchType == BAMEasyTableSearchTypeWordEnding) {
                    searchMatchesNewWordBeginning = ([stringToMatch rangeOfString:searchStringNewWordEnding].location != NSNotFound);
                }
                if (searchType == BAMEasyTableSearchTypeSubstring) {
                    searchMatchesSubstring = ([stringToMatch rangeOfString:searchString].location != NSNotFound);
                }
                if (searchMatchesBeginning || searchMatchesNewWordBeginning || searchMatchesSubstring) {
                    [searchResult addObject:currentObject];
                }
            }
        }
    }
    return YES;
}

@end
