//
//  ViewController.h
//  ProjectCyan
//
//  Created by David Skrundz on 2/8/2014.
//  Copyright (c) 2014 David Skrundz. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;
@import MapKit;

#import "Data.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate> {
	NSMutableArray *items;
	
	CLLocationManager *locationManager;
	
	double lat;
	double lon;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UITableView *leftTable;
@property (weak, nonatomic) IBOutlet UITableView *middleTable;
@property (weak, nonatomic) IBOutlet UITableView *rightTable;

@property (weak, nonatomic) IBOutlet UIView *mapBG;
@property (weak, nonatomic) IBOutlet MKMapView *map;

- (IBAction)leftButton:(id)sender;
- (IBAction)middleButton:(id)sender;
- (IBAction)rightButton:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)settings:(id)sender;

- (IBAction)backFromMap:(id)sender;

@end