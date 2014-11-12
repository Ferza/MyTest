//
//  FlatsViewController.m
//  Flats
//
//  Created by iPlusDev3 on 13.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//
#define ROOM_TAG 9
#define DESCRIPTION_TAG 10
#define PLACE_TAG 11

#import "FlatsViewController.h"

@interface FlatsViewController ()

@end

@implementation FlatsViewController{
    int tag;
}
@synthesize cityViewController;
@synthesize myList;
@synthesize btnLike;
@synthesize rooms;
@synthesize lblRooms;
@synthesize lblDistrict;
@synthesize lblDescript;
@synthesize tvDescript;
@synthesize myPhoto;
@synthesize btnDelete;
@synthesize cityName;
@synthesize districtName;
@synthesize cValue;
@synthesize mainPredicate;

-(void)getPhotoFromCore:(int)flatIndex{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EPhoto"];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"id_flat==%ld",flatIndex];
   // NSLog(@"%@",predicate);
    [fetchRequest setPredicate:predicate];
    myPhoto=[[NSMutableArray alloc] init];
    myPhoto = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

//////////////core data
-(NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context = nil;
    id appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate performSelector:@selector(managedObjectContext)]){
        context = [appDelegate managedObjectContext];
    }
    return context;
}

-(NSManagedObjectModel *)managedObjectModel{
    NSManagedObjectModel *model = nil;
    id appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate performSelector:@selector(managedObjectModel)]){
        model = [appDelegate managedObjectModel];
    }
    return model;
}

///мультивыбор районов
-(NSPredicate *)predicateForDistricts:(NSString *)district{
    
    NSArray *districts=[district componentsSeparatedByString:@", "];

    NSPredicate *districtPredicate;
    NSPredicate *resultPredicate=[NSPredicate predicateWithFormat:@"(place LIKE %@)",districts[0]];
    
    //resultPredicate=[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObject:predicate, nil]];
    //predicate основной предикат=город+комната+избранное
    //составной предикат=основной предикат+ предикат района
    if (districts.count>1) {
        for (int r=1; r<districts.count; r++) {
            if (![districts[r]isEqualToString:@""]) {
                districtPredicate=[NSPredicate predicateWithFormat:@"(place LIKE %@)",districts[r]];
                
                resultPredicate=[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:resultPredicate, districtPredicate, nil]];
            }
        }
    }
    else{
        resultPredicate=[NSPredicate predicateWithFormat:@"(place LIKE %@)",district];
    }

    return resultPredicate;
}

-(void)makeRoomsPredicate{//мультивыбор комнат
    NSArray *room=[rooms componentsSeparatedByString:@"/"];
    
    NSPredicate *roomPredicate;
    mainPredicate=nil;
    for (int y=0; y<room.count; y++) {
        if ([room[y] isEqualToString:@"3-к квартира"]) {
            NSString *roomsF=@"4-к квартира";
            roomPredicate=[NSPredicate predicateWithFormat:@"(rooms LIKE %@) OR (rooms LIKE %@)",room[y],roomsF];
        }
        else{
            roomPredicate=[NSPredicate predicateWithFormat:@"(rooms LIKE %@)",room[y]];
        }
        if (mainPredicate!=nil) {
            mainPredicate=[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:mainPredicate,roomPredicate, nil]];
        }else{
            mainPredicate=roomPredicate;
        }
    }
}

//////////////getting records from core data
-(void)getFlatsFromCore:(NSString *)room is_liked:(int)is_liked{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EFlats"];

    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"city LIKE %@",cityName];
    //NSLog(@"%@",predicate);
    [self makeRoomsPredicate];
    mainPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate,mainPredicate, nil]];
    if (is_liked==1) {
        NSPredicate *likePredicate=[NSPredicate predicateWithFormat:@"(is_favorite==%d)",1];
        mainPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:mainPredicate, likePredicate, nil]];
    }
    
    if(![districtName isEqualToString:@"Все районы"]){
        mainPredicate=[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:mainPredicate, [self predicateForDistricts:districtName], nil]];
    }
    
    NSLog(@"%@",mainPredicate);
    [fetchRequest setPredicate:mainPredicate];
    
    self.myList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)getCityName:(CitiesViewController*)controller city:(NSString*)cityNameIs district:(NSString *)districtNameIs valueIs:(int)value
{
    cityName=cityNameIs;
    districtName=districtNameIs;
    if ([districtNameIs isEqualToString:@""]) {
        districtName=@"Все районы";
    }
    cValue=value;//для перехода к выбору районов или метро
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *indexPathD=[NSIndexPath indexPathForRow:1 inSection:0];

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,indexPathD, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self getFlatsFromCore:rooms is_liked:0];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self getFlatsFromCore:rooms is_liked:0];
 
}
- (void)reloadSections:(NSIndexSet *)sections
      withRowAnimation:(UITableViewRowAnimation)animation{

}
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
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton=YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    if ([[appDelegate days] intValue]!=0) {//!=0 сделать

        if ([[appDelegate days] intValue]==1) {
            labelView.text=[[@"Остался " stringByAppendingString:[appDelegate days]] stringByAppendingString:@" день"];
        }else if([[appDelegate days] intValue]<5){
            labelView.text=[[@"Осталось " stringByAppendingString:[appDelegate days]] stringByAppendingString:@" дня"];
        }else{
            labelView.text=[[@"Осталось " stringByAppendingString:[appDelegate days]] stringByAppendingString:@" дней"];
        }
        
        [headerView addSubview:labelView];
    }
    cityName=@"Москва";
    districtName=@"Все районы";
    cValue=1;//по умолчанию выбор районов
    rooms=@"Комната";
    
    self.tableView.tableHeaderView = headerView;
    [self segControlChange:self.segControl];////????
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result=0;
    if (section==0) {
        result=3;
    }
    if (section==1) {
        result=[myList count];
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    static NSString *simpleTableIndetfier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIndetfier];
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    if (indexPath.section==0) {
        [self configureCell:cell atIndex:indexPath cityName:cityName districtName:districtName];
    }
    else{
        [self configureAnotherCell:cell atIndex:indexPath];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat h=50;
    
    if (indexPath.section==1) {
        h=80;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:8]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    NSManagedObject *listItem=[myList objectAtIndex:indexPath.row] ;
    NSString *txt=[listItem valueForKey:@"descript"];
    
    CGRect rect = [txt boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX)options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:attributes
                    context:nil];
    // use font information from the UILabel to calculate the size
    CGSize textSize = [txt sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:rect.size.height] }];
   CGRect newFrame = lblDescript.frame;
    newFrame.size.height = textSize.height;
    lblDescript.frame = newFrame;
   
        if ([listItem valueForKey:@"photo_count"]!=nil) {
            h=70;
        }
        
    if (textSize.height>50) {
         h=(h+textSize.height)*1.5;
      }
    }
    return h;
}

///////configuring cells in the second section
- (void)configureAnotherCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath
{
    cell.accessoryType=0;
    UIView *cellView = cell.contentView;
    
    NSManagedObject *listItem=[myList objectAtIndex:indexPath.row];
   lblRooms = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
    lblRooms.backgroundColor = [UIColor clearColor];
    lblRooms.font=[UIFont fontWithName:@"Helvetica neue" size:10];
    [lblRooms setText:[listItem valueForKey:@"rooms"]];
    [cellView addSubview:lblRooms];
 
    lblDistrict = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 100, 10)];
    lblDistrict.font=[UIFont fontWithName:@"Helvetica neue" size:8];
    lblDistrict.backgroundColor = [UIColor clearColor];
    [lblDistrict setText:[listItem valueForKey:@"place"]];
    [cellView addSubview:lblDistrict];
    
    tvDescript = [[UITextView alloc]initWithFrame:CGRectMake(15, 30, (cellView.frame.size.width-15), ([self tableView:[self tableView] heightForRowAtIndexPath:indexPath]-50))];
    [tvDescript setUserInteractionEnabled:NO];
    [tvDescript setScrollEnabled:YES];
    tvDescript.scrollsToTop = YES;
    tvDescript.textAlignment = NSTextAlignmentLeft;
    tvDescript.text=[listItem valueForKey:@"descript"];
    tvDescript.delegate=self;
    [cellView addSubview:tvDescript];
    
    /*if ([listItem valueForKey:@"descript"]!=nil) {
    height=[self tableView:[self tableView] heightForRowAtIndexPath:indexPath];
    }*/
    float height=tvDescript.frame.size.height-15;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, height, cell.frame.size.width, 80)];//(x,y,w,h)
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setScrollEnabled:YES];
    UIImage *image;
    ///получаем все фото, принадлежащие данной квартире
    [self getPhotoFromCore:[[listItem valueForKey:@"id"] integerValue]];
    
    NSManagedObject *photoItem;
    
        for (int j=0; j<myPhoto.count; j++) {//j<myPhoto.count
        photoItem=[myPhoto objectAtIndex:j];//перебираем все фото принадлежащие выбранной квартире
        //////////core data-path=photo(server)
        NSString *img_pas=[photoItem valueForKey:@"path"];
   
        NSData *imgData = [NSData dataWithContentsOfFile:img_pas];
        image=[UIImage imageWithData:imgData];
        ///////
       UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((j*75), 0, 70, 70)];
        [imageView setImage:image];
        imageView.tag=j;
        [imageView setUserInteractionEnabled:YES];
        //раскомментировать нужный кусок кода!!!!
       [scrollView addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnImageView:)];
        
        tap.delegate=self;
        [imageView addGestureRecognizer:tap];
    }
   //set content size of you scrollView to the imageView height
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 70)];//imageView.frame.size.height
    [cellView addSubview:scrollView];
    
    btnLike = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect btnThree = CGRectMake(260, 0, 25, 25);
    [btnLike  setFrame:btnThree];
    UIImage *imageLike = [UIImage imageNamed:@"5959_29"];
    [btnLike setImage:imageLike forState:UIControlStateNormal];
    [btnLike  addTarget:self action:@selector(btnLikeClick:) forControlEvents:UIControlEventTouchUpInside];
    btnLike.tag=indexPath.row;
    [cellView addSubview:btnLike];
    
    btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect btDelete = CGRectMake(290, 0, 25, 25);
    [btnDelete  setFrame:btDelete];
    UIImage *imageDelete = [UIImage imageNamed:@"trash"];
    [btnDelete setImage:imageDelete forState:UIControlStateNormal];
    [btnDelete  addTarget:self action:@selector(btnDeleteClick:) forControlEvents:UIControlEventTouchUpInside];
    btnDelete.tag=indexPath.row;
    [cellView addSubview:btnDelete];
/*
     cell.detailTextLabel.text=[[listItem valueForKey:@"name"] stringByAppendingString:[listItem valueForKey:@"phone"]];*/

}

//////gesture
-(void) didTapOnImageView:(UIGestureRecognizer*) recognizer {
    [recognizer locationInView:recognizer.view];
    //NSLog(@"%d",recognizer.view.tag);
    tag=recognizer.view.tag;
   [self performSegueWithIdentifier:@"photo" sender:self];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/////////////configuring cells in the first section
- (void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath cityName:(NSString *)city districtName:(NSString *)district {
    //cell.backgroundColor=[UIColor lightGrayColor];
    switch (indexPath.row) {
        case 0:{
            cell.textLabel.text=city;
            cell.accessoryType=1;
            break;
        }
        case 1:{
            cell.textLabel.text=district;
            cell.accessoryType=1;
            break;
        }
        case 2:{
            cell.accessoryType=0;
            UIView *cellView = cell.contentView;
        
            for (int y=0; y<4; y++) {//buttons
              UIButton  *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                CGRect btnRec = CGRectMake(y*75, 0, 100, 40);
                [btn setFrame:btnRec];
                switch (y) {
                    case 0:
                        [btn setTitle:@"Комната" forState:UIControlStateNormal];
                        break;
                    case 1:
                        [btn setTitle:@"1-комн." forState:UIControlStateNormal];
                        break;
                    case 2:
                        [btn setTitle:@"2-комн." forState:UIControlStateNormal];
                        break;
                    case 3:
                        [btn setTitle:@"3+комн." forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
               
                [btn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
                [cellView addSubview:btn];
                btn.tag=y;
            }
            break;
        }
        default:
            break;
    }
 
}
-(void)btnLikeClick:(UIButton*)sender{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *item=[self.myList objectAtIndex:sender.tag];
    if ([item valueForKey:@"is_favorite"]==[NSNumber numberWithInt:1] ) {
        [item setValue:[NSNumber numberWithInt:0] forKey:@"is_favorite"];
    }else{
        [item setValue:[NSNumber numberWithInt:1] forKey:@"is_favorite"];
    }
    [self saveChangesInCoreData:context];
    if (self.segControl.selectedSegmentIndex==1) {
        [self getFlatsFromCore:rooms is_liked:1];
    }
}

-(void)saveChangesInCoreData:(NSManagedObjectContext *)context{
    // Сохраняем изменения
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}
-(void)btnDeleteClick:(UIButton *)sender{
    // Удаляем выделенный пункт
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *item=[self.myList objectAtIndex:sender.tag];
    [self getPhotoFromCore:[[item valueForKey:@"id"] integerValue]];
    if (self.myPhoto.count!=0) {//удаление фото
        for (int y=0; y<self.myPhoto.count; y++) {
            [context deleteObject:[self.myPhoto objectAtIndex:y]];
        }
    }
 
    /////
    [context deleteObject:[self.myList objectAtIndex:sender.tag]];
    [self.myList removeObject:[self.myList objectAtIndex:sender.tag]];
    NSIndexPath *indPath=[NSIndexPath indexPathForRow:sender.tag inSection:1];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveChangesInCoreData:context];
}

-(void)makeBtnActions:(UIButton *)sender room:(NSString *)room {
    if (sender.selected) {
        rooms=[rooms stringByReplacingOccurrencesOfString:[room stringByAppendingString:@"/"]withString:@""];
        rooms=[rooms stringByReplacingOccurrencesOfString:[@"/" stringByAppendingString:room] withString:@""];
        rooms=[rooms stringByReplacingOccurrencesOfString:room withString:@""];
        sender.selected=NO;
        sender.highlighted=NO;
    }
    else{
        sender.selected=YES;
        rooms=[[rooms stringByAppendingString:@"/"] stringByAppendingString:room];
    }

}

- (void) buttonActions:(UIButton*)sender {

        switch (sender.tag) {
        case 0:
            [self makeBtnActions:sender room:@"Комната"];
            [self segControlChange:sender];
            break;
        case 1:
            [self makeBtnActions:sender room:@"1-к квартира"];
            [self segControlChange:sender];
            break;
        case 2:
            [self makeBtnActions:sender room:@"2-к квартира"];
            [self segControlChange:sender];
            break;
        case 3:
            [self makeBtnActions:sender room:@"3-к квартира"];
            [self segControlChange:sender];
            break;
        
           default:
            break;
    
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if ((indexPath.row==0)||(indexPath.row==1)) {
        [self performSegueWithIdentifier:@"city" sender:self];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:@"city"]) {

    if (self.tableView.indexPathForSelectedRow.section==0) {
        CitiesViewController *upcoming = segue.destinationViewController;
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
        backButton.title=@"Поиск";
        self.navigationItem.backBarButtonItem=backButton;
       // upcoming.cityName=cityName;
       // upcoming.districtName=districtName;
        
    switch ([self.tableView.indexPathForSelectedRow row]) {
            case 0:{
                upcoming.title=@"Выбор города";
                upcoming.cityName=cityName;
                upcoming.districtName=districtName;
                upcoming.cValue=0;
                upcoming.delegate = self;
                break;
            }
            case 1:{
                if (cValue!=3) {
                    upcoming.title=@"Выбор района";
                    upcoming.cityName=cityName;
                    upcoming.districtName=districtName;
                    upcoming.cValue=1;
                    upcoming.delegate = self;
                }else{
                    upcoming.title=@"Выбор метро";
                    upcoming.cityName=cityName;
                    upcoming.districtName=districtName;
                    upcoming.cValue=3;
                    upcoming.delegate = self;
                }
                break;
            }
            default:
            break;
        }
    }
}
    else if ([segue.identifier isEqualToString:@"photo"]) {
        PhotosViewController *upcoming=segue.destinationViewController;

       NSManagedObject *item=[myList objectAtIndex:self.tableView.indexPathForSelectedRow.row];

        upcoming.photoID=[[item valueForKey:@"id"] integerValue];
        upcoming.tag=tag;//индекс выбранного фото
        [self getPhotoFromCore:[[item valueForKey:@"id"] integerValue]];
        upcoming.photoCount=myPhoto.count;//количество фото
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
        backButton.title=@"Готово";
        self.navigationItem.backBarButtonItem=backButton;
    }
    
  else if ([segue.identifier isEqualToString:@"menu"]) {
      MenuViewController *upcoming=segue.destinationViewController;
      upcoming.cityName=cityName;
      upcoming.districtName=districtName;
      upcoming.rooms=rooms;
      upcoming.navigationController.navigationItem.hidesBackButton=YES;
     }
  
}
- (IBAction)segControlChange:(id)sender {
    if (self.segControl.selectedSegmentIndex==0) {
        //is_favorite in dataModel
        [self getFlatsFromCore:rooms is_liked:0];
        [self.segControl setTintColor:[UIColor blueColor]];
    }
    else{
        [self getFlatsFromCore:rooms is_liked:1];
        [self.segControl setTintColor:[UIColor orangeColor]];
    }
}
- (IBAction)btnElseClick:(id)sender {
    [self performSegueWithIdentifier:@"menu" sender:self];
}
@end
