//
//  ARDetailViewController.m
//  ClassRoster
//
//  Created by Anton Rivera on 4/8/14.
//  Copyright (c) 2014 Anton Hilario Rivera. All rights reserved.
//

#import "ARDetailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ARDetailViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIActionSheet *myActionSheet;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UITextField *gitHubTextField;
@property (nonatomic, weak) IBOutlet UIButton *myPhotoButton;

@end

@implementation ARDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.twitterTextField.delegate = self;
    self.gitHubTextField.delegate = self;

    if (_selectedPerson.firstName) {
        _firstNameTextField.text = [NSString stringWithFormat:@"%@", _selectedPerson.firstName];
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", _selectedPerson.firstName, _selectedPerson.lastName];
    }
    if (_selectedPerson.lastName) {
        _lastNameTextField.text = [NSString stringWithFormat:@"%@", _selectedPerson.lastName];
    }
    if (_selectedPerson.twitterAccount) {
        _twitterTextField.text = [NSString stringWithFormat:@"%@", _selectedPerson.twitterAccount];
    }
    if (_selectedPerson.gitHubAccount) {
        _gitHubTextField.text = [NSString stringWithFormat:@"%@", _selectedPerson.gitHubAccount];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    if (_selectedPerson.photoFilePath) {
        NSData *data = [NSData dataWithContentsOfFile:_selectedPerson.photoFilePath];
        UIImage *image = [UIImage imageWithData:data];
        [_myPhotoButton setBackgroundImage:image forState:UIControlStateNormal];
    } else {
        [_myPhotoButton setBackgroundImage:[UIImage imageNamed:@"default"] forState:UIControlStateNormal];
    }
    
    _myPhotoButton.layer.cornerRadius = 116.5;
    [_myPhotoButton.layer setMasksToBounds:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _selectedPerson.firstName = _firstNameTextField.text;
    _selectedPerson.lastName = _lastNameTextField.text;
    _selectedPerson.twitterAccount = _twitterTextField.text;
    _selectedPerson.gitHubAccount = _gitHubTextField.text;
    
    [self.dataController saveEditedText];
}

- (IBAction)findpicture:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.myActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:@"Delete Photo"
                                                otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
    } else {
        self.myActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:@"Delete Photo"
                                                otherButtonTitles:@"Choose Photo", nil];
    }
    
    [self.myActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Choose Photo"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        return;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new]; // ALAssetsLibrary - Window in to users photo library.
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
            [assetsLibrary writeImageToSavedPhotosAlbum:editedImage.CGImage // Creates a CGImage from UIImage
                                            orientation:ALAssetOrientationUp
                                        completionBlock:^(NSURL *assetURL, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error Saving Image: %@", error.localizedDescription);
                                            }
                                        }];
        } else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Save Photo"
                                                                message:@"Authorization status not granted"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            NSLog(@"Authorization Not Determined");
        }
    }];
    
    _myPhotoButton.layer.cornerRadius = 116.5;
    [_myPhotoButton.layer setMasksToBounds:YES];
    [_myPhotoButton setBackgroundImage:editedImage forState:UIControlStateNormal];
    
    NSString *photoFilePath = [[TableDataSourceController applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg", _selectedPerson.firstName]];
    
    NSData *data = UIImagePNGRepresentation(editedImage);
    [data writeToFile:photoFilePath atomically:YES];
    
    _selectedPerson.photoFilePath = photoFilePath;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // dismiss keyboard when user taps anywhere on the screen
    [self.view endEditing:YES];
    
//    for (UIControl *control in self.view.subviews) {
//        if ([control isKindOfClass:[UITextField class]]) {
//            [control endEditing:YES];
//        }
//    }
}

@end















