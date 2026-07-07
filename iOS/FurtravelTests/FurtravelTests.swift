import XCTest
@testable import Furtravel

@MainActor
final class FurtravelTests: XCTestCase {
    func makeIsolatedStore() -> FurtravelStore {
        // Each store instance persists to the same app-support file; tests rely on
        // starting from seeded state and only asserting relative deltas.
        FurtravelStore()
    }

    func testSeedDataLoadsBelowFreeLimit() {
        let store = makeIsolatedStore()
        XCTAssertFalse(store.entries.isEmpty)
        XCTAssertLessThan(store.entries.count, FurtravelStore.freeEntryLimit)
    }

    func testAddEntrySucceedsUnderLimit() {
        let store = makeIsolatedStore()
        let before = store.entries.count
        let added = store.addEntry(date: Date(), destination: "Test value", notes: "Test note", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddEntryRespectsFreeLimit() {
        let store = makeIsolatedStore()
        for _ in 0..<(FurtravelStore.freeEntryLimit + 5) {
            _ = store.addEntry(date: Date(), destination: "Filler", notes: "Filler", isPro: false)
        }
        XCTAssertEqual(store.entries.count, FurtravelStore.freeEntryLimit)
        XCTAssertFalse(store.canAddEntry(isPro: false))
    }

    func testProBypassesFreeLimit() {
        let store = makeIsolatedStore()
        for _ in 0..<(FurtravelStore.freeEntryLimit + 5) {
            _ = store.addEntry(date: Date(), destination: "Filler", notes: "Filler", isPro: true)
        }
        XCTAssertGreaterThan(store.entries.count, FurtravelStore.freeEntryLimit)
    }

    func testDeleteEntryRemovesIt() {
        let store = makeIsolatedStore()
        _ = store.addEntry(date: Date(), destination: "Delete me", notes: "note", isPro: false)
        guard let entry = store.entries.first else { return XCTFail("expected entry") }
        let before = store.entries.count
        store.deleteEntry(entry.id)
        XCTAssertEqual(store.entries.count, before - 1)
    }

    func testUpdateEntryChangesFields() {
        let store = makeIsolatedStore()
        _ = store.addEntry(date: Date(), destination: "Original", notes: "note", isPro: false)
        guard let entry = store.entries.first(where: { _ in true }) else { return XCTFail("expected entry") }
        store.updateEntry(entry.id, date: entry.date, destination: "Updated", notes: entry.notes)
        XCTAssertTrue(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testDeleteAllDataReseeds() {
        let store = makeIsolatedStore()
        store.deleteAllData()
        XCTAssertFalse(store.entries.isEmpty)
    }

    func testEntriesSortedByDateDescending() {
        let store = makeIsolatedStore()
        let older = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let newer = Date()
        _ = store.addEntry(date: older, destination: "Old", notes: "note", isPro: false)
        _ = store.addEntry(date: newer, destination: "New", notes: "note", isPro: false)
        XCTAssertEqual(store.entries.first?.date, store.entries.map(\.date).max())
    }
}
