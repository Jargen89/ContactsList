//
//  MasterViewController.m
//  ContactsList
//
//  Created by Jason Vieira on 2014-12-16.
//  Copyright (c) 2014 Jargen89. All rights reserved.
//

#import "ContactFeedVc.h"
#import "Constants.h"
#import "GData.h"

@interface ContactFeedVc ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signOutButton;
@property (strong, nonatomic) UIRefreshControl *refreshTug;
@property (strong, nonatomic) GDataServiceTicket *fetchTicket;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property NSMutableArray *contacts;
@end

@implementation ContactFeedVc

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRefreshControl];
    [self signIn];
    //Any further design changes to the interface can be done here
}

#pragma mark - Segues
//in case I add more to this project, a segue will be added to push a specific content to a displayVC

#pragma mark - IBAction
- (IBAction)signOut:(id)sender {
    [self clearCredentials];
    self.contacts = nil;
    [self.tableView reloadData];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    GDataEntryContact *contact = self.contacts[indexPath.row];

    cell.textLabel.text = [[contact name] fullName].stringValue;
    if ([[contact emailAddresses] count] > 0) {
        GDataEmail *email = [contact emailAddresses][0];
        cell.detailTextLabel.text = [email address];
    }
    
    return cell;
}

#pragma mark - Private

-(void)getContacts{
    
    GDataServiceGoogleContact *service = [self contactService];
    GDataServiceTicket *ticket;
    
    BOOL shouldShowDeleted = TRUE;
    
    
    const int maxResults = 2000; //Who has more than this number of contacts? I mean really?
    
    NSURL *feedURL = [GDataServiceGoogleContact contactFeedURLForUserID:kGDataServiceDefaultUser];
    
    GDataQueryContact *query = [GDataQueryContact contactQueryWithFeedURL:feedURL];
    [query setShouldShowDeleted:shouldShowDeleted];
    [query setMaxResults:maxResults];
    
    ticket = [service fetchFeedWithQuery:query
                                delegate:self
                       didFinishSelector:@selector(contactsFetchTicket:finishedWithFeed:error:)];
    
    [self setContactFetchTicket:ticket];
}

- (void)refresh{
    
    if(self.userName && self.password){
        [self getContacts];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You are not signed in" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Sign in" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self signIn];
        }];
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)signIn{
    UIAlertController *signInForm = [UIAlertController alertControllerWithTitle:@"Google Contacts" message:@"Please login to retrieve your Google Contacts" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        self.userName = [(UITextField*)[[signInForm textFields] objectAtIndex:0] text];
        self.password = [(UITextField*)[[signInForm textFields] objectAtIndex:1] text];
        
        [signInForm dismissViewControllerAnimated:YES completion:nil];
        [self getContacts];
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [signInForm dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [signInForm addAction:ok];
    [signInForm addAction:cancel];
    
    [signInForm addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    [signInForm addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:signInForm animated:YES completion:nil];

}

- (void)setContactFetchTicket:(GDataServiceTicket *)ticket
{
    self.fetchTicket = ticket;
}

- (GDataServiceGoogleContact *)contactService
{
    static GDataServiceGoogleContact* service = nil;
    
    if (!service) {
        service = [[GDataServiceGoogleContact alloc] init];
        
        [service setShouldCacheResponseData:YES];
        [service setServiceShouldFollowNextLinks:YES];
    }
    
    // update the username/password each time the service is requested
    [service setUserCredentialsWithUsername:self.userName password:self.password];
    
    return service;
}

- (void)setupRefreshControl{
    self.refreshTug = [[UIRefreshControl alloc] init];
    [self.refreshTug addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    self.refreshControl = self.refreshTug;

}

/*This is the callback method where all of the contacts are returned and added to the displaying array.
 Only contacts with names are added to the array.
 */
- (void)contactsFetchTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedContact *)feed error:(NSError *)error {
    
    if (error) {
        NSDictionary *userInfo = [error userInfo];
        if ([[userInfo objectForKey:@"Error"] isEqual:@"BadAuthentication"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Bad Login Attempt" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self clearCredentials];
                [self signIn];

            }];
            [alert addAction:okay];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Fetch Failed" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self clearCredentials];
                [self signIn];
            }];
            [alert addAction:okay];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        
        self.contacts = [[NSMutableArray alloc] init];
        for (int i = 0; i < [[feed entries] count]; i++) {
            GDataEntryContact *contact = feed.entries[i];
         
            NSString *name = [[[contact name] fullName] contentStringValue];
            
            GDataEmail *gmail = [[contact emailAddresses] objectAtIndex:0];
            NSString *email;
            if (gmail && [gmail address]) {
                email = [gmail address];
            }
            
            GDataPhoneNumber *phone = [[contact phoneNumbers] objectAtIndex:0];
            NSString *phNumber;
            if (phone && [phone contentStringValue]) {
                phNumber = [phone contentStringValue];
            }
            
            GDataStructuredPostalAddress *addr = [[contact structuredPostalAddresses] objectAtIndex:0];
            NSString *address;
            if (addr && [addr formattedAddress]) {
                address = [addr formattedAddress];
            }
            
            NSString *dob;
            if ([contact birthday]) {
                dob = [contact birthday];
            }
            
            GDataEntryContent *content = [contact content];
            NSString *notes;
            if (content && [content contentStringValue]) {
                notes = [content contentStringValue];
            }
            
            if (name && (email || phNumber) ) {
                [self.contacts addObject:feed.entries[i]];
            }
        }
        NSString *message = [[NSString alloc] initWithFormat:@"There are %d contacts.", [self.contacts count]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Here you go" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Awesome, thanks!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self.tableView reloadData];
            [self.refreshTug endRefreshing];
        }];
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)clearCredentials{
    [self.refreshTug endRefreshing];
    self.userName = nil;
    self.password = nil;
}
@end
