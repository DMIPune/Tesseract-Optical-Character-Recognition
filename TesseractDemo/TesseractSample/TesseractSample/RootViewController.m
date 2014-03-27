//
//  ViewController.m
//  TesseractSample
//
//  Created by Loïs Di Qual on 08/10/12.
//  Copyright (c) 2012 Loïs Di Qual. All rights reserved.
//

#import "RootViewController.h"
#import "Tesseract.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}
-(IBAction)takePhoto:(id)sender
{
    if([self checkDeviceCapability:UIImagePickerControllerSourceTypeCamera])
    {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
    }
   
}
- (IBAction)selectPhoto:(id)sender
{
    if([self checkDeviceCapability:UIImagePickerControllerSourceTypePhotoLibrary])
    {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
   [self presentViewController:picker animated:YES completion:NULL];
    }
    
}
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait| UIInterfaceOrientationMaskPortraitUpsideDown;
}

// Old Method
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        return YES;
    }
    else
    {
        return NO;
    }
}   


#pragma mark-UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
   
   [self recognizedText:image];
   [picker dismissViewControllerAnimated:YES completion:NULL];

}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
     [self recognizedText:[self fixOrientation:chosenImage]];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}




-(UIImage *) gs_convert_image :(UIImage *) src_img
{
    CGColorSpaceRef d_colorSpace = CGColorSpaceCreateDeviceRGB();
    /*
     * Note we specify 4 bytes per pixel here even though we ignore the
     * alpha value; you can't specify 3 bytes per-pixel.
     */
    size_t d_bytesPerRow = src_img.size.width * 4;
    unsigned char * imgData = (unsigned char*)malloc(src_img.size.height*d_bytesPerRow);
    CGContextRef context =  CGBitmapContextCreate(imgData, src_img.size.width,
                                                  src_img.size.height,
                                                  8, d_bytesPerRow,
                                                  d_colorSpace,
                                                  kCGImageAlphaNoneSkipFirst);
    
    UIGraphicsPushContext(context);
    // These next two lines 'flip' the drawing so it doesn't appear upside-down.
    CGContextTranslateCTM(context, 0.0, src_img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    // Use UIImage's drawInRect: instead of the CGContextDrawImage function, otherwise you'll have issues when the source image is in portrait orientation.
    [src_img drawInRect:CGRectMake(0.0, 0.0, src_img.size.width, src_img.size.height)];
    UIGraphicsPopContext();
    
    /*
     * At this point, we have the raw ARGB pixel data in the imgData buffer, so
     * we can perform whatever image processing here.
     */
    
    
    // After we've processed the raw data, turn it back into a UIImage instance.
    CGImageRef new_img = CGBitmapContextCreateImage(context);
    UIImage * convertedImage = [[UIImage alloc] initWithCGImage:
                                new_img];
    
    CGImageRelease(new_img);
    CGContextRelease(context);
    CGColorSpaceRelease(d_colorSpace);
    free(imgData);
    return convertedImage;
}

/*!
 * Provides way to send input image to tesseract library for separating charactet text of image...
 * \param UIImage for decoding
 * \returns Text of input image.
 */

-(void)recognizedText:(UIImage *)image
{
      Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    
    //setting parameter to tesseract object to recognise text
    
//    [tesseract setVariableValue:@"0" forKey:@"language_model_penalty_non_freq_dict_word"];
//    [tesseract setVariableValue:@"1" forKey:@"tessedit_small_match"];
//    [tesseract setVariableValue:@"1" forKey:@"tessedit_print_text"];
//    [tesseract setVariableValue:@"1" forKey:@"tessedit_draw_words"];
//    [tesseract setVariableValue:@"1" forKey:@"tessedit_draw_words"];
//    [tesseract setVariableValue:@"1" forKey:@"tessedit_dump_choices"];
   
    
    [tesseract setVariableValue:@"1" forKey:@"crunch_terrible_garbage"];
    [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-=*/!""'.:@" forKey:@"tessedit_char_whitelist"];
    [tesseract setImage:image];
    [tesseract recognize];
     NSString *recognizedTextData=[tesseract recognizedText];
   //    NSLog(@"%@", [tesseract recognizedText]);
    UIAlertView *textAlertView = [[UIAlertView alloc] initWithTitle:@"Text"
                                                          message:recognizedTextData
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    
    [textAlertView show];
    
    
}

/*!
 * Function use to check Camera or PhotoLibrary capability of device...
 * \param Camera/PhotoLibrary
 * \returns True if device has camera/photolibrary,ow false.
 */
-(BOOL)checkDeviceCapability:(NSInteger)sourceType
{
if (![UIImagePickerController isSourceTypeAvailable:sourceType])
{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Device has no camera"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    
    [myAlertView show];
    return FALSE;
    
}
    else
    {
        return TRUE;
    }
    return FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*!
 * Tesseract return correct data if provided image in UIImageOrientationUp ,else it gives garbage value .
 * method change orientation if capture orientation is wrong.
 * \param camera capture image/photo library image
 * \returns Image with correct orientation.
 */
-(UIImage *)fixOrientation:(UIImage *)image
{
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}





/*!
 * converting image to pixel to achive clearity in OCR and send converted image to tessaract..
 * \param image
 * \returns nil.
 */

- (void)setTesseractImage:(UIImage *)image
{
    free(pixels);
    
    CGSize size = [image size];
    int width = size.width;
    int height = size.height;
    
	if (width <= 0 || height <= 0)
		return;
    
    // the pixels will be painted to this array
    pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    
    //creating image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    
    
	// we're done with the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-=*/!""'.:@" forKey:@"tessedit_char_whitelist"];
    //  [tesseract setImage:[UIImage imageNamed:@"image_sample.jpg"]];
    [tesseract setImage:resultUIImage];
    [tesseract recognize];
    NSString *recognizedTextData=[tesseract recognizedText];
    //NSLog(@"%@", [tesseract recognizedText]);
    
    
    UIAlertView *textAlertView = [[UIAlertView alloc] initWithTitle:@"Text"
                                                            message:recognizedTextData
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
    
    [textAlertView show];

    
  //  tesseract->SetImage((const unsigned char *) pixels, width, height, sizeof(uint32_t), width * sizeof(uint32_t));
}

/*!
 * Resizing the image to achive clearity in OCR
 * \param image
 * \returns Image with 640x640.
 */

-(UIImage *)resizeImage:(UIImage *)image {
    
    CGImageRef imageRef = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (alphaInfo == kCGImageAlphaNone)
        alphaInfo = kCGImageAlphaNoneSkipLast;
    
    int width, height;
    
    width = 640;//[image size].width;
    height = 640;//[image size].height;
    
    CGContextRef bitmap;
    
    if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
    }
    
    if (image.imageOrientation == UIImageOrientationLeft) {
        NSLog(@"image orientation left");
        CGContextRotateCTM (bitmap, 5159.23);
        CGContextTranslateCTM (bitmap, 0, -height);
        
    } else if (image.imageOrientation == UIImageOrientationRight) {
        NSLog(@"image orientation right");
        CGContextRotateCTM (bitmap, -5159.23);
        CGContextTranslateCTM (bitmap, -width, 0);
        
    } else if (image.imageOrientation == UIImageOrientationUp) {
        NSLog(@"image orientation up");
        
    } else if (image.imageOrientation == UIImageOrientationDown) {
        NSLog(@"image orientation down");
        CGContextTranslateCTM (bitmap, width,height);
        CGContextRotateCTM (bitmap,10318.47);
        
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}

- (UIImage *) toGrayscale:(UIImage*)img
{
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, img.size.width * img.scale, img.size.height * img.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels1 = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels1, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method:     http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:img.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}


@end
