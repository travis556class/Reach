//
//  PinData.swift
//  Reach
//
//  Updated with SwiftData support
//

import Foundation
import MapKit
import SwiftData

// MARK: - Enums

/// Represents the type of residence for outreach
enum ResidenceType: String, CaseIterable, Codable {
    case house = "House"
    case apartment = "Apartment"
    case hotel = "Hotel Housing"
    case duplex = "Duplex"
    case other = "Other"
}

/// Represents whether the residence was answered
enum AnswerStatus: String, CaseIterable, Codable {
    case answered = "Answer"
    case noAnswer = "No Answer"
}

/// Represents the response type when answered
enum ResponseType: String, CaseIterable, Codable {
    case positive = "Positive Response"
    case negative = "Negative Response"
}

// MARK: - Pin Data Model

/// Model representing a pin dropped on the map with outreach data
@Model
final class PinData {
    @Attribute(.unique) var id: UUID
    var latitude: Double
    var longitude: Double
    var residenceTypeRaw: String
    var answerStatusRaw: String
    var responseTypeRaw: String
    var timestamp: Date
    var notes: String?
    
    // MARK: - Computed Properties
    
    /// Returns the coordinate as a CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var residenceType: ResidenceType {
        get { ResidenceType(rawValue: residenceTypeRaw) ?? .other }
        set { residenceTypeRaw = newValue.rawValue }
    }
    
    var answerStatus: AnswerStatus {
        get { AnswerStatus(rawValue: answerStatusRaw) ?? .noAnswer }
        set { answerStatusRaw = newValue.rawValue }
    }
    
    var responseType: ResponseType {
        get { ResponseType(rawValue: responseTypeRaw) ?? .positive }
        set { responseTypeRaw = newValue.rawValue }
    }
    
    // MARK: - Initializers
    
    init(coordinate: CLLocationCoordinate2D, residenceType: ResidenceType, answerStatus: AnswerStatus, responseType: ResponseType, notes: String? = nil) {
        self.id = UUID()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.residenceTypeRaw = residenceType.rawValue
        self.answerStatusRaw = answerStatus.rawValue
        self.responseTypeRaw = responseType.rawValue
        self.timestamp = Date()
        self.notes = notes
    }
}

// MARK: - Identifiable Conformance
extension PinData: Identifiable {
    // SwiftData models are automatically Identifiable through their id property
}
