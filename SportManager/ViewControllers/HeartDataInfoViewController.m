//
//  HeartDataInfoViewController.m
//  SportManager
//
//  Created by Darya on 01/05/16.
//  Copyright © 2016 Darya Mochalova. All rights reserved.
//

#import "HeartDataInfoViewController.h"
#import "CorePlot.h"

@interface HeartDataInfoViewController () <CPTPlotSpaceDelegate, CPTPlotDataSource>

@property (weak, nonatomic) IBOutlet UIView *chartContainerView;
@property (nonatomic, assign) CGFloat titleSize;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *beatsData;

@end

@implementation HeartDataInfoViewController

- (void)loadView
{
    [super loadView];
    self.titleSize = 0.0;
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.chartContainerView.bounds];

    [self.chartContainerView addSubview:hostingView];
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.chartContainerView.bounds];
    hostingView.hostedGraph = graph;
    
    graph.plotAreaFrame.masksToBorder  = NO;
    
    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.25;
    majorGridLineStyle.lineColor = [CPTColor colorWithCGColor:[[UIColor colorWithRed:0.89 green:0.73 blue:0.79 alpha:1.00] CGColor]];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.75;
    minorGridLineStyle.lineColor = [[CPTColor colorWithCGColor:[[UIColor colorWithRed:0.89 green:0.73 blue:0.79 alpha:1.00] CGColor]] colorWithAlphaComponent:CPTFloat(0.8)];
    
    CPTLineCap *lineCap = [CPTLineCap sweptArrowPlotLineCap];
    lineCap.size = CGSizeMake( self.titleSize * CPTFloat(0.625), self.titleSize * CPTFloat(0.625) );
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.positiveFormat = @"0s";
    formatter.multiplier = @(0.001);
    
    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @1000;
    x.minorTicksPerInterval = 9;
    x.preferredNumberOfMajorTicks = 10;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.5];
    x.labelFormatter = formatter;
    
    lineCap.lineStyle = x.axisLineStyle;
    CPTColor *lineColor = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    x.axisLineCapMax = lineCap;
    
//    x.title       = @"X Axis";
    x.titleOffset = self.titleSize * CPTFloat(1.25);
    
    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    y.majorIntervalLength         = @1;
    y.minorTicksPerInterval       = 9;
    y.preferredNumberOfMajorTicks = 10;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelOffset                 = self.titleSize * CPTFloat(0.25);
    y.alternatingBandFills        = @[[[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)], [NSNull null]];
    y.alternatingBandAnchor       = @0.0;
    y.labelOffset                 = 20;
    
    lineCap.lineStyle = y.axisLineStyle;
    lineColor         = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    y.axisLineCapMax = lineCap;
    y.axisLineCapMin = lineCap;
    
//    y.title       = @"Y Axis";
    y.titleOffset = self.titleSize * CPTFloat(1.25);
    
    // Set axes
    graph.axisSet.axes = @[x, y];
    
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"ident";
    
    // Make the data source line use curved interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationLinear;
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor blackColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    // Auto scale the plot space to fit the plot data
    [plotSpace scaleToFitPlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    
    // Expand the ranges to put some space around the plot
    [xRange expandRangeByFactor:@1.0];
    [yRange expandRangeByFactor:@3.0];
    xRange.location = plotSpace.xRange.location;
    yRange.location = plotSpace.yRange.location;
    x.visibleAxisRange = xRange;
    y.visibleAxisRange = yRange;
    y.visibleRange = yRange;
    x.visibleRange = xRange;
    
    [yRange expandRangeByFactor:@1.2];
    plotSpace.globalXRange = xRange;
    plotSpace.globalYRange = yRange;
    plotSpace.xRange = [[CPTPlotRange alloc] initWithLocation:@0 length:@10000];
    plotSpace.yRange = yRange;
    
//    // Add plot symbols
//    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
//    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
//    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:0.5]];
//    plotSymbol.lineStyle          = symbolLineStyle;
//    plotSymbol.size               = CGSizeMake(10.0, 10.0);
//    dataSourceLinePlot.plotSymbol = plotSymbol;
    
    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self;
    
//    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;
    
}

- (void)setHeartData:(NSArray<DMHeartData *> *)heartData
{
    _heartData = heartData;
    self.beatsData = [[NSMutableArray alloc] init];
    double peakTime = 0;
    double width = 50;
    for (DMHeartData *heart in heartData) {
        [self.beatsData addObject:@(peakTime - width)];
        [self.beatsData addObject:@(peakTime)];
        [self.beatsData addObject:@(peakTime + width)];
        peakTime += 60000/heart.heartRate;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.beatsData.count - 1;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *data = self.beatsData[index];
    if(fieldEnum == CPTScatterPlotFieldY)
    {
        if (fmod (index - 1, 3)) {
            return @(0);
        }
        else{
            return @(1);
        }
//        return @(100);
    }
    else{
        return data;
    }
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(nullable CPTPlotRange *)plotSpace:(nonnull CPTPlotSpace *)space willChangePlotRangeTo:(nonnull CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTGraph *theGraph    = space.graph;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)theGraph.axisSet;
    
    CPTMutablePlotRange *changedRange = [newRange mutableCopy];
    
    switch ( coordinate ) {
        case CPTCoordinateX:
            [changedRange expandRangeByFactor:@1.0];
            changedRange.location          = newRange.location;
            axisSet.xAxis.visibleAxisRange = changedRange;
            break;
            
        case CPTCoordinateY:
            return [axisSet.yAxis visibleAxisRange];
            break;
            
        default:
            break;
    }
    
    return newRange;
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    if (fmod (idx - 1, 3) == 0.0 && idx > 0) {
        int index = (idx - 1) / 3.0;
        double rrInterval = 60000/[self.heartData[index] heartRate];
        CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.0lf",rrInterval]];
        return label;
    }
    return nil;
}

#pragma mark -
#pragma mark CPTScatterPlot delegate methods




@end
