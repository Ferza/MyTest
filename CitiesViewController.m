//
//  CitiesViewController.m
//  Flats
//
//  Created by iPlusDev3 on 13.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "CitiesViewController.h"

@interface CitiesViewController ()

@end

@implementation CitiesViewController
@synthesize cValue;
@synthesize cityName;
@synthesize delegate;
@synthesize addVC;
@synthesize district;

i=0;
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

//////////////core data

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

-(void)getDataFromServer{
    NSString *city;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (![cValue isEqualToString:@"2"])
    {
        
        if ([cValue isEqual:@"0"]) {//cities
            val=@"ECity";
            city=@"city";
        }
        else if ([cValue isEqual:@"1"]){//districts
            val=@"EDistrict";
            city=@"district";
        }
        id appDelegate = [[UIApplication sharedApplication] delegate];
       ////lastID
        long lastId=[appDelegate getLastID:val];
       
        NSString *url;
        if ([cValue isEqualToString: @"0"]) {
            url = [NSString stringWithFormat:@"http://citatas.biz/flats/Api/list?login=%@&city=%@&city_id=%ld",        [appDelegate getUUID],city,lastId];
        }
        if ([cValue isEqualToString:@"1"]) {
            url = [NSString stringWithFormat:@"http://citatas.biz/flats/Api/list?login=%@&district=%@&district_id=%ld",        [appDelegate getUUID],city,lastId];
        }
        
        _rssParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        _bashItems=[NSMutableArray arrayWithCapacity:100];
        [_rssParser setDelegate:self];
        [_rssParser parse];
        ////////////////////////
        
        //cities on server: city_id, name
        //core data: id, name
        //districts on server:disrict_id, namre, id_city
        //core data:id, name, id_city
        if(([_bashItems count]!=0)&&([[_bashItems objectAtIndex:0] valueForKey:@"status"]==nil)){//there are new records on server
            ////////////////
            for (int j=0; j<_bashItems.count; j++) {
                CItem *qItem=[_bashItems objectAtIndex:j];
                if ([cValue isEqual:@"0"]) {
                    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ECity" inManagedObjectContext:managedObjectContext];
                    [newItem setValue:qItem.city_name forKey:@"name"];
                    [newItem setValue:[NSNumber numberWithInt:[qItem.city_id intValue]] forKey:@"id"];
                    
                    NSError *error = nil;
                    if(![managedObjectContext save:&error]){
                        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
                    }
                }
                else if ([cValue isEqual:@"1"]){
                    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"EDistrict" inManagedObjectContext:managedObjectContext];
                    [newItem setValue:qItem.district_name forKey:@"name"];
                    [newItem setValue:[NSNumber numberWithInt:[qItem.district_id intValue]] forKey:@"id"];
                    [newItem setValue:[NSNumber numberWithInt:[qItem.id_city intValue]] forKey:@"id_city"];
                    NSError *error = nil;
                    if(![managedObjectContext save:&error]){
                        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
                    }
                }
            }
        }
    }
}
-(void)getDataFromCore{
    if ([cValue isEqualToString:@"0"]) {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ECity"];
        self.myList = [[managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
        [self.tableView reloadData];
    }
    else {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
              //получаем районы выбранного города=районы с id_city=idCity
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EDistrict"];
        long id_c=[self getIDCity];
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"id_city==%ld",id_c];//ID is integer!!!!
        [fetchRequest setPredicate:pred];
        
        self.myList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        [self.tableView reloadData];
    }
  
}
/////////////////////////////

-(long)getIDCity{
    //получаем id выбранного города
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ECity"];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name LIKE %@",cityName];//по названию города
    [request setPredicate:predicate];
    
    NSMutableArray *obj=[[managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
    NSManagedObject *listItem = [obj objectAtIndex:0];
    NSInteger id_c=[[listItem valueForKey:@"id"] integerValue];
    return id_c;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    NSString *unique = [NSString stringWithFormat:@"%d",i];//для перебора всех item(item_unique)

    if ( [elementName isEqualToString:[@"item_" stringByAppendingString:unique]] ) {
        _currentItem = [[CItem alloc] init];
        return;
        
    }
    //дописать поля из таблицы!!!!!!!!!!
    else if ([elementName isEqualToString:@"city_id"]||[elementName isEqualToString:@"city_name"]||[elementName isEqualToString:@"district_id"] ||[elementName isEqualToString:@"district_name"]||[elementName isEqualToString:@"id_city"]||[elementName isEqualToString:@"status"]) {
        _currentProperty = elementName;
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!_currentValue) {
        _currentValue = [[NSMutableString alloc] initWithCapacity:500];
    }
    [_currentValue appendString:string];
    
    // избавляемся от лишней инфо
    NSString *trimmedString = [_currentValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
    [_currentValue setString:trimmedString];
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    NSString *unique=[NSString stringWithFormat:@"%d",i];
    if ( [elementName isEqualToString:[@"item_" stringByAppendingString:unique]] ) {
        [_bashItems addObject:_currentItem];
        i++;
        return;
    }
    else if ([elementName isEqualToString:_currentProperty]){
        [_currentItem setValue:_currentValue forProperty:_currentProperty];
    }
    _currentValue = nil;
    
}

///////////парсер//////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![cValue isEqualToString:@"2"]) {
        [self getDataFromServer];
        [self getDataFromCore];
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
        backButton.title=@"Поиск";
        self.navigationItem.backBarButtonItem=backButton;
    }else{
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
        backButton.title=@"Назад";
        self.navigationItem.backBarButtonItem=backButton;
        if ([cValue isEqualToString:@"0"]) {
            lastIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
            DistrictName=@"[";
        }
    }
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
    NSInteger result=1;
    // Return the number of rows in the section.
    
    if ([cValue isEqualToString:@"2"]) {
        result=5;
    }else if(([cValue isEqualToString:@"0"])||([cValue isEqualToString:@"1"])){
        result=[self.myList count];
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    static NSString *simpleTableIndetfier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIndetfier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIndetfier];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    if ([cValue isEqualToString:@"2"]) {
        [self configureCell:cell atIndexPath:indexPath];
    }
    else{
    NSManagedObject *listItem = [self.myList objectAtIndex:indexPath.row];
    cell.textLabel.text=[listItem valueForKey:@"name"];
    }
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=@"1-к квартира";
            break;
        case 1:
            cell.textLabel.text=@"2-к квартира";
            break;
        case 2:
            cell.textLabel.text=@"3-к квартира";
            break;
        case 3:
            cell.textLabel.text=@"4-к квартира";
            break;
        case 4:
            cell.textLabel.text=@"Комната";
            break;
        default:
            break;
    }
}
////////удалить потом!!!!!!!
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{

    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        // Удаляем выделенный пункт
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:[self.myList objectAtIndex:indexPath.row]];
        [self.myList removeObject:[self.myList objectAtIndex:indexPath.row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        // Сохраняем изменения
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *newCell =[tableView cellForRowAtIndexPath:indexPath];

    if (([cValue isEqualToString: @"0"])||(addVC!=nil)) {
        int newRow = [indexPath row];
        int oldRow = [lastIndexPath row];
       
            if (newRow != oldRow)
            {
                newCell = [tableView  cellForRowAtIndexPath:indexPath];
                newCell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: lastIndexPath];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
                
                lastIndexPath = indexPath;
            }
            else{
                 newCell.accessoryType = UITableViewCellAccessoryCheckmark;
                lastIndexPath = indexPath;
            }
    }
    else{//мультивыбор районов
        BOOL isSelected = (newCell.accessoryType == UITableViewCellAccessoryCheckmark);
        if (isSelected) {
            newCell.accessoryType = UITableViewCellAccessoryNone;
        DistrictName = [DistrictName stringByReplacingOccurrencesOfString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text withString:@""];
        }
        else {
           // NSString *dName;
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            if (DistrictName==nil) {
                DistrictName=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            }
            else{
                DistrictName=[[DistrictName stringByAppendingString:@" "] stringByAppendingString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

        /////////////////
if (![cValue isEqualToString:@"2"]) {
    
    if (([cValue isEqualToString:@"0"])||(addVC!=nil)) {
        if (([cityName isEqualToString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text])||(cityName==nil)) {
        [self.delegate getCityName:self city:[tableView cellForRowAtIndexPath:indexPath].textLabel.text isCity:NO];
            
            //////
            if (district!=nil) {
                [self.delegate getCityName:self city:[tableView cellForRowAtIndexPath:indexPath].textLabel.text isCity:NO];
            }
            else{
                [self.delegate getCityName:self city:[tableView cellForRowAtIndexPath:indexPath].textLabel.text isCity:YES];
            }
//////////////////
        }
        else{
            if (district!=nil) {
             [self.delegate getCityName:self city:[tableView cellForRowAtIndexPath:indexPath].textLabel.text isCity:NO];
            }
            else{
            [self.delegate getCityName:self city:[tableView cellForRowAtIndexPath:indexPath].textLabel.text isCity:YES];
            }
        }
    }
    else{
         [self.delegate getCityName:self city:DistrictName isCity:NO];
     }
        
    }
  else{
      [self.delegate getRooms:self rooms:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    }
}


#pragma mark - Navigation
/*
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // UIViewController *controller=self.parentViewController;
   

}*/

@end
