//
//  GameBoard.swift
//  BioBattle
//
//  Created by Justin Hold on 12/22/22.
//

import SwiftUI

class GameBoard: ObservableObject {
	let rowCount = 11
	let columnCount = 22
	@Published var grid = [[Bacteria]]()
	@Published var currentPlayer = Color.green
	@Published var greenScore = 1
	@Published var redScore = 1
	@Published var winner: String? = nil
	private var bacteriaBeingInfected = 0
	init() {
		reset()
	}
	func reset() {
		winner = nil
		currentPlayer = .green
		greenScore = 1
		redScore = 1
		grid.removeAll()
		for row in 0..<rowCount {
			var newRow = [Bacteria]()
			for column in 0..<columnCount {
				let bacteria = Bacteria(row: row, column: column)
				if row <= rowCount / 2 {
					if row == 0 && column == 0 {
						bacteria.direction = .north
					} else if row == 0 && column == 1 {
						bacteria.direction = .east
					} else if row == 1 && column == 0 {
						bacteria.direction = .south
					} else {
						bacteria.direction = Bacteria.Direction.allCases.randomElement()!
					}
				} else {
					if let counterpart = getBacteria(atRow: rowCount - 1 - row, column: columnCount - 1 - column) {
						bacteria.direction = counterpart.direction.opposite
					}
				}
				newRow.append(bacteria)
			}
			grid.append(newRow)
		}
		grid[0][0].color = .green
		grid[rowCount - 1][columnCount - 1].color = .red
	}
	func getBacteria(atRow row: Int, column: Int) -> Bacteria? {
		guard row >= 0 else { return nil }
		guard row < grid.count else { return nil }
		guard column >= 0 else { return nil }
		guard column < grid[0].count else { return nil }
		return grid[row][column]
	}
	func infect(from: Bacteria) {
		objectWillChange.send()
		var bacteriaToInfect = [Bacteria?]()
		// MARK: DIRECT INFECTION
		switch from.direction {
		case .north:
			bacteriaToInfect.append(getBacteria(atRow: from.row - 1, column: from.column))
		case .south:
			bacteriaToInfect.append(getBacteria(atRow: from.row + 1, column: from.column))
		case .east:
			bacteriaToInfect.append(getBacteria(atRow: from.row, column: from.column + 1))
		case .west:
			bacteriaToInfect.append(getBacteria(atRow: from.row, column: from.column - 1))
		}
		// MARK: INDIRECT INFECTION
		// indirect infection from above
		if let indirect = getBacteria(atRow: from.row - 1, column: from.column) {
			if indirect.direction == .south {
				bacteriaToInfect.append(indirect)
			}
		}
		// indirect infection from below
		if let indirect = getBacteria(atRow: from.row + 1, column: from.column) {
			if indirect.direction == .north {
				bacteriaToInfect.append(indirect)
			}
		}
		// indirect infection from left
		if let indirect = getBacteria(atRow: from.row, column: from.column - 1) {
			if indirect.direction == .east {
				bacteriaToInfect.append(indirect)
			}
		}
		// indirect infection from right
		if let indirect = getBacteria(atRow: from.row, column: from.column + 1) {
			if indirect.direction == .west {
				bacteriaToInfect.append(indirect)
			}
		}
		for case let bacteria? in bacteriaToInfect {
			if bacteria.color != from.color {
				bacteria.color = from.color
				bacteriaBeingInfected += 1
				Task { @MainActor in
					try await Task.sleep(for: .milliseconds(50))
					bacteriaBeingInfected -= 1
					infect(from: bacteria)
				}
			}
		}
		updateScores()
	}
	func rotate(bacteria: Bacteria) {
		guard bacteria.color == currentPlayer else { return }
		guard bacteriaBeingInfected == 0 else { return }
		guard winner == nil else { return }
		objectWillChange.send()
		bacteria.direction = bacteria.direction.next
		infect(from: bacteria)
	}
	func changePlayer() {
		if currentPlayer == .green {
			currentPlayer = .red
		} else {
			currentPlayer = .green
		}
	}
	func updateScores() {
		var newGreenScore = 0
		var newRedScore = 0
		for row in grid {
			for bacteria in row {
				if bacteria.color == .green {
					newGreenScore += 1
				} else if bacteria.color == .red {
					newRedScore += 1
				}
			}
		}
		greenScore = newGreenScore
		redScore = newRedScore
		if bacteriaBeingInfected == 0 {
			withAnimation(.spring()) {
				if redScore == 0 {
					winner = "Green"
				} else if greenScore == 0 {
					winner = "Red"
				} else {
					changePlayer()
				}
			}
		}
	}
}
