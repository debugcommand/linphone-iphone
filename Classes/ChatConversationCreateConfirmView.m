//
//  ChatConversationCreateConfirmView.m
//  linphone
//
//  Created by REIS Benjamin on 04/10/2017.
//

#import "ChatConversationCreateConfirmView.h"
#import "PhoneMainView.h"
#import "UIChatCreateConfirmCollectionViewCell.h"

@implementation ChatConversationCreateConfirmView

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
	if (compositeDescription == nil) {
		compositeDescription = [[UICompositeViewDescription alloc] init:self.class
															  statusBar:StatusBarView.class
																 tabBar:TabBarView.class
															   sideMenu:SideMenuView.class
															 fullscreen:false
														 isLeftFragment:NO
														   fragmentWith:ChatsListView.class];
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	_contactsGroup = [[NSMutableArray alloc] init];
	_nameField.delegate = self;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
								   initWithTarget:self
								   action:@selector(dismissKeyboards)];
	tap.delegate = self;
	[self.view addGestureRecognizer:tap];
	UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
	layout.scrollDirection = UICollectionViewScrollDirectionVertical;
	layout.itemSize = CGSizeMake(100.0 , 50.0);
	_collectionController.collectionView = _collectionView;
	_collectionController = (ChatConversationCreateConfirmCollectionViewController *)[[UICollectionViewController alloc] initWithCollectionViewLayout:layout];
	_collectionView.dataSource = self;
	[_collectionView setCollectionViewLayout:layout];
}

- (void) viewWillAppear:(BOOL)animated {
	for(id uri in _contacts.allKeys) {
		[_collectionView registerClass:UIChatCreateConfirmCollectionViewCell.class forCellWithReuseIdentifier:uri];
		if(![_contactsGroup containsObject:uri])
			[_contactsGroup addObject:uri];
	}
	[_collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[_contactsGroup removeAllObjects];
	[_contacts removeAllObjects];
}

- (void)dismissKeyboards {
	if ([_nameField isFirstResponder]) {
		[_nameField resignFirstResponder];
	}
}

- (IBAction)onBackClick:(id)sender {
	[PhoneMainView.instance popToView:ChatConversationCreateView.compositeViewDescription];
}

- (IBAction)onValidateClick:(id)sender {
	LinphoneChatRoom *room =  linphone_core_create_client_group_chat_room(LC, _nameField.text.UTF8String);
	bctbx_list_t *addresses = NULL;
	for (id object in _contactsGroup) {
		LinphoneAddress *addr = linphone_address_new(((NSString *)object).UTF8String);
		if(addresses)
			bctbx_list_append(addresses, addr);
		else
			addresses = bctbx_list_new(addr);
	}
	linphone_chat_room_add_participants(room, addresses);
}

- (void)deleteContact:(NSString *)uri {
	[_contacts removeObjectForKey:uri];
	[_contactsGroup removeObject:uri];
	[_collectionView reloadData];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	_validateButton.enabled = !((string.length == 0 || string == nil || [string isEqual:@""]) && (textField.text.length == 1));
	return TRUE;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _contacts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (UIChatCreateConfirmCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString *uri = _contactsGroup[indexPath.item];
	UIChatCreateConfirmCollectionViewCell *cell = (UIChatCreateConfirmCollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:uri forIndexPath:indexPath];
	cell.uri = uri;
	cell.confirmController = self;
	cell = [cell initWithName:_contacts[uri]];
	return cell;
}

@end
