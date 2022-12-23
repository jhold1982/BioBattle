//
//  ContentView.swift
//  BioBattle
//
//  Created by Justin Hold on 12/22/22.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var board = GameBoard()
	var body: some View {
		VStack {
			HStack {
				Text("GREEN: \(board.greenScore)")
					.padding(.horizontal)
					.background(Capsule().fill(.green).opacity(board.currentPlayer == .green ? 1 : 0))
				Spacer()
				Text("BIOBATTLE")
				Spacer()
				Text("RED: \(board.redScore)")
					.padding(.horizontal)
					.background(Capsule().fill(.red).opacity(board.currentPlayer == .red ? 1 : 0))
			}
			.padding()
			.font(.system(size: 36).weight(.black))
			ZStack {
				VStack {
					ForEach(0..<11, id: \.self) { row in
						HStack {
							ForEach(0..<22, id: \.self) { column in
								let bacteria = board.grid[row][column]
								BacteriaView(bacteria: bacteria) {
									board.rotate(bacteria: bacteria)
								}
							}
						}
					}
				}
				if let winner = board.winner {
					VStack {
						Text("\(winner) wins!")
							.font(.largeTitle)
						Button(action: board.reset) {
							Text("Play Again")
								.padding()
								.background(.blue)
								.clipShape(Capsule())
						}
						.buttonStyle(.plain)
					}
					.padding(40)
					.background(.black.opacity(0.85))
					.cornerRadius(25)
					.transition(.scale)
				}
			}
		}
		.padding()
		.fixedSize()
		.preferredColorScheme(.dark)
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
