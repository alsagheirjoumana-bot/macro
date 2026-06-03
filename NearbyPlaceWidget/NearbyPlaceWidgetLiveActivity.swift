//
//  NearbyPlaceWidgetLiveActivity.swift
//  NearbyPlaceWidget
//
//  Created by May Alqunaytir on 02/06/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NearbyPlaceWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NearbyPlaceWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NearbyPlaceWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension NearbyPlaceWidgetAttributes {
    fileprivate static var preview: NearbyPlaceWidgetAttributes {
        NearbyPlaceWidgetAttributes(name: "World")
    }
}

extension NearbyPlaceWidgetAttributes.ContentState {
    fileprivate static var smiley: NearbyPlaceWidgetAttributes.ContentState {
        NearbyPlaceWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NearbyPlaceWidgetAttributes.ContentState {
         NearbyPlaceWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NearbyPlaceWidgetAttributes.preview) {
   NearbyPlaceWidgetLiveActivity()
} contentStates: {
    NearbyPlaceWidgetAttributes.ContentState.smiley
    NearbyPlaceWidgetAttributes.ContentState.starEyes
}
