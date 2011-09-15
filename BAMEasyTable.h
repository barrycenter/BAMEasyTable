//
//  BAMEasyTable.h
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


#import <UIKit/UIKit.h>

typedef enum {
    BAMEasyTableSectionHeaderTypeShow = 0,
    BAMEasyTableSectionHeaderTypeThreshold,
    BAMEasyTableSectionHeaderTypeNeverShow
} BAMEasyTableSectionHeaderType;

typedef enum {
    BAMEasyTableSectionFooterTypeShow = 0,
    BAMEasyTableSectionFooterTypeThreshold,
    BAMEasyTableSectionFooterTypeNeverShow
} BAMEasyTableSectionFooterType;

typedef enum {
    BAMEasyTableIndexTypeShow = 0,
    BAMEasyTableIndexTypeThreshold,
    BAMEasyTableIndexTypeNeverShow
} BAMEasyTableIndexType;


typedef enum {
    BAMEasyTableSearchTypeBeginningOnly = 0,
    BAMEasyTableSearchTypeWordBeginning,
    BAMEasyTableSearchTypeEndingOnly,
    BAMEasyTableSearchTypeWordEnding,
    BAMEasyTableSearchTypeSubstring
} BAMEasyTableSearchType;

typedef enum {
    BAMEasyTableEditButtonTypeNone = 0,
    BAMEasyTableEditButtonTypeLeft,
    BAMEasyTableEditButtonTypeRight
} BAMEasyTableEditButtonType;

@protocol BAMEasyTableDelegate;

@interface BAMEasyTable : UITableViewController <UISearchDisplayDelegate> {
    id<BAMEasyTableDelegate> delegate;
    BOOL allowSearching, allowRemoving, allowMoving;
    BOOL showCountInFooter, showAddButtonWhileEditing;
    NSUInteger indexThreshold, sectionHeaderThreshold, sectionFooterThreshold;
    NSString *textStringMethodName, *detailStringMethodName, *imageMethodName, *searchStringMethodName;
    NSString *countLabelTextSingular, *countLabelTextPlural;
    NSArray *headerTitles, *indexTitles;
    NSMutableArray *source, *searchResult;
    UIColor *searchHeaderColor, *topBoundsViewColor;
    UILabel *countLabel;
    UISearchDisplayController *searchDisplayController;
    
    BAMEasyTableSectionHeaderType sectionHeaderType;
    BAMEasyTableSectionFooterType sectionFooterType;
    BAMEasyTableSearchType searchType;
    BAMEasyTableEditButtonType editButtonType;
    BAMEasyTableIndexType indexType;
    
    UITableViewCellStyle cellStyle;
}
@property (assign) id<BAMEasyTableDelegate> delegate;
@property (assign) BOOL allowSearching, allowRemoving, allowMoving;
@property (assign) BOOL showCountInFooter, showAddButtonWhileEditing;
@property (assign) NSUInteger indexThreshold, sectionHeaderThreshold, sectionFooterThreshold;
@property (nonatomic, retain) NSString *countLabelTextSingular, *countLabelTextPlural;
@property (nonatomic, retain) NSString *textStringMethodName, *detailStringMethodName, *imageMethodName, *searchStringMethodName;
@property (nonatomic, retain) NSArray *headerTitles, *indexTitles, *footerTitles;
@property (nonatomic, retain) UIColor *searchHeaderColor, *topBoundsViewColor;
@property (nonatomic, retain) UILabel *countLabel;
@property (assign) BAMEasyTableSectionHeaderType sectionHeaderType;
@property (assign) BAMEasyTableSectionFooterType sectionFooterType;
@property (assign) BAMEasyTableSearchType searchType;
@property (assign) BAMEasyTableEditButtonType editButtonType;
@property (assign) BAMEasyTableIndexType indexType;
@property (assign) UITableViewCellStyle cellStyle;

// Loading the table
- (void)loadTableFromArray:(NSArray *)sourceArray;
- (void)loadTableFromArrayOfArrays:(NSArray *)sourceArrayOfArrays;

// Managing rows
- (void)removeRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertRowObject:(id)objectToAdd atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

// Managing sections
- (void)removeSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertSection:(NSUInteger)section withHeaderTitle:(NSString *)headerTitle indexTitle:(NSString *)indexTitle footerTitle:(NSString *)footerTitle rowAnimation:(UITableViewRowAnimation)animation;

// Convenience methods
- (NSUInteger)count;
- (NSIndexPath *)indexPathForObject:(id)objectToFind;

@end

@protocol BAMEasyTableDelegate <NSObject>
@optional
- (CGFloat)bamEasyTable:(BAMEasyTable *)easyTable heightForCellWithObject:(id)selectedObject;
- (void)bamEasyTable:(BAMEasyTable *)easyTable accessoryButtonTappedForRowWithObject:(id)selectedObject;
- (NSString *)bamEasyTable:(BAMEasyTable *)easyTable titleForDeleteConfirmationButtonForRowWithObject:(id)selectedObject;
- (void)bamEasyTable:(BAMEasyTable *)easyTable didSelectObject:(id)selectedObject;
- (void)bamEasyTable:(BAMEasyTable *)easyTable didDeselectObject:(id)deselectedObject;
- (void)bamEasyTable:(BAMEasyTable *)easyTable didRemoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)bamEasyTable:(BAMEasyTable *)easyTable didRemoveSection:(NSUInteger)section;
- (void)bamEasyTableAddButtonPressed:(BAMEasyTable *)easyTable;
- (void)bamEasyTable:(BAMEasyTable *)easyTable cellForCustomization:(UITableViewCell *)cell withObject:(id)currentObject;
- (UITableViewCell *)bamEasyTable:(BAMEasyTable *)easyTable cellForObject:(id)currentObject;

- (CGFloat)bamEasyTable:(BAMEasyTable *)easyTable heightForHeaderInSection:(NSInteger)section;
- (UIView *)bamEasyTable:(BAMEasyTable *)easyTable viewForHeaderInSection:(NSInteger)section withTitle:(NSString *)title;
- (CGFloat)bamEasyTable:(BAMEasyTable *)easyTable heightForFooterInSection:(NSInteger)section;
- (UIView *)bamEasyTable:(BAMEasyTable *)easyTable viewForFooterInSection:(NSInteger)section withTitle:(NSString *)title;
- (BOOL)bamEasyTable:(BAMEasyTable *)easyTable canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)bamEasyTable:(BAMEasyTable *)easyTable canRemoveSection:(NSUInteger)section;
- (BOOL)bamEasyTable:(BAMEasyTable *)easyTable canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)bamEasyTable:(BAMEasyTable *)easyTable movedRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;


@end
