//
//  TrendingCard.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import SwiftUI

struct TrendingCard: View {
    let place: FSQPlace

    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 140, height: 140)
                .cornerRadius(15)
                .overlay(
                    Text(String(place.name.prefix(1)))
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )

            Text(place.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)

            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption2)
                Text("4.8")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 140)
    }
}
