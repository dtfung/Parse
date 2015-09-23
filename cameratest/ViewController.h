//
//  ViewController.h
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate,
UITableViewDelegate, UITableViewDataSource>
{
    NSString *urlStr;
    UIPopoverController *pop;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UITableView *tblView;
    NSArray *tableData;
}

@property (nonatomic, retain) PFObject *images;
-(void)loadData;
- (IBAction)takePicture:(id)sender;
- (IBAction)edit:(id)sender;



@end
