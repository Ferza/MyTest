//
//  PhotosViewController.m
//  Flats
//
//  Created by iPlusDev3 on 26.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "PhotosViewController.h"

@interface PhotosViewController (){
    int j;
}

@end

@implementation PhotosViewController
@synthesize image;
@synthesize myImages;
@synthesize imgPath;
@synthesize tag;
@synthesize selfImage;
@synthesize photoCount;
@synthesize photoID;//для получения названия фото

-(void) getNext{
    //устанавливаем анимацию переворачивания
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1]; // сколько длится анимация – в секундах
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.myImage cache:YES]; //повернуть «листок» влево
    
    [self getNextImg];
    [self makeTitle];
    [UIView commitAnimations];
}
// почти тоже самое в методе getPrev
-(void) getPrev{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.myImage cache:YES]; //повернуть листок вправо
    
    [self getPrevImg];
    [self makeTitle];
    [UIView commitAnimations];
}

-(void)getPrevImg{
    
    switch (j) {
        case 0:
            self.myImage.image=myImages[0];
            break;
        case 1:
            j--;
            self.myImage.image=myImages[0];
            break;
        default:
            if (j==photoCount-1) {//5
                self.myImage.image=myImages[1];
                j--;
            }
            else{
                j--;
                [self makeGallery];
                self.myImage.image=myImages[1];
                break;
            }
            break;
    }
}
-(void)getNextImg{
    
    switch (j) {
        case 0:
            self.myImage.image=myImages[1];
            j++;
            break;
            
        default:
            if (j==photoCount-1) {
                self.myImage.image=myImages[2];
            }
            else if (j==photoCount-2) {
                self.myImage.image=myImages[2];
                j++;
            }
            else{
                j++;
                [self makeGallery];
                self.myImage.image=myImages[1];
            }
            
            break;
    }
}

-(void)makeGallery{
    j--;
    [self getImg:j];
    [myImages replaceObjectAtIndex:0 withObject:image];
    
    j++;
    [self getImg:j];
    [myImages replaceObjectAtIndex:1 withObject:image];
    
    j++;
    [self getImg:j];
    [myImages replaceObjectAtIndex:2 withObject:image];
    
    j--;
}

-(void)getImg:(int)indexValue{
    NSString *imgP=[[[[NSString stringWithFormat:@"%d",photoID] stringByAppendingString:@"_"] stringByAppendingString:[NSString stringWithFormat:@"%d",indexValue]] stringByAppendingString:@".png"];
    NSString *imgName= [DOCUMENTS stringByAppendingPathComponent:imgP];//documents/id объявления_j.png
    //проверять на существование
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imgName];
    if (fileExists) {
        NSData *imgData = [NSData dataWithContentsOfFile:imgName];
        
        UIImage *img=[UIImage imageWithData:imgData];
        
        image=img;
    }

}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)makeTitle{
    NSString *titleStr=[[NSString stringWithFormat:@"%d",(j+1)] stringByAppendingString:@" из "];
  //  NSString *imgCount=[NSString stringWithFormat:@"%d",photoCount];
    titleStr=[titleStr stringByAppendingString:[NSString stringWithFormat:@"%d",photoCount]];
    self.navigationItem.title=titleStr;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myImage.image=self.image;
	// Do any additional setup after loading the view.
   //imgPath=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3", nil];
    myImages=[NSMutableArray arrayWithCapacity:3];
    if (tag==0) {
        j=0;
        [self getImg:j];
        [myImages addObject:image];
        
        j=1;
        [self getImg:j];
        [myImages addObject:image];
        
        j=2;
        [self getImg:j];
        [myImages addObject:image];
        j=0;
        
        self.myImage.image=myImages[0];
    }
    else{
        j=0;
        [self getImg:(tag-1)];
        [myImages addObject:image];
        
        j=1;
        [self getImg:tag];
        [myImages addObject:image];
        
        j=2;
        [self getImg:(tag+1)];
        [myImages addObject:image];

       // NSString *imgName= [[NSString stringWithFormat:@"%d",photoID]stringByAppendingString:[NSString stringWithFormat:@"%d",tag]];
        
        //UIImage *img=[UIImage imageNamed:[imgName stringByAppendingString:@".png"]];
        /////
        NSString *imgName= [DOCUMENTS stringByAppendingPathComponent:[[[[NSString stringWithFormat:@"%d",photoID] stringByAppendingString:@"_"] stringByAppendingString:[NSString stringWithFormat:@"%d",tag]] stringByAppendingPathComponent:@".png"]];//documents/id объявления_j.png
        NSData *imgData = [NSData dataWithContentsOfFile:imgName];
        
        UIImage *img=[UIImage imageWithData:imgData];
        
        self.myImage.image=img;//делаем текущей фото выбранную в предыдущем экране
        j=tag%3;
    }
    
    [self makeTitle];
    
    [self.myImage setUserInteractionEnabled:YES];
    //перетащили пальцем вправо
    UISwipeGestureRecognizer *swipenext = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(getNext)];
    [swipenext setDirection:UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionLeft];
    [self.myImage addGestureRecognizer:swipenext];
    //перетащили пальцем влево
    UISwipeGestureRecognizer *swipeback = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(getPrev)];
    [swipeback setDirection:UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionRight];
    [self.myImage addGestureRecognizer:swipeback];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnNextClick:(id)sender {
    [self getNext];
}
@end
