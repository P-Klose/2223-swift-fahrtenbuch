//
//  DriveingWidget.swift
//  DriveingWidget
//
//  Created by Peter Klose on 16.05.23.
//

import ActivityKit
import WidgetKit
import SwiftUI



struct DriveingWidgetView : View {
    let context: ActivityViewContext<DriveAttributes>
    
    
    var body: some View {
        VStack {
            Text(context.attributes.vehicleName)
                .font(.headline)
            Text(context.state.startTime, style: .relative)
        }
        .padding(.horizontal)
    }
}

struct DriveingWidget: Widget {
    let kind: String = "DriveingWidget"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DriveAttributes.self) { context in
            DriveingWidgetView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("MAIN")
                }
            } compactLeading: {
                Text("CL")
            } compactTrailing: {
                Text("CT")
            } minimal: {
                Text("Minimal")
            }

        }
    


    }
}

//struct DriveingWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        DriveingWidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
