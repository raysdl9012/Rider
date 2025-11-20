//
//  DestinationSearchResultRow.swift
//  RideFuture
//
//  Created by Reinner Steven Daza Leiva on 18/11/25.
//

import SwiftUI
import MapKit

struct DestinationSearchResultCard: View {
    let completion: MKLocalSearchCompletion
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(alignment: .center, spacing: 12) {

                // Leading icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 42, height: 42)

                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(completion.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    if !completion.subtitle.isEmpty {
                        Text(completion.subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.07), radius: 5, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    DestinationSearchResultCard(completion: MKLocalSearchCompletion()) {
        
    }
}
