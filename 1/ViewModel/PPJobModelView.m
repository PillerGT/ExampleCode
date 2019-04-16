//
//  PPJobModelView.m
//  PayForPrint
//
//  Copyright © 2018 ePRINTit. All rights reserved.
//

#import "PPJobModelView.h"
#import "PPPendingJobs.h"
#import "PPHistoryJobs.h"

#import "NSNumber+Date.h"
#import "UIColor+PayForPrint.h"

@implementation PPJobModelView

- (instancetype)initWithJob:(PPPendingJobs *)job {
    self = [super init];
    if (!self) {
        return nil;
    }
    _job = job;
    _isExpandCell = false;
    
    _jobId = [NSString stringWithFormat:@"%@", job.jobId];
    _fileFullName = job.fileName;
    _fileName = [job.fileName stringByDeletingPathExtension];
    _fileType = [job.fileName pathExtension];
    if (self.fileType.length > 0) {
        _fileName = [self.fileName stringByAppendingString:@"."];
    }
    _fileSize = [NSString stringWithFormat:@"%@", job.fileSize];
    _uploadedTimestamp = [job.uploadedTimestamp convertToDate];
    NSString *format = NSLocalizedString(@"pages_format", nil);
    
    _numPages = [NSString localizedStringWithFormat:format, job.numPages.intValue];
    _releaseCode = [NSString stringWithFormat:@"%@", job.releaseCode];
    _expiry = [NSString stringWithFormat:@"%@", [job.expiry convertToExpireDate]];
    _costBW = [NSString stringWithFormat:@"%@", job.costBW];
    
    _rightBottomButtonImage = [UIImage imageNamed:@"ppCellTrash"];
    
    [self checkedStatus:job.status];
    [self configColorCellExpand];
    _widthPagesCopiesConstraint = 8;
    
    return self;
}

- (instancetype)initWithHistoryJob:(PPHistoryJobs *)job {
    self = [super init];
    if (!self) {
        return nil;
    }
    _historyJob = job;
    _isExpandCell = false;
    
    _jobId = [NSString stringWithFormat:@"%@", job.printedJobId];
    _fileFullName = job.fileName;
    _fileName = [job.fileName stringByDeletingPathExtension];
    _fileType = [job.fileName pathExtension];
    if (self.fileType.length > 0) {
        _fileName = [self.fileName stringByAppendingString:@"."];
    }
    _fileSize = [NSString stringWithFormat:@"%@", job.fileSize];
    _uploadedTimestamp = [job.printedTimestamp convertToDate];
    
    NSString *pages = NSLocalizedString(@"pages_format", nil);
    NSString *copies = NSLocalizedString(@"copies_format", nil);
    NSString *numPages = [NSString localizedStringWithFormat:pages, job.numPages.intValue];
    NSString *numCopies = [NSString localizedStringWithFormat:copies, job.copies.intValue];
    
    _numPages = [NSString stringWithFormat:@"%@, %@", numPages, numCopies];
    _costBW = [NSString stringWithFormat:@"%@", job.cost];
    
    _statusImage = [UIImage imageNamed:@"ppCellCheckedHistory"];
    _statusText = [job.printedTimestamp convertToDate];
    _statusTextColor = [UIColor blackColor];

    _rightBottomButtonImage = [UIImage imageNamed:@"ppCellPrint"];
    
    _widthPagesCopiesConstraint = -100;
    [self configColorCellExpand];
    
    return self;
}

- (void)shouldExpandViewCell {
    _isExpandCell = !self.isExpandCell;
    [self configColorCellExpand];
}

- (void)configColorCellExpand {
    
    if (self.isExpandCell) {
        _headerBackgroundColor = [UIColor appHeaderCellColor];
        _headerTextColor = [UIColor whiteColor];
        _moreInfoButtonImage = [UIImage imageNamed:@"ppCellMoreV"];
        _fileTypeImage = [UIImage imageNamed:[self checkImagesFile:self.fileType] ? @"ppCellPictureWhite" : @"ppCellDocumentWhite"];
    }else {
        _headerBackgroundColor = [UIColor whiteColor];
        _headerTextColor = [UIColor blackColor];
        _moreInfoButtonImage = [UIImage imageNamed:@"ppCellMoreH"];
        _fileTypeImage = [UIImage imageNamed:[self checkImagesFile:self.fileType] ? @"ppCellPicture" : @"ppCellDocument"];
    }
}

- (void)checkedStatus:(NSString *)status {
    if ([status isEqualToString:@"ready"]) {
        _statusImage = [UIImage imageNamed:@"ppCellChecked"];
        _statusText = @"Ready for printing";
        _statusTextColor = [UIColor appCellReadyColor];
    }else if ([status isEqualToString:@"processing"]){
        _statusImage = [UIImage imageNamed:@"ppCellProcessing"];
        _statusText = @"Processing...";
        _statusTextColor = [UIColor appCellProccessingColor];
    }else if ([status isEqualToString:@"error"]) {
        _statusImage = [UIImage imageNamed:@"ppCellError"];
        _statusText = @"A problem occurred.";
        _statusTextColor = [UIColor appCellProblemColor];
    }
}

- (BOOL)checkImagesFile:(NSString *)type {
    NSSet *fileTypes = [NSSet setWithObjects:@"jpg", @"jpeg", @"png", @"bmp", @"gif", @"tif", @"tiff", nil];
    return [fileTypes containsObject:type];
}

@end
