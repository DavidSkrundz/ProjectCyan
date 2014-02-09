//
//  ViewController.m
//  ProjectCyan
//
//  Created by David Skrundz on 2/8/2014.
//  Copyright (c) 2014 David Skrundz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	items = [[NSMutableArray alloc] init];
	
	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[self.scrollView setContentSize:CGSizeMake(2304, self.scrollView.frame.size.height)];
		} else {
			[self.scrollView setContentSize:CGSizeMake(960, self.scrollView.frame.size.height)];
		}
		[self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
	});
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;//kCLLocationAccuracyKilometer;
	locationManager.distanceFilter = 1; //meters
	[locationManager startUpdatingLocation];
}

// Get updates from the scrollviews
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"contentOffset"]) {
		// Get the scroll view
		if ([object isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scroll = (UIScrollView *)object;
			[self setAlphaForImagesWithObject:scroll];
		}
    }
}

#pragma mark - Set proper alpha for the images based on scrollview contentoffset
- (void)setAlphaForImagesWithObject:(UIScrollView *)scrollview {
	int width = 320.0;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		width = 768.0;
	}
	
	NSArray *views = @[self.leftView, self.middleView, self.rightView];
	
	// Calculate the lower index and the opacity it should have
	int index = floor(scrollview.contentOffset.x / width);
	int offset = (int)scrollview.contentOffset.x % width;
	
	if (offset < 0) {
		offset += width;
	}
	
	if (offset == 0 && index < 0) {
		index = 0;
	}
	
	double opacityLow = MAX(0.0, (213.0 - offset)/(213.0));
	double opacityHigh = MAX(0.0, (offset - 107.0)/(213.0));
	
	for (int i = 0; i < [views count]; i++) {
		UIView *view = views[i];
		
		if (i == index) {
			[view setAlpha:opacityLow];
		} else if (i == (index + 1)) {
			[view setAlpha:opacityHigh];
		} else {
			[view setAlpha:0];
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)search:(id)sender {
	
}

- (IBAction)settings:(id)sender {
	
}

#pragma mark - Buttons

- (IBAction)leftButton:(id)sender {
	[self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)middleButton:(id)sender {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.scrollView setContentOffset:CGPointMake(768, 0) animated:YES];
	} else {
		[self.scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
	}
}

- (IBAction)rightButton:(id)sender {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.scrollView setContentOffset:CGPointMake(1536, 0) animated:YES];
	} else {
		[self.scrollView setContentOffset:CGPointMake(640, 0) animated:YES];
	}
}

- (IBAction)backFromMap:(id)sender {
	[self.mapBG setHidden:YES];
	
	[self.map removeOverlays:self.map.overlays];
	[self.map removeAnnotations:self.map.annotations];
}

#pragma mark - Network

- (IBAction)refresh:(id)sender {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.190/pull.php?lat=%f&lon=%f&type=coffee", lat, lon]];
	NSData *urlData = [NSData dataWithContentsOfURL:url];
//	NSLog(@"%@", [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]);
	[self parseData:urlData];
}

- (void)parseData:(NSData *)data {
	NSError *error;
	NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//	NSLog(@"%@", dictionary);
	
	[items removeAllObjects];
	
	NSMutableArray *array = [dictionary objectForKey:@"devices"];
	for (NSMutableDictionary *dict in array) {
//		NSLog(@"%@", dict);
		if (![[dict objectForKey:@"NONE"] isEqualToString:@"NONE"]) {
			for (id key in dict.allKeys) {
				NSMutableDictionary *d = [dict objectForKey:key];
//				NSLog(@"%@", d);
				
				NSString *uuid = key;
				int count = [[d objectForKey:@"count"] intValue];
				double delta = [[d objectForKey:@"delta"] doubleValue];
				
				NSMutableDictionary *dd = [d objectForKey:@"loc"];
				NSString *addr = [dd objectForKey:@"addr"];
				NSString *lat = [dd objectForKey:@"lat"];
				NSString *lon = [dd objectForKey:@"lon"];
				NSString *name = [dd objectForKey:@"name"];
				
				NSString *time = [d objectForKey:@"t"];
				
				Data *newData = [[Data alloc] initWithUUID:uuid count:count delta:delta address:addr latitude:lat longitude:lon name:name time:time];
				[items addObject:newData];
			}
		}
	}
	
	[self.leftTable reloadData];
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
	}
	
	if ([tableView isEqual:self.leftTable]) {
		int i = (int)indexPath.row;
		[cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@", ((Data *)items[i]).name, ((Data *)items[i]).address]];
		[cell.detailTextLabel setText:[NSString stringWithFormat:@"Number of People: %d	Time: %.0f minutes", ((Data *)items[i]).count, ((Data *)items[i]).delta * ((Data *)items[i]).count]];
	} else {
		[cell.textLabel setText:@"NOTHING"];
		[cell.detailTextLabel setText:@"NOTHING"];
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return 250;
	} else {
		return 90;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int i = (int)indexPath.row;
	NSString *string = ((Data *)items[i]).address;
	NSString *endLatS = ((Data *)items[i]).latitude;
	NSString *endLonS = ((Data *)items[i]).longitude;
	
	double endLat = [endLatS doubleValue];
	double endLon = (-1) * [endLonS doubleValue];
	
	CLLocationCoordinate2D coord = CLLocationCoordinate2DMake((endLat + lat)/2.0, (endLon + lon)/2.0);
	MKCoordinateSpan span = MKCoordinateSpanMake(1.5*ABS(endLon - lon), 1.5*ABS(endLat - lat));
	[self.map setRegion:MKCoordinateRegionMake(coord, span) animated:YES];
	
	MKPointAnnotation *anotation = [[MKPointAnnotation alloc] init];
	[anotation setTitle:((Data *)items[i]).name];
	[anotation setSubtitle:string];
	[anotation setCoordinate:CLLocationCoordinate2DMake(endLat, endLon)];
	
	MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
	[request setSource:[MKMapItem mapItemForCurrentLocation]];
	[request setDestination:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil]]];
	[request setTransportType:MKDirectionsTransportTypeAny]; // This can be limited to automobile and walking directions.
	[request setRequestsAlternateRoutes:YES]; // Gives you several route options.
	MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		if (!error) {
			for (MKRoute *route in [response routes]) {
				[self.map addOverlay:[route polyline] level:MKOverlayLevelAboveRoads]; // Draws the route above roads, but below labels.
				// You can also get turn-by-turn steps, distance, advisory notices, ETA, etc by accessing various route properties.
			}
		}
	}];
	
	[self.map addAnnotation:anotation];
	
	[self.mapBG setHidden:NO];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - LocationUpdate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation* location = [locations lastObject];
//	NSDate* eventDate = location.timestamp;
//	NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//	if (abs(howRecent) < 15.0) {
//		NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
//	}
	lat = location.coordinate.latitude;
	lon = location.coordinate.longitude;
	
	[self refresh:nil];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
		[renderer setStrokeColor:[UIColor colorWithRed:0.0 green:0.63 blue:1.0 alpha:0.8]];
		[renderer setLineWidth:5.0];
		return renderer;
	}
	return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
	MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Anotation"];
	if (!pinView) {
		pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Anotation"];
		pinView.pinColor = MKPinAnnotationColorRed;
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//		[rightButton addTarget:self action:@selector(myShowDetailsMethod:) forControlEvents:UIControlEventTouchUpInside];
		pinView.rightCalloutAccessoryView = rightButton;
	} else {
		pinView.annotation = annotation;
	}
	return pinView;
}

@end