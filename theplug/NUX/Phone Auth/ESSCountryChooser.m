//
//  ESSCountryChooser.m
//  ESSPhoneNumberFieldDemo
//
//  Created by Erik Strottmann on 7/11/14.
//  Copyright (c) 2014 Erik Strottmann. All rights reserved.
//

#import "ESSCountryChooser.h"
#import "ESSCountryChooserCell.h"

#import "NBPhoneNumberUtil.h"

@interface ESSCountryChooser ()

/**
 * Mutable dictionary of NSArrays where keys are section titles and values are
 * NSArrays of ESSCountry objects corresponding to that section. Within a
 * section, countries are sorted alphabetically.
 */
@property (nonatomic) NSMutableDictionary *countries;
/** Equivalent to [countries allKeys]. The titles for section headers. */
@property (nonatomic) NSMutableArray *countrySectionTitles;
/** The titles for the section index (quick jump) on the right of the screen. */
@property (nonatomic) NSMutableArray *countryIndexTitles;
/** The cells corresponding to ::selectedCountry. */
@property (nonatomic) NSMutableSet *selectedCells;

@end

@implementation ESSCountryChooser

#pragma mark - Constants

/** Default value for ::defaultSectionTitle. */
NSString * const kESSCountryChooserDefaultDefaultSectionTitle = @"Current Region";
/** Default value for ::dismissDelay. */
NSTimeInterval const kESSCountryChooserDefaultDismissDelay = 0.0f;
/** Reuse identifier for table view cells. */
NSString * const kESSCountryChooserReuseIdentifier = @"kESSCountryChooserReuseIdentifier";

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initializeData];
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ESSCountryChooserCell class]) bundle:nil] forCellReuseIdentifier:kESSCountryChooserReuseIdentifier];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChooser)];
    }
    return self;
}

- (void)initializeData
{
    self.defaultLocale = [NSLocale currentLocale];
    self.selectedCountry = self.defaultCountry;
    self.selectedCells = [NSMutableSet set];
    self.defaultSectionTitle = kESSCountryChooserDefaultDefaultSectionTitle;
    
    self.countries = [NSMutableDictionary dictionary];
    for (NSString *regionCode in [NSLocale ISOCountryCodes]) {
        NSString *identifier = [NSLocale localeIdentifierFromComponents:@{NSLocaleCountryCode:regionCode}];
        NSString *name = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
        
        NBPhoneNumberUtil *util = [NBPhoneNumberUtil sharedInstance];
        NSString *callingCode = [NSString stringWithFormat:@"%@", [util getCountryCodeForRegion:regionCode]];
        
        if (name && callingCode) {
            ESSCountry *country = [ESSCountry countryWithRegionCode:regionCode name:name callingCode:callingCode];
            
            NSString *key = [country.name substringToIndex:1];
            NSMutableArray *array = self.countries[key] ? self.countries[key] : [NSMutableArray array];
            [array addObject:country];
            self.countries[key] = array;
        }
    }
    
    NSMutableArray *sectionTitles = [NSMutableArray arrayWithArray:[self.countries.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    self.countrySectionTitles = sectionTitles;
    [self reloadCountrySectionTitles]; // insert the default section title
    
    NSMutableArray *indexTitles = [NSMutableArray arrayWithArray:[self.countries.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [indexTitles insertObject:UITableViewIndexSearch atIndex:0];
    self.countryIndexTitles = indexTitles;
    
    [self reloadCountries]; // insert the default section
}

/**
 * Resets the object for key ::defaultSectionTitle in ::countries, as well as
 * the first section in ::countrySectionTitles, to reflect ::defaultCountry
 * when it changes (i.e. when defaultLocale changes).
 */
- (void)reloadCountries
{
    if (self.defaultCountry) {
        self.countries[self.defaultSectionTitle] = @[self.defaultCountry];
    } else {
        [self.countries removeObjectForKey:self.defaultSectionTitle];
    }
}

- (void)reloadCountrySectionTitles
{
    if (self.defaultCountry) {
        if (![self.countrySectionTitles containsObject:self.defaultSectionTitle]) {
            [self.countrySectionTitles insertObject:self.defaultSectionTitle atIndex:0];
        }
    } else {
        [self.countrySectionTitles removeObject:self.defaultSectionTitle];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // to ensure proper checkmarks on selected rows
}

#pragma mark - Properties

- (void)setDefaultLocale:(NSLocale *)defaultLocale
{
    _defaultLocale = defaultLocale;
    NBPhoneNumberUtil *util = [NBPhoneNumberUtil sharedInstance];
    
    BOOL defaultSelected = [self.selectedCountry isEqual:self.defaultCountry];
    
    NSString *regionCode = [defaultLocale objectForKey:NSLocaleCountryCode];
    NSString *name = [defaultLocale displayNameForKey:NSLocaleCountryCode value:regionCode];
    NSString *callingCode = [NSString stringWithFormat:@"%@", [util getCountryCodeForRegion:regionCode]];
    _defaultCountry = [ESSCountry countryWithRegionCode:regionCode name:name callingCode:callingCode];
    
    if (defaultSelected) {
        self.selectedCountry = self.defaultCountry;
    }
    
    [self reloadCountries];
    [self reloadCountrySectionTitles];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.countrySectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = self.countrySectionTitles[section];
    NSArray *sectionCountries = self.countries[sectionTitle];
    return sectionCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESSCountryChooserCell *cell = [tableView dequeueReusableCellWithIdentifier:kESSCountryChooserReuseIdentifier forIndexPath:indexPath];
    
    ESSCountry *country = [self countryAtIndexPath:indexPath];
    [cell configureForCountry:country];
    
    if ([country isEqual:self.selectedCountry]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedCells addObject:cell];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedCells removeObject:cell];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.countrySectionTitles[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.countryIndexTitles;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCountry = [self countryAtIndexPath:indexPath];
    
    for (UITableViewCell *cell in self.selectedCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [self.selectedCells removeAllObjects];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    if ([self.selectedCountry isEqual:self.defaultCountry]) {
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.delegate countryChooser:self didSelectCountry:self.selectedCountry];
    [self performSelector:@selector(dismissChooser) withObject:nil afterDelay:kESSCountryChooserDefaultDismissDelay];
}

#pragma mark - Actions

- (void)dismissChooser
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelChooser
{
    if ([self.delegate respondsToSelector:@selector(countryChooserDidCancel:)]) {
        [self.delegate countryChooserDidCancel:self];
    }
    [self dismissChooser];
}

#pragma mark - Helpers

- (ESSCountry *)countryAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = self.countrySectionTitles[indexPath.section];
    NSArray *sectionCountries = self.countries[sectionTitle];
    return sectionCountries[indexPath.row];
}

@end
