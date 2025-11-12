//
//  PinData.swift
//  Reach
//
//  Created by xCode on 9/10/25.
//

import Foundation
import MapKit

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
struct PinData: Identifiable, Codable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let residenceType: ResidenceType
    let answerStatus: AnswerStatus
    let responseType: ResponseType
    let timestamp: Date
    let notes: String?
    
    // MARK: - Computed Properties
    
    /// Returns the coordinate as a CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Initializers
    
    init(coordinate: CLLocationCoordinate2D, residenceType: ResidenceType, answerStatus: AnswerStatus, responseType: ResponseType, notes: String? = nil) {
        self.id = UUID()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.residenceType = residenceType
        self.answerStatus = answerStatus
        self.responseType = responseType
        self.timestamp = Date()
        self.notes = notes
    }
    
    // MARK: - Codable
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.residenceType = try container.decode(ResidenceType.self, forKey: .residenceType)
        self.answerStatus = try container.decode(AnswerStatus.self, forKey: .answerStatus)
        self.responseType = try container.decode(ResponseType.self, forKey: .responseType)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(residenceType, forKey: .residenceType)
        try container.encode(answerStatus, forKey: .answerStatus)
        try container.encode(responseType, forKey: .responseType)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude, residenceType, answerStatus, responseType, timestamp, notes
    }
}

