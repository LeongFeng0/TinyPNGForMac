//
//  DragDropImageView.m
//  TinyPngForMac
//
//  Created by liangfeng on 2018/9/17.
//  Copyright © 2018年 liangfeng. All rights reserved.
//

#import "DragDropImageView.h"

@implementation DragDropImageView
@synthesize delegate = _delegate;
-(void)dealloc {
    [self setDelegate: nil];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithFrame:(NSRect) frame
{
    self = [super initWithFrame: frame];
    if (self) {
        //这里我们只添加对文件进行监听，如果拖动其他数据类型到view中是不会被接受的
        self.image = [NSImage imageNamed:@"BG"];
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    
    return self;
}
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([NSImage canInitWithPasteboard:pboard]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}
/***
 第三步：当在view中松开鼠标键时会触发以下函数，我们可以在这个函数里面处理接受到的数据
 ***/
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    // 1）、获取拖动数据中的粘贴板
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // 2）、从粘贴板中提取我们想要的NSFilenamesPboardType数据，这里获取到的是一个文件链接的数组，里面保存的是所有拖动进来的文件地址，如果你只想处理一个文件，那么只需要从数组中提取一个路径就可以了。
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    // 3）、将接受到的文件链接数组通过代理传送
    if(self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewFileList:)])
        [self.delegate dragDropViewFileList:list];
    return YES;
}
@end
