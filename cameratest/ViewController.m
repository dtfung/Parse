//
//  ViewController.m
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    NSMutableArray *downloads = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"Test"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error)
         {
             // The find succeeded.
             NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
             // Do something with the found objects
             
             for (PFObject *object in objects)
             {
                 NSLog(@"%@", object.objectId);
                 [downloads addObject:object.objectId];
             }
         }
         else
         {
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
         tableData = downloads;
         [tblView reloadData];
     }];
}


- (IBAction)edit:(id)sender{
    if([tblView isEditing]){
        [sender setTitle:@"Edit"];
    }
    else{
        [sender setTitle:@"Done"];
    }
    [tblView setEditing:![tblView isEditing]];
}

- (IBAction)takePicture:(id)sender{
    
    if([pop isPopoverVisible]){
        [pop dismissPopoverAnimated:YES];
        pop = nil;
        return;
    }
    
    UIImagePickerController *ip = [[UIImagePickerController alloc] init];
    
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
        
        [ip setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [ip setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }
    
    [ip setAllowsEditing:TRUE];
    
    [ip setDelegate:self];
    
    pop = [[UIPopoverController alloc]initWithContentViewController:ip];
    
    [pop setDelegate:self];
    
    [pop presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [pop dismissPopoverAnimated:YES];
    pop = nil;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [imageView setImage:image];
    
    NSData *imageData = UIImageJPEGRepresentation (image, 1.0);
    NSString *fileName = [[NSString alloc] initWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970 ] ];
    
    PFFile *file = [PFFile fileWithName:fileName data:imageData];
    [file saveInBackground];
    self.images = [PFObject objectWithClassName:@"Test"];
    self.images[@"UploadedFiles"] = file;
    [self.images saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             // The object has been saved.
             NSLog(@"file uploaded");
             [self loadData];
         }
         else
         {
             // There was a problem, check error.description
             NSLog(@"upload failed");
         }
     }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Table Data Count: %lu", (unsigned long)[tableData count]);
    return [tableData count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell){
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@",
                          [tableData objectAtIndex: indexPath.row ]];
    
    [[cell textLabel] setText: fileName];
    return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [tableData objectAtIndex: indexPath.row ]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Test"];
    [query whereKey:@"objectId" equalTo:fileName];
    [query getObjectInBackgroundWithId:fileName block:^(PFObject *objects, NSError *error)
    {
        if (!error)
        {
            PFFile *file = [objects objectForKey:@"UploadedFiles"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
            {
                if (!error)
                {
                    // data available here, put any operations dependent on the data existing here
                    imageView.image = [UIImage imageWithData:data];
                }
                else
                {
                    // notify user that there was an error getting file, or handle error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
}


- (void) tableView: (UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [tableData objectAtIndex: indexPath.row ]];
    PFQuery *query = [PFQuery queryWithClassName:@"Test"];
    [query whereKey:@"objectId" equalTo:fileName];
    [query getObjectInBackgroundWithId:fileName block:^(PFObject *objects, NSError *error){
        if (!error)
        {
            [objects deleteInBackground];
            [objects saveInBackground];
            [self loadData];
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


@end
