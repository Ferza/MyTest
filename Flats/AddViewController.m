//
//  AddViewController.m
//  Flats
//
//  Created by iPlusDev3 on 12.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController ()

@end

@implementation AddViewController
@synthesize tvFlat;
@synthesize imageView;
@synthesize tvPrice;
@synthesize tfPhone;
@synthesize tap;
@synthesize tfPrice;
@synthesize cityName;
@synthesize districtName;
@synthesize rooms;
@synthesize cValue;
@synthesize roomsIndex;
///////upload photos to server
/////вызывать метод для каждой фотки
-(void)uploadPhotos:(NSURL *)URL file:(NSURL *)filePath{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    ///продумать запрос на загрузку фото на сервер
    //URL = [NSURL URLWithString:@"http://example.com/upload"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    ////найти способ получения директории сохранения выбранных фото для загрузки
    ////убрать потом ненужный путь!!!!!!!
   //NSURL *filePath = [NSURL fileURLWithPath:@"file://path/to/image.png"];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];
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
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    labelView.text=@"РАСПОЛОЖЕНИЕ";
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
    k=0;
    cValue=1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = 1;
    if (section==0) {
        result=2;
    }else if(section==1){
        result=3;
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
    switch (indexPath.section) {
        case 0:
            [self configureOtherCell:cell atIndexPath:indexPath];
            break;
        case 1:
            [self configureCell:cell atIndexPath:indexPath];
            break;
        case 2:
            [self configureCellPhoto:cell atIndexPath:indexPath];
            break;
        case 3:
            [self configureCellPhone:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
    return cell;
}

-(void)configureCellPhone:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.accessoryType=0;
    UIView *cellView = cell.contentView;
    
    tfPhone=[[UITextField alloc] initWithFrame:cellView.frame];
    [tfPhone setUserInteractionEnabled:YES];
    [tfPhone setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    tfPhone.delegate=self;
    [cellView addSubview:tfPhone];
}

-(void)configureCellPrice:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    UIView *cellView = cell.contentView;
    
    tfPrice=[[UITextField alloc] initWithFrame:CGRectMake(cellView.frame.size.width*0.5, 0, cellView.frame.size.width*0.5, cellView.frame.size.height)];
    [tfPrice setUserInteractionEnabled:YES];
    [tfPrice setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    tfPrice.delegate=self;
    [cellView addSubview:tfPrice];
    
    UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cellView.frame.size.width*0.5, cellView.frame.size.height)];
    lblPrice.backgroundColor = [UIColor clearColor];
    lblPrice.font=[UIFont fontWithName:@"Helvetica neue" size:10];
    lblPrice.text=@"Цена руб/месяц";
    [cellView addSubview:lblPrice];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)configureCellTV:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    UIView *cellView = cell.contentView;
    tvFlat = [[UITextView alloc]initWithFrame:cellView.frame];
    [tvFlat setUserInteractionEnabled:YES];
    [tvFlat setScrollEnabled:YES];
    tvFlat.scrollsToTop = YES;
    tvFlat.textAlignment = NSTextAlignmentLeft;
    tvFlat.text=@"Опишите квартиру";
    tvFlat.delegate=self;
    [cellView addSubview:tvFlat];
    
}

-(void)configureCellPhoto:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.accessoryType=0;
    UIView *cellView = cell.contentView;
    UIImage *image;
  
        //create a UIImage,set the imageName to your image name
       image= [UIImage imageNamed:@"5959_29.png"];
        //create UIImageView and set imageView size to you image height
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40,cell.frame.size.height)];
       [imageView setImage:image];
    
    // set up the image view
    
   // [imageView setBounds:CGRectMake(0.0, 0.0, 120.0, 120.0)];
  //  [imageView setCenter:self.view.center];
    [imageView setUserInteractionEnabled:YES]; // <--- This is very important
    
   tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnImageView:)];
       tap.delegate=self;
    [imageView addGestureRecognizer:tap];
    
    [cellView addSubview:imageView]; // add the image view as a subview of the view controllers view
}

//////gesture
-(void) didTapOnImageView:(UIGestureRecognizer*) recognizer {
    //код который должен отработать
    [self takePicture:recognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            cell.accessoryType=1;
            if (rooms==nil) {
                cell.textLabel.text=@"Комнат";
            }else{
                cell.textLabel.text=rooms;
            }
            break;
        case 1:
            cell.accessoryType=0;
            [self configureCellPrice:cell atIndexPath:indexPath];
            break;
        case 2:
            cell.accessoryType=0;
            [self configureCellTV:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
}

-(void)configureOtherCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        cell.accessoryType=1;
        if (cityName==nil) {
            cell.textLabel.text=@"Город";
        }else{
            cell.textLabel.text=cityName;
        }
    }
    else{
        cell.accessoryType=1;
        if (districtName==nil) {
           cell.textLabel.text=@"Выберите район";
        }else{
            cell.textLabel.text=districtName;
        }
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *result = nil;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    switch (section) {
        case 1:
            label.text = @"ХАРАКТЕРИСТИКИ";
            break;
        case 2:
            label.text = @"ФОТОГРАФИИ";
            break;
        case 3:
            label.text = @"ТЕЛЕФОН";
            break;
        default:
            break;
    }

    label.backgroundColor = [UIColor clearColor];
    
    [label sizeToFit];
    
    /* Сдвинуть метку на 10 пикселей вправо */
    label.frame = CGRectMake(label.frame.origin.x + 10.0f,
                             5.0f, /* Сдвинуть метку на 5 пикселей вниз */
                             label.frame.size.width,
                             label.frame.size.height);
    
    /* Сделать container view на 10 пикселей больше по ширине, чем наша label из-за того, что label нужно на 10 пикселей большеотступа слева */
    CGRect resultFrame = CGRectMake(0.0f,
                                    0.0f,
                                    label.frame.size.height,
                                    label.frame.size.width + 10.0f);
    
    result = [[UIView alloc] initWithFrame:resultFrame];
    
    [result addSubview:label];

    return result;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
   if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldReturn:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}


-(void)textViewDidEndEditing:(UITextView *)textView {
    [self textViewShouldReturn:textView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section==0)||((indexPath.section==1)&&(indexPath.row==0)) ) {
        [self performSegueWithIdentifier:@"aCity" sender:self];
    }
}

-(void)getCityName:(CitiesViewController*)controller city:(NSString*)cityNameIs district:(NSString *)districtNameIs valueIs:(int) value
{
    cityName=cityNameIs;
    districtName=districtNameIs;
    cValue=value;
    [self.tableView reloadData];
}

-(void)getRooms:(CitiesViewController*)controller rooms:(NSString *)roomsCount index:(NSIndexPath *)indexPath{
    rooms=roomsCount;
    roomsIndex=indexPath;
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CitiesViewController *upcoming=segue.destinationViewController;
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] init];
    backButton.title=@"Назад";
    self.navigationItem.backBarButtonItem=backButton;
    
    if (self.tableView.indexPathForSelectedRow.section==0) {
        
    if (self.tableView.indexPathForSelectedRow.row==0) {
        upcoming.cValue=0;
        upcoming.cityName=@"Город";
        upcoming.districtName=districtName;
        upcoming.delegate=self;
    }
    else {
        if (cValue!=3) {
            upcoming.cValue=1;
            upcoming.cityName=cityName;
            upcoming.districtName=districtName;
            upcoming.delegate=self;
        }else{
            upcoming.cValue=3;
            upcoming.cityName=cityName;
            upcoming.districtName=districtName;
            upcoming.delegate=self;
        }

    }
        
    }
    else if(self.tableView.indexPathForSelectedRow.section==1){
        if (self.tableView.indexPathForSelectedRow.row==0) {
            upcoming.cValue=2;
            upcoming.delegate=self;
            upcoming.roomsIndex=roomsIndex;
        }
    }
   upcoming.addVC=@"AddViewController";
}

-(void)addRecordsToCore{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"EFlats" inManagedObjectContext:context];
    
    [newItem setValue:cityName forKey:@"city"];
    [newItem setValue:districtName forKey:@"place"];
    [newItem setValue:rooms forKey:@"rooms"];
    [newItem setValue:self.tvPrice.text forKey:@"price"];
    [newItem setValue:self.tvFlat.text forKey:@"descript"];
    [newItem setValue:self.tfPhone.text forKey:@"phone"];
    /*[newItem setValue:qItem.name forKey:@"name"];
     [newItem setValue:qItem.phone forKey:@"phone"];*/
    [newItem setValue:[NSDate date] forKey:@"pub_date"];
    id appDelegate=[[UIApplication sharedApplication] delegate];
    long lID=[appDelegate getLastID:@"EFlats"];
    [newItem setValue:[NSNumber numberWithLong:(lID+1)] forKey:@"id"];
    // [newItem setValue:[NSNumber numberWithInt:[qItem.photo_count intValue]] forKey:@"photo_count"];
    NSError *error = nil;
    if(![context save:&error]){
        NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
    }

}
- (IBAction)btnAddClick:(id)sender {
     //////add data to Core
    
    if ((![cityName isEqualToString:@"Город"])&&(![districtName isEqualToString:@"Выберите район"])&&(![rooms isEqualToString:@"Комнат"])) {//проверка полей на заполненность
        
    id appDelegate=[[UIApplication sharedApplication] delegate];
    NSString *url=[NSString stringWithFormat:@"http://citatas.biz/flats/Api/create?city=%@&place=%@&rooms=%@&phone=%@&descript=%@&photo_count=%@&creator=%@",cityName,districtName,rooms,self.tfPhone.text,self.tvFlat.text,[NSString stringWithFormat:@"%d", imagePath.count],[appDelegate getUUID]];
        
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
       
    //////////request to server to create record for user
    //запрос возвращает id добавленной записи
   _rssParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    _bashItems=[NSMutableArray arrayWithCapacity:100];
    [_rssParser setDelegate:self];
    [_rssParser parse];

        
    if (_bashItems.count!=0){
        
    QItem *qItem=[_bashItems objectAtIndex:0];
     
    if (![[qItem valueForKey:@"status"]isEqualToString:@"You are not allowed to add records anymore!"]){
    [self addRecordsToCore];//добавление в core data
 
    NSManagedObjectContext *context = [self managedObjectContext];
    //////нужен массив с путями до выбранных фото!!!!!
        
    //формируем адрес фото на сервере
    NSString *urlPhoto=[@"http://citatas.biz/flats/uploads/" stringByAppendingString:[qItem valueForKey:@"status"]];//+id объявления
    
    for (int l=0; l<imagePath.count; l++) {//массив с путями фото формируется при выборе фото
        
    urlPhoto=[[[urlPhoto stringByAppendingString:@"/"] stringByAppendingString:[[[qItem valueForKey:@"status"] stringByAppendingString:@"_"] stringByAppendingString:[NSString stringWithFormat:@"%d",l]]] stringByAppendingString:@".png"];
        //rename file  в формате id_j
  //запрос на создание записи в таблице t_photos на сервере
    NSString *urlR=[NSString stringWithFormat: @"http://citatas.biz/flats/Api/create?photo=%@&id_flat=%@&photo=%@",@"photo",[qItem valueForKey:@"status"],urlPhoto];
        
    _rssParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:urlR]];
        
    //методу передаем путь для размещения фото на сервере
    NSURL *urlRequest=[NSURL fileURLWithPath:urlPhoto];
    //и путь до фото на устройстве, который получаем из массива путей до фото
    //переименование полученного фото и получение пути до него на устройстве
    NSString *photoName=[[[[qItem valueForKey:@"status"] stringByAppendingString:@"_"] stringByAppendingString:[NSString stringWithFormat:@"%d",l]] stringByAppendingString:@".png"];//id_l.png
    NSString *imgName=[self renameFileFrom:imagePath[l] to:photoName];
   
        [self uploadPhotos:urlRequest file:[NSURL URLWithString:imgName]];//метод добавляет фото на сервер
     
        //добавление фото в папку DOCUMENTS
        NSData *photoData = [NSData dataWithContentsOfFile:imgName];
        NSString *filePathPhoto = [DOCUMENTS stringByAppendingPathComponent:photoName];
        [photoData writeToFile:filePathPhoto atomically:YES];
     
        //занесение данных о фото в сущность EPhoto
        NSManagedObject *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"EPhoto" inManagedObjectContext:context];
        long lastPhotoID=[appDelegate getLastID:@"EPhoto"];
        [newPhoto setValue:[NSNumber numberWithLong: lastPhotoID ]forKey:@"id"];
        [newPhoto setValue:[NSNumber numberWithLong: [[qItem valueForKey:@"status"] longValue] ]forKey:@"id_flat"];
        [newPhoto setValue:filePathPhoto forKey:@"path"];
        }//l++
      }//this is the first record from this user
    else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Увы!" message:@"Вы больше не можете добавлять объявления!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

     }//_bashItems.count!=0
        }//все поля заполнены
    else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Внимание!" message:@"Необходимо указать город, район и количество комнат!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (NSString *)renameFileFrom:(NSString*)oldPath to:(NSString *)newName
{
    NSString *newPath=[[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileMan moveItemAtPath:oldPath toPath:newPath error:&error])
    {
        NSLog(@"Failed to move '%@' to '%@': %@", oldPath, newPath, [error localizedDescription]);
        return @"";
    }
    return newPath;
}

/////////////////////parser
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    NSString *unique = [NSString stringWithFormat:@"%d",i];
    
    //если это новое объявление - создадим экземпляр QItem для сохранения в нем данных
    if ( [elementName isEqualToString:[@"item_" stringByAppendingString:unique]] ) {
        _currentItem = [[QItem alloc] init];
        return;
        
    }
    //дописать поля из таблицы!!!!!!!!!!
    else if ([elementName isEqualToString:@"status"]) {
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
    NSString *trimmedString = [_currentValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n\r"]];
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

#pragma mark - Image capture
- (IBAction)takePicture:(UITapGestureRecognizer*)sender {
	UIActionSheet *sheet;
	sheet = [[UIActionSheet alloc] initWithTitle:@"Pick Photo"
										delegate:self
							   cancelButtonTitle:@"Cancel"
						  destructiveButtonTitle:nil
							   otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
	
	[sheet showInView:self.navigationController.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

////проверить
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil); // сохраняем фото в CameraRollAlbum
          //получить путь к файлу
    imagePath [k]= (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    //[self uploadPhotos:imagePath file:<#(NSURL *)#>];
   // NSString* chosed_imagePath = [imagePath path];
    //формируем file-data изображения
   // NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
    //Это собственно стандартный набор данных о фото которые можем вытянуть

     
    ////////////
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextinfo
{
    UIAlertView *alert;
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!"
        message:@"Невозможно сохранить фото в галерее=(" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:@"Ура!"
        message:@"Фотография успешно сохранена в альбоме!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	switch (buttonIndex) {
		case 0: {
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                k++;
				[self presentViewController:imagePicker animated:YES completion:nil];
			}
		}
			break;
		case 1: {
			imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:imagePicker animated:YES completion:nil];
		}
			break;
		default:
			break;
	}
}

@end
