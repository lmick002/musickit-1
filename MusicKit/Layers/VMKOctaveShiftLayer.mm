//  Copyright (c) 2015 Venture Media Labs. All rights reserved.

#import "VMKGeometry.h"
#import "VMKImageStore.h"
#import "VMKOctaveShiftLayer.h"

#import <CoreText/CoreText.h>

#include <mxml/dom/OctaveShift.h>

static const CGFloat kLineWidth = 1;

using namespace mxml;


@implementation VMKOctaveShiftLayer

- (instancetype)initWithSpanDirectionGeometry:(const SpanDirectionGeometry*)wedgeGeom {
    return [super initWithGeometry:wedgeGeom];
}

- (const SpanDirectionGeometry*)spanDirectionGeometry {
    return static_cast<const SpanDirectionGeometry*>(self.geometry);
}

- (void)setSpanDirectionGeometry:(const SpanDirectionGeometry*)spanDirectionGeometry {
    self.geometry = spanDirectionGeometry;
}

- (void)setForegroundColor:(CGColorRef)foregroundColor {
    [super setForegroundColor:foregroundColor];
    [self setNeedsDisplay];
}

- (void)setGeometry:(const Geometry *)geometry {
    [super setGeometry:geometry];
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx {
    const CGFloat lineWidth = SpanDirectionGeometry::kLineWidth;

    CGContextSetStrokeColorWithColor(ctx, self.foregroundColor);
    CGContextSetLineWidth(ctx, lineWidth);

    const SpanDirectionGeometry* geom = self.spanDirectionGeometry;

    CGFloat width = geom->stopLocation().x - geom->startLocation().x;

    
    CTFontRef font = CTFontCreateWithName(CFSTR("Baskerville-Italic"), 22.0, NULL);
    NSDictionary* attribs = @{ (id)kCTFontAttributeName: (__bridge id)font };
    NSMutableAttributedString* stringToDraw = [[NSMutableAttributedString alloc] initWithString:@"8va" attributes:attribs];
    [stringToDraw addAttribute:(id)kCTSuperscriptAttributeName value:@1 range:NSMakeRange(1, 2) ];

    // Flip the context coordinates, in iOS only.
#if TARGET_OS_IPHONE
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
#endif

    // draw
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextSetTextPosition(ctx, 0, 0);
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)stringToDraw);
    CGRect bounds = CTLineGetImageBounds(line, ctx);
    CTLineDraw(line, ctx);

    // clean up
    CFRelease(line);
    CFRelease(font);

    CGContextMoveToPoint(ctx, CGRectGetMaxX(bounds) + 2, CGRectGetMidY(bounds) - kLineWidth/2);
    CGContextAddLineToPoint(ctx, width - lineWidth/2, CGRectGetMidY(bounds) - kLineWidth/2);
    CGContextAddLineToPoint(ctx, width - lineWidth/2, CGRectGetMinY(bounds));
    CGContextStrokePath(ctx);
}

@end
