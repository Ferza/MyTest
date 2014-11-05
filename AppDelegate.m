//
//  AppDelegate.m
//  Flats
//
//  Created by iPlusDev3 on 05.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize uuid;
@synthesize image;
@synthesize days;

-(void)getUUID{
    //getting uuid
    uuid= @"";
    NSString *key=@"flatsUUID";
    uuid= [KeychainWrapper keychainStringFromMatchingIdentifier:key];
    if ( uuid==nil) {
        uuid = [NSString generatedString];
        uuid=[uuid MD5Hash];
        
        [KeychainWrapper createKeychainValue:uuid forIdentifier:key];
    }

    ////////////uuid//////////////////////
    
    //////////request to server to create record for user
    NSString *url=[NSString stringWithFormat:@"http://citatas.biz/flats/Api/create?login=%@",uuid];
   
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
   
     NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
     
     if (connection) {
     NSLog(@"Connecting...");
     }
     else {
     NSLog(@"Connection error!");
     }
}

-(void)getPhotosFromServer{
    ///путь к папке сохранения фото
    NSURL* docDir=[self applicationDocumentsDirectory];
   
    NSManagedObjectContext *context = [self managedObjectContext];

    int k=0;//для подсчета количества записей в таблице photo (EPhoto)
    for (int c=0; c<_bashItems.count; c++) {
        QItem *item=[_bashItems objectAtIndex:c];
        NSString *photos=[item valueForKey:@"path"];
        NSArray *photoPath=[photos componentsSeparatedByString:@"["]; //функция для разбора строки
        //и помещения полученных значений в массив photoPath
        /////при запросе на добавление записи на сервер, передавать количество фото, которое можно посчитать при добавлении пути в массив путей к фото
        for (int j=0; j<[[item valueForKey:@"photo_count"] intValue]; j++)///j < количество записей для этого id на сервере в таблице photos
        {   /////на сервере все пути в поле path
            ///надо парсить до символа [ между ними путь к каждой фото
            NSString *img_pas=photoPath[j];
            if (![img_pas isEqual:@""]) {
                [self getPhoto:img_pas];//запрос на получение фото по указанному адресу
                NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"EPhoto" inManagedObjectContext:context];
                ////занесение путей к фото в сущность EPhoto
                NSString *imgPath=[[[[[docDir path] stringByAppendingString:@"/"] stringByAppendingString:[NSString stringWithFormat:@"%d",[[item valueForKey:@"id_rec"] intValue]]] stringByAppendingString:@"_"] stringByAppendingString:[[NSString stringWithFormat:@"%d",j] stringByAppendingString:@".png"]];
                [newItem setValue: imgPath forKey:@"path"];
                [newItem setValue:[NSNumber numberWithInt: k] forKey:@"id"];///id записи в таблице фото
                [newItem setValue:[NSNumber numberWithInt:[[item valueForKey:@"id_rec"] intValue]] forKey:@"id_flat"];//id_flat в таблице фото
                NSError *error = nil;
                if(![context save:&error]){
                    NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
                }
                k++;
            }
            
        }
    }
}
//////photos from server
-(void)getPhoto:(NSString *)urlString{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSLog(@"%@",documentsDirectoryURL );
    
    [downloadTask resume];

}

- (void)getNewFlats {
    
    // получить ID последней записи в локальной БД
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EFlats" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    [request setResultType:NSDictionaryResultType];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"id"];
    
    NSExpression *maxExpression = [NSExpression
                                   expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    [expressionDescription setName:@"maxID"];
    [expressionDescription setExpression:maxExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];

    long lastId=0;
    NSError *error = nil;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    if (objects == nil) {
        
        NSLog(@"Error has occured in reading from core data!!!");
        
    }
    else {
        if ([objects count] > 0) {
            
            NSLog(@"Максимальный ID: %@", [[objects objectAtIndex:0] valueForKey:@"maxID"]);
            lastId=[[[objects objectAtIndex:0] valueForKey:@"maxID"] integerValue];
        }
    }
    ///////////////request to server/////////////
    NSString *url = [NSString stringWithFormat:@"http://citatas.biz/flats/Api/list?login=%@&id=%ld",uuid,lastId];
    
    _rssParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    _bashItems=[NSMutableArray arrayWithCapacity:100];
    [_rssParser setDelegate:self];
    [_rssParser parse];
  
   // [self getPhotos];
    
}
///////creating directory
/////Убрать потом. в ней нет необходимости
-(void)createDir:(NSString *)directory
{
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:directory isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", directory);
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
    else if ([elementName isEqualToString:@"id"]||[elementName isEqualToString:@"city"] || [elementName isEqualToString:@"place"] || [elementName isEqualToString:@"rooms"]||[elementName isEqualToString:@"price"]||[elementName isEqualToString:@"descript"]||[elementName isEqualToString:@"photo"]||[elementName isEqualToString:@"name"]||[elementName isEqualToString:@"phone"]||[elementName isEqualToString:@"pub_date"]||[elementName isEqualToString:@"photo_count"]||[elementName isEqualToString:@"path"]||[elementName isEqualToString:@"days"]) {
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

//////////////adding records to Core Data
-(void)addRecords
{
    for (int j=0; j<_bashItems.count; j++) {
        QItem *qItem=[_bashItems objectAtIndex:j];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"EFlats" inManagedObjectContext:context];
        [newItem setValue:qItem.city forKey:@"city"];
        [newItem setValue:qItem.place forKey:@"place"];
        [newItem setValue:qItem.rooms forKey:@"rooms"];
        [newItem setValue:qItem.price forKey:@"price"];
        [newItem setValue:qItem.descript forKey:@"descript"];
        //[newItem setValue:qItem.photo forKey:@"photo"];
        [newItem setValue:qItem.name forKey:@"name"];
        [newItem setValue:qItem.phone forKey:@"phone"];
        [newItem setValue:qItem.pub_date forKey:@"pub_date"];
        [newItem setValue:[NSNumber numberWithLong:[qItem.id_rec intValue]] forKey:@"id"];
        [newItem setValue:[NSNumber numberWithInt:[qItem.photo_count intValue]] forKey:@"photo_count"];
        days=qItem.days;
        //[newItem setValue:[NSNumber numberWithInt:[qItem.likes intValue]] forKey:@"likes"];
        NSError *error = nil;
        if(![context save:&error]){
            NSLog(@"Can't save! %@ %@", error, [error localizedDescription]);
        }
        
    }
    
}

////////core data для добавления записей

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self getUUID];//uuid
    [self getNewFlats];//getting new flats
    [self getPhotosFromServer];//getting photos from server and adding its to the core data
    [self addRecords];//adding records into core_data
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data stack
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreFlats" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreFlats.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
