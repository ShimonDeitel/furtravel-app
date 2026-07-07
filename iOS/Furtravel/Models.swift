import Foundation

struct FurtravelEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var destination: String
    var notes: String
}
