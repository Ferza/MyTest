//
//  MenuViewController.m
//  Flats
//
//  Created by iPlusDev3 on 28.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize cityName;
@synthesize districtName;
@synthesize rooms;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //[self performSegueWithIdentifier:@"FastSegue" sender:nil];
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIndetfier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIndetfier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIndetfier];
    }

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=@"Поиск квартир";
            break;
        case 1:
            cell.textLabel.text=@"Избранное";
            break;
        case 2:
            cell.textLabel.text=@"Разместить объявление";
            break;
        case 3:
            cell.textLabel.text=@"Помощь";
            break;
        case 4:
            cell.textLabel.text=@"Войти через соц. сеть";
            break;
        default:
            break;
    }
    return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h=50;
    switch (indexPath.row) {
        case 2:
             h=h*2;
            break;
        case 3:
            h=h*3;
            break;
        default:
            break;
    }
    return h;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"flats" sender:self];
            [self.delegate getParams:self city:cityName district:districtName rooms:rooms favorite:0];
            break;
        case 1:
            [self.delegate getParams:self city:cityName district:districtName rooms:rooms favorite:1];
            [self performSegueWithIdentifier:@"favorite" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"add" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"help" sender:self];
            break;
        default:
            break;
    }
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"add"]) {
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
        backButton.title=@"Отмена";
        self.navigationItem.backBarButtonItem=backButton;
    }
    if ([segue.identifier isEqualToString:@"flats"]) {
       FlatsViewController *upcoming = segue.destinationViewController;
        upcoming.segControl.selectedSegmentIndex=0;
    }
    if ([segue.identifier isEqualToString:@"favorite"]) {
        FlatsViewController *upcoming = segue.destinationViewController;
        upcoming.segControl.selectedSegmentIndex=1;
    }
  
}



@end
