//
//  EZAudioPlot.m
//  EZAudio
//
//  Created by Syed Haris Ali on 9/2/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "EZAudioPlot.h"

#import "EZAudio.h"

@interface EZAudioPlot () {
    //  BOOL             _hasData;
    //  TPCircularBuffer _historyBuffer;
    
    // Rolling History
    BOOL    _setMaxLength;
    float   *_scrollHistory;
    int     _scrollHistoryIndex;
    UInt32  _scrollHistoryLength;
    BOOL    _changingHistorySize;
    
    
    float blockAverage;
    float blockTotal;
    int blockSize;
    int blockSpacing;
    int virtualScrollHistoryIndex;
    int numSamplesPerPixel;
    float currentY;
    int samplesPerBlock;
    int rollover;
    float maxFrame;
}
@end

@implementation EZAudioPlot
@synthesize backgroundColor = _backgroundColor;
@synthesize color           = _color;
@synthesize gain            = _gain;
@synthesize plotType        = _plotType;
@synthesize shouldFill      = _shouldFill;
@synthesize shouldMirror    = _shouldMirror;
@synthesize plotSpeed       = _plotSpeed;
@synthesize progress        = _progress;
@synthesize progressColor   = _progressColor;
@synthesize oneWay          = _oneWay;

#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self){
        [self initPlot];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initPlot];
    }
    return self;
}

#if TARGET_OS_IPHONE
-(id)initWithFrame:(CGRect)frameRect {
#elif TARGET_OS_MAC
    -(id)initWithFrame:(NSRect)frameRect {
#endif
        self = [super initWithFrame:frameRect];
        if(self){
            [self initPlot];
        }
        return self;
    }
    
    -(void)initPlot {
#if TARGET_OS_IPHONE
        self.backgroundColor = [UIColor blackColor];
        self.color           = [UIColor colorWithHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
#elif TARGET_OS_MAC
        self.backgroundColor = [NSColor blackColor];
        self.color           = [NSColor colorWithCalibratedHue:0 saturation:1.0 brightness:1.0 alpha:1.0];
#endif
        self.gain            = 1.0;
        self.plotType        = EZPlotTypeRolling;
        self.shouldMirror    = NO;
        self.shouldFill      = NO;
        plotData             = NULL;
        _scrollHistory       = NULL;
        _plotSpeed           = 1;
        _scrollHistoryLength = 1024;
        blockTotal           = 0;
        blockSize           =  2;
        blockSpacing         = 1;
        numSamplesPerPixel   = 0;
        maxFrame             = 10;
        rollover = 0;
        virtualScrollHistoryIndex = 0;
    }
    
#pragma mark - Setters
    -(void)setBackgroundColor:(id)backgroundColor {
        _backgroundColor = backgroundColor;
        [self _refreshDisplay];
    }
    
    -(void)setColor:(id)color {
        _color = color;
        [self _refreshDisplay];
    }
    
    -(void)setProgressColor:(UIColor *)progressColor {
        _progressColor = progressColor;
        [self _refreshDisplay];
    }
    
    -(void)setGain:(float)gain {
        _gain = gain;
        [self _refreshDisplay];
    }
    
    -(void)setPlotType:(EZPlotType)plotType {
        _plotType = plotType;
        [self _refreshDisplay];
    }
    
    -(void)setShouldFill:(BOOL)shouldFill {
        _shouldFill = shouldFill;
        [self _refreshDisplay];
    }
    
    -(void)setPlotSpeed:(int)plotSpeed {
        _plotSpeed = plotSpeed;
    }
    
    -(void)setShouldMirror:(BOOL)shouldMirror {
        _shouldMirror = shouldMirror;
        [self _refreshDisplay];
    }
    
    -(void)setProgress:(float)progress {
        _progress = progress;
        [self _refreshDisplay];
    }
    
    -(void)_refreshDisplay {
#if TARGET_OS_IPHONE
        [self setNeedsDisplay];
#elif TARGET_OS_MAC
        [self setNeedsDisplay:YES];
#endif
    }
    
#pragma mark - Get Data
    
    - (void)normalizeData:(float *)data length:(int)length {
        for (int i=0; i<length; i++) {
            if (data[i] > 1) {
                data[i] = .9f / _gain;
            }
        }
    }
    
    -(void)generateWaveform:(float *)data
length:(int)length {
    int numBlocks = ceil(self.frame.size.width / (blockSize+blockSpacing));
    samplesPerBlock = floor(length / numBlocks);
    NSLog(@"samp %d", samplesPerBlock);
    float sizeAndSpacing = (float)blockSize+(float)blockSpacing;
    float size = (float)blockSize;
    float sampleProportion = size / sizeAndSpacing;
    int blockPortion = floorf(samplesPerBlock*sampleProportion);
    blockTotal = 0;
    [self setRollingHistoryLength:length];
    
    for (int i=0; i<length; i++) {
        blockTotal += data[i];
        if (i % samplesPerBlock == 0) {
            blockAverage = blockTotal / samplesPerBlock;
            for (int j=0; j<samplesPerBlock; j++) {
                if (j < blockPortion) {
                    data[i+j - (blockSize+blockSpacing)] = blockAverage;
                } else {
                    data[i+j - (blockSize+blockSpacing)] = -0.001;
                }
            }
            blockTotal = 0;
        }
    }
    
    [self normalizeData:data length:length];
    
    [self setSampleData:data
                 length:length];
}
    
    
    
    -(void)setSampleData:(float *)data
length:(int)length {
    if( plotData != nil ){
        free(plotData);
    }
    
    plotData   = (CGPoint *)calloc(sizeof(CGPoint),length);
    plotLength = length;
    
    for(int i = 0; i < length; i++) {
        data[i]     = i == 0 ? 0 : data[i];
        plotData[i] = CGPointMake(i,data[i] * _gain);
    }
    
    [self _refreshDisplay];
}
    
#pragma mark - Update
    -(void)updateBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize {
        if( _plotType == EZPlotTypeRolling){
            
            // Update the scroll history datasource
            [EZAudio updateScrollHistory:&_scrollHistory
                              withLength:_scrollHistoryLength
                                 atIndex:&_scrollHistoryIndex
                              withBuffer:buffer
                          withBufferSize:bufferSize
                    isResolutionChanging:&_changingHistorySize];
            
            //
            [self setSampleData:_scrollHistory
                         length:(!_setMaxLength?kEZAudioPlotMaxHistoryBufferLength:_scrollHistoryLength)];
            _setMaxLength = YES;
            
        }
        else if (_plotType == EZPlotTypeRollingBlock || _plotType == EZPlotTypeRollingBlockRight) {
            
            int numBlocks = floor(self.frame.size.width / (blockSize+blockSpacing));
            samplesPerBlock = _scrollHistoryLength / numBlocks;
            if (_oneWay) {
                _scrollHistoryIndex = 1024;
            }
            
            for (int i=0; i<samplesPerBlock; i++) {
                [EZAudio updateScrollHistory:&_scrollHistory
                                  withLength:_scrollHistoryLength
                                     atIndex:&_scrollHistoryIndex
                                  withBuffer:buffer
                              withBufferSize:bufferSize
                        isResolutionChanging:&_changingHistorySize];
                
                
                virtualScrollHistoryIndex++;
                
                int numBlocks = floor(self.frame.size.width / (blockSize+blockSpacing));
                samplesPerBlock = _scrollHistoryLength / numBlocks;
                float sizeAndSpacing = (float)blockSize+(float)blockSpacing;
                float size = (float)blockSize;
                float sampleProportion = size / sizeAndSpacing;
                int blockPortion = floorf(samplesPerBlock*sampleProportion);
                
                blockTotal += _scrollHistory[_scrollHistoryIndex-1];
                _scrollHistory[_scrollHistoryIndex-1] = 0;
                if (virtualScrollHistoryIndex % samplesPerBlock == 0) {
                    blockAverage = blockTotal / samplesPerBlock;
                    blockTotal = 0;
                }
                
                if (_scrollHistoryIndex > samplesPerBlock) {
                    if (virtualScrollHistoryIndex % samplesPerBlock < blockPortion) {
                        _scrollHistory[_scrollHistoryIndex-1] = blockAverage;
                    } else {
                        _scrollHistory[_scrollHistoryIndex-1] = -.001;
                    }
                }
            }
            [self setSampleData:_scrollHistory
                         length:(!_setMaxLength?kEZAudioPlotMaxHistoryBufferLength:_scrollHistoryLength)];
            _setMaxLength = YES;
            
        }
        
        else if( _plotType == EZPlotTypeBuffer ){
            
            [self setSampleData:buffer
                         length:bufferSize];
            
        }
        else {
            
            // Unknown plot type
            
        }
    }
    
#if TARGET_OS_IPHONE
    - (void)drawRect:(CGRect)rect
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGRect frame = self.bounds;
#elif TARGET_OS_MAC
        - (void)drawRect:(NSRect)dirtyRect
        {
            [[NSGraphicsContext currentContext] saveGraphicsState];
            NSGraphicsContext * nsGraphicsContext = [NSGraphicsContext currentContext];
            CGContextRef ctx = (CGContextRef) [nsGraphicsContext graphicsPort];
            NSRect frame = self.bounds;
#endif
            
#if TARGET_OS_IPHONE
            // Set the background color
            [(UIColor*)self.backgroundColor set];
            UIRectFill(frame);
            // Set the waveform line color
            [(UIColor*)self.color set];
#elif TARGET_OS_MAC
            [(NSColor*)self.backgroundColor set];
            NSRectFill(frame);
            [(NSColor*)self.color set];
#endif
            
            if (_plotType == EZPlotTypeRollingBlock || _plotType == EZPlotTypeRollingBlockRight) {
                
                double halfHeight = floor( frame.size.height / 2.0 );
                int numBlocks = (int)ceil(self.frame.size.width / (blockSize+blockSpacing));
                int currentFrame = 1;
                int curFrame = 1;
                int progressExtent = (int)floor(self.frame.size.width * _progress);
                int drawProgressFraction = -1;
                int samplesToSkip = 0;
                if (_progress) {
                    [(UIColor*)_progressColor set];
                }
                if (_scrollHistoryLength > 0 && plotData) {
                    
                    if (_oneWay) {
                        while (_scrollHistory[curFrame] == 0) {
                            curFrame++;
                        }
                        samplesToSkip = curFrame / samplesPerBlock;
                    }
                    
                    
                    for (int i=samplesToSkip; i<numBlocks; i++) {
                        if (i * (blockSize+blockSpacing) > progressExtent) {
                            [(UIColor*)_color set];
                        }
                        while (plotData[currentFrame].y < 0) {
                            if (currentFrame < (int)_scrollHistoryLength-1)
                                currentFrame++;
                            else break;
                        }
                        float pixelHeight = (float)plotData[currentFrame].y * (float)frame.size.height * 10;
                        if (pixelHeight > self.frame.size.height/2) {
                            float diff = pixelHeight - self.frame.size.height/2;
                            pixelHeight = self.frame.size.height/2 + diff*.3;
                        }
                        CGRect rect = CGRectMake(i * (blockSize+blockSpacing), MIN(halfHeight-(pixelHeight/2), halfHeight-.5), blockSize, MAX(pixelHeight, 1));
                        CGPathRef path = CGPathCreateWithRect(rect, NULL);
                        CGContextAddPath(ctx, path);
                        CGContextDrawPath(ctx, kCGPathFill);
                        CGPathRelease(path);
                        if (drawProgressFraction > 0) {
                            [(UIColor*)_progressColor set];
                            if (drawProgressFraction > blockSize)
                                drawProgressFraction = blockSize;
                            CGRect progRect = CGRectMake(i * (blockSize+blockSpacing), MIN(halfHeight-(pixelHeight/2), halfHeight-.5), drawProgressFraction, MAX(pixelHeight, 1));
                            CGPathRef progPath = CGPathCreateWithRect(progRect, NULL);
                            CGContextAddPath(ctx, progPath);
                            CGContextDrawPath(ctx, kCGPathFill);
                            CGPathRelease(progPath);
                            drawProgressFraction = -1;
                            [(UIColor*)_color set];
                        }
                        int progressDiff = progressExtent - (i * (blockSize + blockSpacing));
                        if (progressDiff <= blockSize+blockSpacing-1 && progressDiff > 0) {
                            drawProgressFraction = progressDiff;
                        }
                        while (plotData[currentFrame].y >= 0) {
                            if (currentFrame < (int)_scrollHistoryLength-1)
                                currentFrame++;
                            else break;
                        }
                    }
                }
            } else {
                if(plotLength > 0) {
                    plotData[plotLength-1] = CGPointMake(plotLength-1,0.0f);
                    
                    CGMutablePathRef halfPath = CGPathCreateMutable();
                    CGPathAddLines(halfPath,
                                   NULL,
                                   plotData,
                                   plotLength);
                    CGMutablePathRef path = CGPathCreateMutable();
                    
                    double xscale = (frame.size.width) / (float)plotLength;
                    double halfHeight = floor( frame.size.height / 2.0 );
                    
                    // iOS drawing origin is flipped by default so make sure we account for that
                    int deviceOriginFlipped = 1;
#if TARGET_OS_IPHONE
                    deviceOriginFlipped = -1;
#elif TARGET_OS_MAC
                    deviceOriginFlipped = 1;
#endif
                    
                    CGAffineTransform xf = CGAffineTransformIdentity;
                    xf = CGAffineTransformTranslate( xf, frame.origin.x , halfHeight + frame.origin.y );
                    xf = CGAffineTransformScale( xf, xscale, deviceOriginFlipped*halfHeight );
                    CGPathAddPath( path, &xf, halfPath );
                    
                    if( self.shouldMirror ){
                        xf = CGAffineTransformIdentity;
                        xf = CGAffineTransformTranslate( xf, frame.origin.x , halfHeight + frame.origin.y);
                        xf = CGAffineTransformScale( xf, xscale, -deviceOriginFlipped*(halfHeight));
                        CGPathAddPath( path, &xf, halfPath );
                    }
                    CGPathRelease( halfPath );
                    
                    // Now, path contains the full waveform path.
                    CGContextAddPath(ctx, path);
                    
                    // Make this color customizable
                    if( self.shouldFill ){
                        CGContextFillPath(ctx);
                    }
                    else {
                        CGContextStrokePath(ctx);
                    }
                    CGPathRelease(path);
                }
            }
            
#if TARGET_OS_IPHONE
            CGContextRestoreGState(ctx);
#elif TARGET_OS_MAC
            [[NSGraphicsContext currentContext] restoreGraphicsState];
#endif
        }
        
#pragma mark - Adjust Resolution
        -(int)setRollingHistoryLength:(int)historyLength {
            historyLength = MIN(historyLength,kEZAudioPlotMaxHistoryBufferLength);
            size_t floatByteSize = sizeof(float);
            _changingHistorySize = YES;
            if( _scrollHistoryLength != historyLength ){
                _scrollHistoryLength = historyLength;
            }
            _scrollHistory = realloc(_scrollHistory,_scrollHistoryLength*floatByteSize);
            if( _scrollHistoryIndex < _scrollHistoryLength ){
                memset(&_scrollHistory[_scrollHistoryIndex],
                       0,
                       (_scrollHistoryLength-_scrollHistoryIndex)*floatByteSize);
            }
            else {
                _scrollHistoryIndex = _scrollHistoryLength;
            }
            _changingHistorySize = NO;
            return historyLength;
        }
        
        -(int)rollingHistoryLength {
            return _scrollHistoryLength;
        }
        
        -(void)dealloc {
            if( plotData ){
                free(plotData);
            }
        }
        
        @end
