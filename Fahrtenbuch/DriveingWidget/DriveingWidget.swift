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
            Text("Aktuelle Fahrt:")
                .font(.headline)
            
            HStack (alignment: .center) {
                Image(systemName: "car.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                Text(context.attributes.vehicleName)
                    .font(.system(size: 14))
                Image(systemName: "timer.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                Text(context.state.startTime, style: .relative)
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
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
