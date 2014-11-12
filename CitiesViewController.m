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
@synthesize districtName;
@synthesize roomsIndex;

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
    NSString *city;//для запроса серверу(чтобы было понятно к какой модели обращаться)
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (cValue!=2)
    {
      switch (cValue) {
            case 0:{//cities
                val=@"ECity";
                city=@"city";
            }
                break;
            case 1:{//cities
                val=@"EDistrict";
                city=@"district";
            }
                break;
            case 3:{//subways
                val=@"ESubway";
                city=@"subway";
            }
                break;
            default:
                break;
        }
        
        id appDelegate = [[UIApplication sharedApplication] delegate];
       ////lastID
        long lastId=[appDelegate getLastID:val];
       
        NSString *url;
        
        switch (cValue) {
            case 0:{
                url = [NSString stringWithFormat:@"http://citatas.biz/flats/Api/list?login=%@&city=%@&city_id=%ld",[appDelegate getUUID],city,lastId];
            }
                break;
            case 1: {
                url = [NSString stringWithFormat:@"http://citatas.biz/flats/Api/list?login=%@&district=%@&district_id=%ld",[appDelegate getUUID],city,lastId];
            }
                break;
          /*  case 3: {
                url = [NSString stringWithFormat:@"http://citatas.biz/flats/Api/list?login=%@&subway=%@&district_id=%ld",[appDelegate getUUID],city,lastId];
            }
                break;*/
            default:
                break;
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
                switch(cValue){
                    case 0:{
                    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ECity" inManagedObjectContext:managedObjectContext];
                    [newItem setValue:qItem.city_name forKey:@"name"];
                    [newItem setValue:[NSNumber numberWithInt:[qItem.city_id intValue]] forKey:@"id"];
                    
                    NSError *error = nil;
                    if(![managedObjectContext save:&error]){
                        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
                    }
                }
                        break;//0
                        
                    case 1:{
                    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"EDistrict" inManagedObjectContext:managedObjectContext];
                    [newItem setValue:qItem.district_name forKey:@"name"];
                    [newItem setValue:[NSNumber numberWithInt:[qItem.district_id intValue]] forKey:@"id"];
                    [newItem setValue:[NSNumber numberWithInt:[qItem.id_city intValue]] forKey:@"id_city"];
                    NSError *error = nil;
                    if(![managedObjectContext save:&error]){
                        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
                    }
                }
                break;///1
                        
                  /* case 3:{//subway
                        NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ESubway" inManagedObjectContext:managedObjectContext];
                        [newItem setValue:qItem.subway_name forKey:@"name"];
                        [newItem setValue:[NSNumber numberWithInt:[qItem.subway_id intValue]] forKey:@"id"];
                        [newItem setValue:[NSNumber numberWithInt:[qItem.id_city intValue]] forKey:@"id_city"];
                        NSError *error = nil;
                        if(![managedObjectContext save:&error]){
                            NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
                        }
                    }
                        break;///3
                        */
                        default:
                        break;
                }
            }
        }
    }
}
-(void)getDataFromCore{
    
    switch (cValue) {
        case 0:{
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ECity"];
            self.myList = [[managedObjectContext executeFetchRequest:request error:nil] mutableCopy];
            [self.tableView reloadData];
        }
            break;
        case 1:{
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            //получаем районы выбранного города=районы с id_city=idCity
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EDistrict"];
            long id_c=[self getIDCity];
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"id_city==%ld",id_c];//ID is integer!!!!
            [fetchRequest setPredicate:pred];
            
            self.myList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            [self.tableView reloadData];
        }
            break;
        /*case 3:{
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            //получаем районы выбранного города=районы с id_city=idCity
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ESubway"];
            long id_c=[self getIDCity];
            NSPredicate *pred =[NSPredicate predicateWithFormat:@"id_city==%ld",id_c];//ID is integer!!!!
            [fetchRequest setPredicate:pred];
            
            self.myList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            [self.tableView reloadData];
            
        }
            break;*/
        default:
            break;
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
    else if ([elementName isEqualToString:@"city_id"]||[elementName isEqualToString:@"city_name"]||[elementName isEqualToString:@"district_id"] ||[elementName isEqualToString:@"district_name"]||[elementName isEqualToString:@"id_city"]||[elementName isEqualToString:@"status"]||[elementName isEqualToString:@"subway_name"]||[elementName isEqualToString:@"subway_id"]) {
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setParams];
}

-(void)setParams{
    if (cValue!=2) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, headerView.frame.size.height)];
        
        if (cValue==0) {
            self.btnSubway.hidden=true;
            [self getDataFromServer];
            [self getDataFromCore];
            //lastIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        }else{
            if (cityName!=nil) {
                [self getDataFromServer];
                [self getDataFromCore];
                labelView.text=cityName;
                labelView.font = [UIFont boldSystemFontOfSize:10];
                headerView.backgroundColor = [UIColor lightGrayColor];
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Внимание!" message:@"Необходимо выбрать город!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }
        [headerView addSubview:labelView];
        self.tableView.tableHeaderView = headerView;
        
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
        backButton.title=@"Поиск";
        self.navigationItem.backBarButtonItem=backButton;
    }
    else{
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
        backButton.title=@"Назад";
        self.navigationItem.backBarButtonItem=backButton;
        self.btnSubway.hidden=true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result=1;
    // Return the number of sections.
    if (((cValue==1)||(cValue==3))&&(addVC==nil)) {//subway & districts
        result=2;
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result=1;
    // Return the number of rows in the section.
    switch (cValue) {
        case 0:
            result=[self.myList count];
            break;
        case 1:
            if ((section==1)||(addVC!=nil)){
                result=[self.myList count];
            }
            break;
        case 2:
            result=5;
            break;
        case 3://subway
            if ((section==1)||(addVC!=nil)){
            result=[self.myList count];
        }
            break;
        default:
            break;
    }

    return result;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView=[[UIView alloc] initWithFrame:CGRectZero];
    if ((section==0)&&((cValue==1)||(cValue==3))&&(addVC==nil)) {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 200, 40)];
        footerView.backgroundColor=[UIColor lightGrayColor];
    }
    return footerView;
}

-(void)cellConfig:(UITableViewCell *)cell cellIndex:(int)row{
    NSManagedObject *listItem = [self.myList objectAtIndex:row];
    cell.textLabel.text=[listItem valueForKey:@"name"];
    if ([[listItem valueForKey:@"is_selected"]integerValue]==1) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
}

-(void)configureCell:(UITableViewCell *)cell atIndexP:(NSIndexPath *)indexPath{
    if (addVC==nil) {
        switch (cValue) {//если значение поля is_selected ==1, то отмечаем галочкой запись
            case 0:{
                [self cellConfig:cell cellIndex:indexPath.row];
                if ([cityName isEqualToString:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text]) {
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                    [self setIsSelected:indexPath.row isSelected:1];/////
                }
            }
                break;
            case 1:{
                if (indexPath.section==0) {
                    cell.textLabel.text=@"Все районы";
                    if ([districtName isEqualToString:@"Все районы"]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        for (int u=0; u<self.myList.count; u++) {
                            NSIndexPath *indexP=[NSIndexPath indexPathForRow:u inSection:1];
                            [self setIsSelected:indexP.row isSelected:0];/////
                        }
                    }
                }
                else{
                    [self cellConfig:cell cellIndex:indexPath.row];
                }
            }
                break;
                /* case 3:if (indexPath.section==0) {
                 cell.textLabel.text=@"Все станции метро";
                 if ([districtName isEqualToString:@"Все станции метро"]) {
                 cell.accessoryType = UITableViewCellAccessoryCheckmark;                }
                 }else{
                 NSManagedObject *listItem = [self.myList objectAtIndex:indexPath.row];
                 cell.textLabel.text=[listItem valueForKey:@"name"];}
                 break;*/
            default:
                break;
        }
    }else{///добавление объявления
        ///////
        switch (cValue) {
            case 0:{
                [self deSelect:cityName isVal:@"Город"];
                [self cellConfig:cell cellIndex:indexPath.row];
            }
                break;
            case 1:{
                [self deSelect:districtName isVal:@"Выберите район"];
                [self cellConfig:cell cellIndex:indexPath.row];
            }
                break;
            case 2:{
                [self configureCell:cell atIndexPath:indexPath];
    
                /*if (roomsIndex.row==indexPath.row) {
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                }*/
            }
                break;
            case 3:
               /* [self deSelect:subwayName isVal:@"Метро"];
                [self cellConfig:cell cellIndex:indexPath.row];*/
                break;
            default:
                break;
        }
    }
}
-(void)deSelect:(NSString *)name isVal:(NSString *)value{
    if ([name isEqualToString: value]) {
        for (int y=0; y<self.myList.count; y++) {
            NSIndexPath *indexPathD=[NSIndexPath indexPathForRow:y inSection:0];
            [self.tableView cellForRowAtIndexPath:indexPathD].accessoryType=UITableViewCellEditingStyleNone;
            [self setIsSelected:indexPathD.row isSelected:0];
        }
    }
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
    
    [self configureCell:cell atIndexP:indexPath];
    
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

-(void)setIsSelected:(int)row isSelected:(int)value {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *listItem=[self.myList objectAtIndex:row];
    [listItem setValue:[NSNumber numberWithInt:value] forKey: @"is_selected" ];
    // Сохраняем изменения
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(void)getDistricts:(NSIndexPath *)indexPath{

    districtName=[districtName stringByReplacingOccurrencesOfString:[[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text stringByAppendingString:@", "] withString:@""];
    districtName=[districtName stringByReplacingOccurrencesOfString:[@", " stringByAppendingString:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text]withString:@""];
    districtName=[districtName stringByReplacingOccurrencesOfString:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text withString:@""];
}


-(void)multiSelectDistricts:(NSIndexPath *)indexPath tableV:(UITableView*)tableView {
    UITableViewCell *newCell =[tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelected = (newCell.accessoryType == UITableViewCellAccessoryCheckmark);
    NSIndexPath *indexPathD=[NSIndexPath indexPathForRow:0 inSection:0];
    BOOL isAllSelected=([self.tableView cellForRowAtIndexPath:indexPathD].accessoryType==UITableViewCellAccessoryCheckmark);
    if ((!isAllSelected)&&(newCell!=[self.tableView cellForRowAtIndexPath:indexPathD])) {//если не выбраны все районы
        
        if (isSelected) {//если район уже был выбран
            newCell.accessoryType = UITableViewCellAccessoryNone;
            [self getDistricts:indexPath];//формируем строку выбранных районов путем удаления только что выбранного
            NSLog(@"%@",districtName);
            [self setIsSelected:indexPath.row isSelected:0];//отмечаем в базе, что район был выбран
        }
        else {
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            if (districtName==nil) {//если еще не был выбран район
                districtName=[tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                [self setIsSelected:indexPath.row isSelected:1];
            }
            else{///trouble
                districtName=[[districtName stringByAppendingString:@", "] stringByAppendingString:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
                [self setIsSelected:indexPath.row isSelected:1];
            }
        }
    }/////if (!isAllSelected)
    else{
        if (newCell==[self.tableView cellForRowAtIndexPath:indexPathD]) {
            if (isAllSelected) {
                [self.tableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryNone;
                [self getDistricts:indexPath];
            }
            else{
                [self.tableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryCheckmark;
                districtName=[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
                for (int y=0; y<self.myList.count; y++) {
                    indexPathD=[NSIndexPath indexPathForRow:y inSection:1];
                    [self.tableView cellForRowAtIndexPath:indexPathD].accessoryType=UITableViewCellEditingStyleNone;
                }
            }
        }////newCell=isAllSelected
        else{
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryType=UITableViewCellAccessoryCheckmark;
            [self.tableView cellForRowAtIndexPath:indexPathD].accessoryType=UITableViewCellAccessoryNone;
            districtName=[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            [self setIsSelected:indexPath.row isSelected:1];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{// написать метод, который будет выбранной записи устанавливать значение поля is_selected в 1
   /* if (cValue==2) {//rooms
        lastIndexPath=roomsIndex;
    }*/
    for (int u=0; u<self.myList.count; u++) {
      NSManagedObject *listItem = [self.myList objectAtIndex:u];
        if ([[listItem valueForKey:@"is_selected"]integerValue]==1) {
            lastIndexPath=[NSIndexPath indexPathForRow:u inSection:0];
        }
    }
    UITableViewCell *newCell =[tableView cellForRowAtIndexPath:indexPath];

    if ((cValue==0)||(addVC!=nil)) {
        int newRow = [indexPath row];
        int oldRow = [lastIndexPath row];
       
            if (newRow != oldRow)
            {
                newCell = [tableView  cellForRowAtIndexPath:indexPath];
                newCell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: lastIndexPath];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
                
                [self setIsSelected:indexPath.row isSelected:1];
                [self setIsSelected:lastIndexPath.row isSelected:0];
                
                lastIndexPath = indexPath;
            }
            else{
                 newCell.accessoryType = UITableViewCellAccessoryCheckmark;
                lastIndexPath = indexPath;
            }
    }
    else{//мультивыбор районов
        [self multiSelectDistricts:indexPath tableV:tableView];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self setParamsToSegue:indexPath];
   }

-(void)setParamsToSegue:(NSIndexPath *)indexPath{
    if (cValue!=2) {
        if (cValue==0) {//город
            if ([cityName isEqualToString:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text]) {//не меняется название города
                [self.delegate getCityName:self city:cityName district:districtName valueIs:cValue];
                
            }else{
                if (addVC==nil) {
                    [self.delegate getCityName:self city:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text district:@"Все районы" valueIs:cValue];
                }else{
                    [self.delegate getCityName:self city:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text district:@"Выберите район" valueIs:cValue];
                }
            }
        }
        else{//район
            if ((addVC==nil)||([districtName isEqualToString:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text])) {
                [self.delegate getCityName:self city:cityName district:districtName valueIs:cValue];
                if ([districtName isEqualToString:@""]) {//если не выбран ни один район, то автоматически все
                    NSIndexPath *indexPathD=[NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView cellForRowAtIndexPath:indexPathD].accessoryType=UITableViewCellAccessoryCheckmark;
                }
            }
            else{
                [self.delegate getCityName:self city:cityName district:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text valueIs:cValue];
            }
        }
    }
    else{
        [self.delegate getRooms:self rooms:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text index:indexPath];
    }
}

#pragma mark - Navigation
/*
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // UIViewController *controller=self.parentViewController;
   

}*/
- (void)reloadData:(BOOL)animated
{
    [self.tableView reloadData];
    
    if (animated) {
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:.5];
        [[self.tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
        
    }
}

- (IBAction)btnSubwayClick:(id)sender {
    if (cValue==1) {
        cValue=3;
        self.title=@"Выбор метро";
        [self.btnSubway setTitle:@"Районы" forState:UIControlStateNormal];
        [self reloadData:YES];
    }else if(cValue==3){
        cValue=1;
        self.title=@"Выбор района";
        [self.btnSubway setTitle:@"Метро" forState:UIControlStateNormal];
        [self reloadData:YES];
    }

}
@end
