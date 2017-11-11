//
//  HomeTableViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 4/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "HomeTableViewController.h"
#import "ArticleDetailViewController.h"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self setupRefresh];
    self.navigationItem.title = @"Safe Night Out";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

        // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupRefresh
{
    UIRefreshControl *control=[[UIRefreshControl alloc]init];
    [control addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
    
    [control beginRefreshing];
    
    [self refreshStateChange:control];
}

-(void)refreshStateChange:(UIRefreshControl *)control
{
        [self.tableView reloadData];
        [control endRefreshing];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.articleInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"articleCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"articleCell"];
    }


    cell.textLabel.text = [[self.articleInfo objectAtIndex:indexPath.row] valueForKey:@"article_title"];
    cell.detailTextLabel.text = [[self.articleInfo objectAtIndex:indexPath.row] valueForKey:@"resource"];
    NSString *strImg = [[self.articleInfo objectAtIndex:indexPath.row] valueForKey:@"image_url"];
    NSString *strImgURLAsString = [NSString stringWithFormat:@"http://safenightout.azurewebsites.net/%1$@",strImg];
    [strImgURLAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *imgURL = [NSURL URLWithString:strImgURLAsString];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imgURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            UIImage *img = [[UIImage alloc] initWithData:data];
            cell.imageView.image = img;
            cell.imageView.layer.cornerRadius = 15;
            cell.imageView.clipsToBounds = YES;
            [cell setNeedsLayout];
            // pass the img to your imageview
        }else{
            NSLog(@"%@",connectionError);
        }
    }];


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"aritcle"];
    [self.navigationController pushViewController:vc animated:YES];
    vc.content = [[self.articleInfo objectAtIndex:indexPath.row] valueForKey:@"content"];
    
    NSString *strImg = [[self.articleInfo objectAtIndex:indexPath.row] valueForKey:@"bigimage_url"];
    NSString *strImgURLAsString = [NSString stringWithFormat:@"http://safenightout.azurewebsites.net/%1$@",strImg];
    [strImgURLAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *imgURL = [NSURL URLWithString:strImgURLAsString];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imgURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            UIImage *img = [[UIImage alloc] initWithData:data];
            vc.bigImage.image = img;
        }else{
            NSLog(@"%@",connectionError);
        }
    }];
}

@end
