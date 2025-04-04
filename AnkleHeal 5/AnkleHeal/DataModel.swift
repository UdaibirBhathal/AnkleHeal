//
//  DataModel.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 13/03/25.
//

import SwiftUI
import Foundation
import Combine
import AVFoundation

// MARK: - Enums and Supporting Structures

enum Gender: String, Codable {
    case male, female, other
}

/// Types of ankle injuries supported in the app
enum Injury: Codable {
    case grade1  // Mild ankle sprain
    case grade2  // Moderate ankle sprain
    case grade3  // Severe ankle sprain
    case ligamentTear  // Torn ligament
    case inversion  // Inversion ankle injury
    case other(description: String)  // Other injury types
}

/// Location structure for geographical positioning
struct Location: Codable {
    var latitude: Double
    var longitude: Double
}

// MARK: - Core Data Models

/// Appointment Model - Represents a scheduled session between patient and physiotherapist
struct Appointment: Codable, Identifiable {
    var id: UUID = UUID()
    var patientID: Int
    var appointmentID: Int
    var date: Date
    var time: String  // E.g., "8:00 AM"
    var physiotherapistID: Int
    var patientName: String
    var diagnosis: String
    var isExpanded: Bool = false  // UI state for expandable appointment cells
    var status: Bool  // true = confirmed, false = cancelled
}

extension Appointment {
    // Create a separate enum for UI/display purposes
    enum AppointmentStatus: String {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case cancelled = "Cancelled"
        
        // Get color for UI
        var color: Color {
            switch self {
            case .pending: return .orange
            case .confirmed: return .green
            case .cancelled: return .red
            }
        }
    }
}

struct RescheduleRequest: Codable, Identifiable {
    var id = UUID()
    var appointmentID: Int
    var patientID: Int
    var originalDate: Date
    var originalTime: String
    var status: RequestStatus = .pending
    // Add new properties to store suggested date and time from physiotherapist
    var suggestedNewDate: Date?
    var suggestedNewTime: String?
    
    enum RequestStatus: String, Codable {
        case pending, accepted, rejected
    }
    
    // Add a coding keys enum to ensure proper encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, appointmentID, patientID, originalDate, originalTime, status
        case suggestedNewDate, suggestedNewTime
    }
}

/// Exercise Model - Represents an exercise that can be assigned to patients
struct Exercise: Codable, Identifiable {
    var id: UUID = UUID()
    var exerciseID: Int
    var name: String
    var duration: Int  // In minutes
    var intensity: Int  // Scale: 1 to 10
    var numberOfSets: Int
    var repsPerSet: Int
    var tutorialURL: String
    var exerciseDetails: String  // Description of the exercise
    var exerciseInstructions: String  // Step-by-step instructions
    var feedbackGiven: Bool = false  // Whether feedback has been provided
}

/// Exercise Feedback Model - Stores patient feedback on exercises
struct ExerciseFeedback: Codable, Identifiable {
    var id = UUID()
    var feedbackID: Int
    var patientID: Int
    var exerciseID: Int
    var patientName: String
    var exerciseName: String
    var date: Date
    var comment: String  // Patient comments about the exercise
    var painLevel: Int  // Scale: 1 to 10
    var completed: Bool  // Whether the exercise was completed
}

/// Patient Model - Represents a patient in the system
struct Patient: Codable, Identifiable {
    var id: Int
    var name: String
    var dob: Date
    var gender: Gender
    var mobile: String
    var email: String
    var height: Int  // In cm
    var weight: Int  // In kg
    var injury: Injury?
    var currentPhysiotherapistID: Int?
    var location: Location
    var locationDescription: String?  // Human-readable location
    var exerciseLogs: [ExerciseLog] = []  // History of exercise performance
    var appointmentHistory: [Appointment] = []  // Past and upcoming appointments
    var exercises: [Exercise] = []  // Assigned exercises
}

struct PatientVideo: Codable, Identifiable {
    var id = UUID()
    var patientID: Int
    var videoURL: URL
    var uploadDate: Date
    var exerciseID: Int?
    var duration: TimeInterval?
    var fileSize: Int64?
}

/// Physiotherapist Model - Represents a physiotherapist in the system
struct Physiotherapist: Codable, Identifiable {
    var id: Int
    var name: String
    var dob: Date
    var mobile: String
    var email: String
    var experience: Int  // In years
    var patients: [Int] = []  // List of Patient IDs assigned to this physiotherapist
    var location: Location
    var locationDescription: String?  // Human-readable location
    var rating: Double?  // Scale: 1.0 to 5.0
    var appointments: [Appointment] = []  // All appointments for this physiotherapist
    var details: String  // Biographical and professional details
}

/// Chat Message Model - Represents a message between users
struct ChatMessage: Codable, Identifiable {
    var id: UUID = UUID()
    var senderID: Int
    var receiverID: Int
    var timestamp: Date
    var message: String
    var isRead: Bool = false
    var senderName: String = ""
    
    // Helper to format timestamp for display
    var formattedTime: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(timestamp) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: timestamp)
        } else if calendar.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
            return formatter.string(from: timestamp)
        }
    }
}

/// Article Model - Represents an educational article
struct Article: Codable, Identifiable {
    var id: UUID = UUID()
    var articleID: Int
    var title: String
    var publicationDate: String
    var author: String
    var imageName: String
    var url: String
    var tags: [String] = []  // Added for better searchability and categorization
    var summary: String = ""  // Brief summary of article content
}

/// Appointment Request Model - Represents a pending appointment request
struct AppointmentRequest: Codable, Identifiable {
    var id: UUID = UUID()
    var patientID: Int                     // ✅ Must be present now
    var patientName: String
    var date: String
    var time: String
    var status: RequestStatus = .pending
    var injury: Injury
    var notes: String = ""
    
    enum RequestStatus: String, Codable {
        case pending, approved, rejected
    }
}

// Enhanced ExerciseLog struct with more detailed information
struct ExerciseLog: Identifiable, Codable {
    let logID: Int
    let exerciseID: Int
    let userID: Int
    let date: Date
    let reps: Int
    let sets: Int
    let painLevel: Int
    var exertionLevel: Int? = nil
    var completed: Bool = true
    var comment: String? = nil
    
    var id: Int { logID }
}
// MARK: - Main Data Model Class

/// AnkleHeal Data Model - Singleton class that manages all app data
class AnkleHealDataModel: ObservableObject {
    /// Shared instance for app-wide access
    static let shared = AnkleHealDataModel()

    // MARK: - Published Properties (Observable)
    
    /// Patients dictionary - keyed by patient ID
    @Published private(set) var patients: [Int: Patient] = [:]
    
    /// Physiotherapists dictionary - keyed by physiotherapist ID
    @Published private(set) var physiotherapists: [Int: Physiotherapist] = [:]
    
    /// Exercise logs dictionary - keyed by user ID
    @Published var exerciseLogs: [Int: [ExerciseLog]] = [:]
    var patientExerciseLogs: [Int: [ExerciseLog]] = [:]
    
    /// Exercise library - all available exercises
    @Published private(set) var exerciseLibrary: [Exercise] = []
    
    /// Exercise feedback collection
    @Published private(set) var exerciseFeedbacks: [ExerciseFeedback] = []
    
    /// Educational articles
    @Published private(set) var articles: [Article] = [
        Article(articleID: 1, title: "Types of Ankle Sprains", publicationDate: "12 Oct 2024", author: "Dr. Ashok Pt", imageName: "Image", url: "https://certifiedfoot.com/healing-after-ankle-sprain-treatment/"),
        Article(articleID: 2, title: "About Ankle Health", publicationDate: "12 Oct 2024", author: "Dr. Devang Pt", imageName: "Image 1", url: "https://www.nhslanarkshire.scot.nhs.uk/services/physiotherapy-msk/ankle-sprain/")
    ]
    
    /// Chat messages
    @Published private(set) var chatMessages: [ChatMessage] = []
    
    /// Appointment requests
    @Published private(set) var appointmentRequests: [AppointmentRequest] = []

    private let appointmentsKey = "saved_appointments"
    
    @Published private(set) var rescheduleRequests: [RescheduleRequest] = []
    
    // Track today's progress metrics for quick access
    @Published var todayProgressMetrics: [Int: (completed: Int, total: Int, painLevel: Double)] = [:]
    
    // MARK: - Initialization
    
    // Add these properties to the class
    private var _patientVideos: [PatientVideo] = []
    
    // Computed property for patient videos
    var patientVideos: [PatientVideo] {
        _patientVideos
    }
    
    /// Private initializer to ensure singleton pattern
    private init() {
        initializeSampleData()
        initializeSampleChatData()
        initializeSampleArticles()
        initializeSampleAppointmentRequests()
        initializeDemoUsers()
        loadExerciseLogs()
    }
    
    /// Save all appointments to UserDefaults
    func saveAppointmentsToStorage() {
        var allAppointments: [Appointment] = []

        // Collect all appointments from physiotherapists
        for physio in physiotherapists.values {
            allAppointments.append(contentsOf: physio.appointments)
        }

        // Save to UserDefaults
        do {
            let encodedData = try JSONEncoder().encode(allAppointments)
            UserDefaults.standard.set(encodedData, forKey: appointmentsKey)
        } catch {
            print("Failed to encode appointments: \(error)")
        }
    }

    /// Load appointments from UserDefaults and sync with physiotherapists and patients
    func loadAppointmentsFromStorage() -> [Appointment] {
        guard let data = UserDefaults.standard.data(forKey: appointmentsKey) else { return [] }
        
        do {
            let decodedAppointments = try JSONDecoder().decode([Appointment].self, from: data)
            
            for appointment in decodedAppointments {
                // Assign to physiotherapist
                physiotherapists[appointment.physiotherapistID]?.appointments.append(appointment)
                
                // Assign to patient
                patients[appointment.patientID]?.appointmentHistory.append(appointment)
            }

            objectWillChange.send()
            
            return decodedAppointments
        } catch {
            print("Failed to decode appointments: \(error)")
        }
        
        return []
    }

    // MARK: - Sample Data Initialization
    
    /// Initialize sample data for demonstration purposes
    private func initializeSampleData() {
        // Sample Exercises
        let exerciseLibrary = [
            Exercise(
                exerciseID: 101,
                name: "Single Leg Balance",
                duration: 5,
                intensity: 4,
                numberOfSets: 2,
                repsPerSet: 1,
                tutorialURL: "https://www.youtube.com/watch?v=example1",
                exerciseDetails: "Improves balance and proprioception. Helps strengthen the muscles around the ankle joint.",
                exerciseInstructions: "Stand on one leg, hold for 30 seconds. Repeat with other leg. Try to maintain balance without touching the other foot down."
            ),
            Exercise(
                exerciseID: 102,
                name: "Heel Stretch",
                duration: 3,
                intensity: 3,
                numberOfSets: 3,
                repsPerSet: 1,
                tutorialURL: "https://www.youtube.com/watch?v=example2",
                exerciseDetails: "Stretches calf muscles and Achilles tendon. Helps improve ankle flexibility.",
                exerciseInstructions: "Stand facing a wall with one leg forward. Keep back leg straight with heel on ground. Lean forward until you feel a stretch in your calf. Hold for 30 seconds."
            ),
            Exercise(
                exerciseID: 103,
                name: "Resistance Band Stretch",
                duration: 5,
                intensity: 5,
                numberOfSets: 3,
                repsPerSet: 10,
                tutorialURL: "https://www.youtube.com/watch?v=example3",
                exerciseDetails: "Strengthens ankle muscles. Improves overall stability and helps prevent future injuries.",
                exerciseInstructions: "Wrap resistance band around foot. Move foot against the band's resistance in all four directions: up, down, in, and out."
            ),
            Exercise(
                exerciseID: 104,
                name: "Golf Ball Roll",
                duration: 5,
                intensity: 2,
                numberOfSets: 1,
                repsPerSet: 1,
                tutorialURL: "https://www.youtube.com/watch?v=example4",
                exerciseDetails: "Relieves foot pain and stretches plantar fascia. Also helps with ankle mobility.",
                exerciseInstructions: "While seated, roll a golf ball under your foot, applying gentle pressure. Continue for 3-5 minutes."
            ),
            Exercise(
                exerciseID: 105,
                name: "Alphabet Exercise",
                duration: 5,
                intensity: 3,
                numberOfSets: 2,
                repsPerSet: 1,
                tutorialURL: "https://www.youtube.com/watch?v=example5",
                exerciseDetails: "Improves range of motion. Helps with ankle flexibility and coordination.",
                exerciseInstructions: "Trace the entire alphabet with your toe, moving only at the ankle. Do all 26 letters without putting your foot down."
            ),
            Exercise(
                exerciseID: 106,
                name: "Heel Raise",
                duration: 3,
                intensity: 4,
                numberOfSets: 3,
                repsPerSet: 15,
                tutorialURL: "https://www.youtube.com/watch?v=example6",
                exerciseDetails: "Strengthens calf muscles. Helps with push-off stability during walking and running.",
                exerciseInstructions: "Stand with feet shoulder-width apart. Rise up onto toes, then lower back down. Do 15 repetitions."
            ),
            Exercise(
                exerciseID: 107,
                name: "Ankle Circles",
                duration: 3,
                intensity: 2,
                numberOfSets: 2,
                repsPerSet: 10,
                tutorialURL: "https://www.youtube.com/watch?v=example7",
                exerciseDetails: "Improves ankle mobility and circulation. Good warm-up exercise.",
                exerciseInstructions: "Lift foot off the ground. Rotate ankle in clockwise circles 10 times, then counter-clockwise 10 times."
            ),
            Exercise(
                exerciseID: 108,
                name: "Balance Board",
                duration: 5,
                intensity: 6,
                numberOfSets: 3,
                repsPerSet: 1,
                tutorialURL: "https://www.youtube.com/watch?v=example8",
                exerciseDetails: "Advanced balance training. Challenges stability and strengthens ankle.",
                exerciseInstructions: "Stand on balance board with feet shoulder-width apart. Try to keep the board level for 30 seconds."
            )
        ]
        
        self.exerciseLibrary = exerciseLibrary
    }
    
    /// Initialize sample articles
    private func initializeSampleArticles() {
        articles = [
            Article(
                articleID: 1,
                title: "Types of Ankle Sprains",
                publicationDate: "12 Oct 2024",
                author: "Dr. Ashok Pt",
                imageName: "Image",
                url: "https://certifiedfoot.com/healing-after-ankle-sprain-treatment/",
                tags: ["ankle", "sprain", "education"],
                summary: "An overview of different types of ankle sprains and their characteristics."
            ),
            Article(
                articleID: 2,
                title: "About Ankle Health",
                publicationDate: "12 Oct 2024",
                author: "Dr. Devang Pt",
                imageName: "Image 1",
                url: "https://www.nhslanarkshire.scot.nhs.uk/services/physiotherapy-msk/ankle-sprain/",
                tags: ["ankle", "health", "prevention"],
                summary: "Guide to maintaining ankle health and preventing injuries."
            ),
            Article(
                articleID: 3,
                title: "Rehabilitation Exercises After Ankle Injury",
                publicationDate: "15 Oct 2024",
                author: "Dr. Sarah Chen",
                imageName: "Image 2",
                url: "https://example.com/rehab-exercises",
                tags: ["exercises", "rehabilitation", "recovery"],
                summary: "Effective exercises for ankle rehabilitation after common injuries."
            )
        ]
    }
    
    /// Initialize sample chat messages
    // Initialize sample chat messages
    private func initializeSampleChatData() {
        // Initialize chat messages if none exist
        if chatMessages.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
            
            // Sample messages between physiotherapist 1 and patient 1
            chatMessages.append(ChatMessage(
                senderID: 1, // Physio ID
                receiverID: 1, // Patient ID
                timestamp: twoDaysAgo.addingTimeInterval(3600 * 10), // Morning
                message: "Hello John, how is your ankle feeling today?",
                isRead: true,
                senderName: "Dr. Sarah Chen"
            ))
            
            chatMessages.append(ChatMessage(
                senderID: 1, // Patient ID
                receiverID: 1, // Physio ID
                timestamp: twoDaysAgo.addingTimeInterval(3600 * 11), // An hour later
                message: "Hi Dr. Chen, it's still a bit stiff in the morning but getting better.",
                isRead: true,
                senderName: "John Doe"
            ))
            
            chatMessages.append(ChatMessage(
                senderID: 1, // Physio ID
                receiverID: 1, // Patient ID
                timestamp: yesterday.addingTimeInterval(3600 * 10), // Yesterday morning
                message: "Remember to do your exercises 3 times a day as we discussed. Are you able to bear weight on it now?",
                isRead: true,
                senderName: "Dr. Sarah Chen"
            ))
            
            chatMessages.append(ChatMessage(
                senderID: 1, // Patient ID
                receiverID: 1, // Physio ID
                timestamp: yesterday.addingTimeInterval(3600 * 14), // Yesterday afternoon
                message: "I did all the exercises today. The resistance band ones are getting easier. Yes, I can put more weight on it now.",
                isRead: true,
                senderName: "John Doe"
            ))
            
            chatMessages.append(ChatMessage(
                senderID: 1, // Physio ID
                receiverID: 1, // Patient ID
                timestamp: today.addingTimeInterval(-3600), // 1 hour ago
                message: "Great progress, John! Looking forward to seeing you at your appointment tomorrow. Please bring your supportive shoes.",
                isRead: false,
                senderName: "Dr. Sarah Chen"
            ))
            
            // Sample messages between physiotherapist 2 and patient 2
            chatMessages.append(ChatMessage(
                senderID: 2, // Physio ID
                receiverID: 2, // Patient ID
                timestamp: twoDaysAgo.addingTimeInterval(3600 * 13), // 2 days ago afternoon
                message: "Hi Jane, just checking in on your ankle. How's your pain level today?",
                isRead: true,
                senderName: "Dr. Michael Brown"
            ))
            
            chatMessages.append(ChatMessage(
                senderID: 2, // Patient ID
                receiverID: 2, // Physio ID
                timestamp: twoDaysAgo.addingTimeInterval(3600 * 15), // 2 hours later
                message: "Hello Dr. Brown. It's around 3/10 today. Better than yesterday. I've been icing regularly.",
                isRead: true,
                senderName: "Jane Smith"
            ))
            
            chatMessages.append(ChatMessage(
                senderID: 2, // Physio ID
                receiverID: 2, // Patient ID
                timestamp: yesterday.addingTimeInterval(3600 * 9), // Yesterday morning
                message: "That's good progress. Have you been able to do the heel raises I showed you?",
                isRead: false,
                senderName: "Dr. Michael Brown"
            ))
        }
    }
    
    /// Initialize sample appointment requests
    private func initializeSampleAppointmentRequests() {
        if appointmentRequests.isEmpty {
            // Create date formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            
            // Create dates for the next few days
            let calendar = Calendar.current
            let today = Date()
            
            // Create dates for the next few days
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            let twoDaysLater = calendar.date(byAdding: .day, value: 2, to: today)!
            let threeDaysLater = calendar.date(byAdding: .day, value: 3, to: today)!
            let fourDaysLater = calendar.date(byAdding: .day, value: 4, to: today)!
            
            // Format the dates
            let tomorrowStr = dateFormatter.string(from: tomorrow)
            let twoDaysLaterStr = dateFormatter.string(from: twoDaysLater)
            let threeDaysLaterStr = dateFormatter.string(from: threeDaysLater)
            let fourDaysLaterStr = dateFormatter.string(from: fourDaysLater)
            
            // Create appointment requests
//            appointmentRequests = [
//                AppointmentRequest(patientName: "Alex Taylor", date: tomorrowStr, time: "9:30 AM"),
//                AppointmentRequest(patientName: "Jamie Wilson", date: tomorrowStr, time: "2:00 PM"),
//                AppointmentRequest(patientName: "Sam Reynolds", date: twoDaysLaterStr, time: "10:00 AM"),
//                AppointmentRequest(patientName: "Morgan Davis", date: threeDaysLaterStr, time: "11:30 AM"),
//                AppointmentRequest(patientName: "Casey Johnson", date: fourDaysLaterStr, time: "3:30 PM")
//            ]
        }
    }
    
    /// Initialize demo users for testing
    func initializeDemoUsers() {
        // Check if we already have the demo users
        if !physiotherapists.isEmpty && !patients.isEmpty {
            return
        }
        
        // Create demo physiotherapists if they don't exist
        if physiotherapists[1] == nil {
            let physio1 = Physiotherapist(
                id: 1,
                name: "Dr. Sarah Chen",
                dob: Calendar.current.date(from: DateComponents(year: 1978, month: 8, day: 12))!,
                mobile: "555-111-0000",
                email: "sarah.chen@example.com",
                experience: 12,
                patients: [1, 3, 4],
                location: Location(latitude: 37.7749, longitude: -122.4194),
                locationDescription: "San Francisco Medical Center",
                rating: 4.9,
                appointments: [],
                details: "Dr. Sarah Chen is a board-certified physiotherapist specializing in sports injuries and rehabilitation. With over 12 years of experience, she has helped numerous athletes recover from ankle and foot injuries."
            )
            addPhysiotherapist(physio1)
        }
        
        if physiotherapists[2] == nil {
            let physio2 = Physiotherapist(
                id: 2,
                name: "Dr. Michael Brown",
                dob: Calendar.current.date(from: DateComponents(year: 1982, month: 11, day: 25))!,
                mobile: "555-222-0000",
                email: "michael.brown@example.com",
                experience: 8,
                patients: [2],
                location: Location(latitude: 40.7128, longitude: -74.0060),
                locationDescription: "New York Rehabilitation Center",
                rating: 4.7,
                appointments: [],
                details: "Dr. Michael Brown specializes in post-surgical rehabilitation and has extensive experience treating ankle injuries. His holistic approach combines traditional therapy with innovative techniques."
            )
            addPhysiotherapist(physio2)
        }
        
        if physiotherapists[3] == nil {
            let physio3 = Physiotherapist(
                id: 3,
                name: "Dr. Ashok Pt",
                dob: Calendar.current.date(from: DateComponents(year: 1975, month: 5, day: 15))!,
                mobile: "555-333-0000",
                email: "drashok@example.com",
                experience: 15,
                patients: [],
                location: Location(latitude: 19.0760, longitude: 72.8777),
                locationDescription: "Mumbai Health Center",
                rating: 4.8,
                appointments: [],
                details: "Dr. Ashok is a specialist in ankle rehabilitation with over 15 years of experience. He has published numerous articles on effective recovery techniques for ankle injuries."
            )
            addPhysiotherapist(physio3)
        }
        
        if physiotherapists[4] == nil {
            let physio4 = Physiotherapist(
                id: 4,
                name: "Dr. Sanjay",
                dob: Calendar.current.date(from: DateComponents(year: 1980, month: 9, day: 10))!,
                mobile: "555-444-0000",
                email: "drsanjay@example.com",
                experience: 10,
                patients: [],
                location: Location(latitude: 28.7041, longitude: 77.1025),
                locationDescription: "Delhi Physiotherapy Clinic",
                rating: 4.6,
                appointments: [],
                details: "Dr. Sanjay has a decade of experience in sports medicine and physiotherapy, specializing in ankle and foot injuries. His approach focuses on personalized treatment plans for optimal recovery."
            )
            addPhysiotherapist(physio4)
        }
        
        // Create demo patients if they don't exist
        if patients[1] == nil {
            let patient1 = Patient(
                id: 1,
                name: "John Doe",
                dob: Calendar.current.date(from: DateComponents(year: 1992, month: 6, day: 15))!,
                gender: .male,
                mobile: "555-123-4567",
                email: "johndoe@example.com",
                height: 180,
                weight: 75,
                injury: .grade2,
                currentPhysiotherapistID: 1,
                location: Location(latitude: 37.7749, longitude: -122.4194),
                locationDescription: "San Francisco, CA"
            )
            addPatient(patient: patient1)
        }
        
        if patients[2] == nil {
            let patient2 = Patient(
                id: 2,
                name: "Jane Smith",
                dob: Calendar.current.date(from: DateComponents(year: 1988, month: 8, day: 20))!,
                gender: .female,
                mobile: "555-987-6543",
                email: "janesmith@example.com",
                height: 165,
                weight: 60,
                injury: .ligamentTear,
                currentPhysiotherapistID: 1,
                location: Location(latitude: 40.7128, longitude: -74.0060),
                locationDescription: "New York, NY"
            )
            addPatient(patient: patient2)
        }
        
        if patients[3] == nil {
            let patient3 = Patient(
                id: 3,
                name: "Emily White",
                dob: Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15))!,
                gender: .female,
                mobile: "555-111-2222",
                email: "emily.white@example.com",
                height: 168,
                weight: 65,
                injury: .grade1,
                currentPhysiotherapistID: 1,
                location: Location(latitude: 37.7749, longitude: -122.4194),
                locationDescription: "San Francisco, CA"
            )
            addPatient(patient: patient3)
        }
        
        if patients[4] == nil {
            let patient4 = Patient(
                id: 4,
                name: "David Lee",
                dob: Calendar.current.date(from: DateComponents(year: 1985, month: 10, day: 20))!,
                gender: .male,
                mobile: "555-333-4444",
                email: "david.lee@example.com",
                height: 180,
                weight: 80,
                injury: .grade2,
                currentPhysiotherapistID: 1,
                location: Location(latitude: 40.7128, longitude: -74.0060),
                locationDescription: "New York, NY"
            )
            addPatient(patient: patient4)
        }
    }

    // MARK: - Data Access Methods
    
    /// Get all patients as an array
    func getAllPatients() -> [Patient] {
        return Array(patients.values)
    }
    
    /// Get all physiotherapists as an array
    func getAllPhysiotherapists() -> [Physiotherapist] {
        return Array(physiotherapists.values)
    }
    // Get physiatherapist by rating
    func getPopularPhysiotherapists() -> [Physiotherapist] {
            physiotherapists.values.filter { $0.rating ?? 0 > 4.0 }
        }
    
    /// Get a patient by ID
    func getPatient(by id: Int) -> Patient? {
        return patients[id]
    }

    /// Get a physiotherapist by ID
    func getPhysiotherapist(by id: Int) -> Physiotherapist? {
        return physiotherapists[id]
    }
    
    /// Get a physiotherapist by email
    func getPhysiotherapistByEmail(_ email: String) -> Physiotherapist? {
        return physiotherapists.values.first { physio in
            physio.email.lowercased() == email.lowercased()
        }
    }
        
        /// Get an appointment by ID
        func getAppointment(by appointmentID: Int) -> Appointment? {
            // Check in all physiotherapists' appointments
            for physio in physiotherapists.values {
                if let appointment = physio.appointments.first(where: { $0.appointmentID == appointmentID }) {
                    return appointment
                }
            }
            
            // Check in all patients' appointment histories
            for patient in patients.values {
                if let appointment = patient.appointmentHistory.first(where: { $0.appointmentID == appointmentID }) {
                    return appointment
                }
            }
            
            return nil
        }
        
        /// Get all available exercises
        func getAllExercises() -> [Exercise] {
            return exerciseLibrary
        }
        
        /// Get all educational articles
        func getAllArticles() -> [Article] {
            return articles
        }
        
        /// Get articles by tag
        func getArticles(withTags tags: [String]) -> [Article] {
            return articles.filter { article in
                !Set(article.tags).isDisjoint(with: Set(tags))
            }
        }
        
        /// Get articles by physiotherapist (author)
        func getArticles(byAuthor authorName: String) -> [Article] {
            return articles.filter { $0.author == authorName }
        }
        
        /// Update the patient
        func updatePatient(_ patient: Patient) {
            patients[patient.id] = patient
        }

        // MARK: - Appointment Management Methods

        /// Book a new appointment
    func bookAppointment(
        patientID: Int,
        physioID: Int,
        date: Date,
        time: String,
        summary: String
    ) {
        // Check if an identical appointment already exists
        let existingAppointments = patients[patientID]?.appointmentHistory ?? []
        let isDuplicateAppointment = existingAppointments.contains { appointment in
            appointment.date == date &&
            appointment.time == time &&
            appointment.physiotherapistID == physioID
        }
        
        // If not a duplicate, create the new appointment
        if !isDuplicateAppointment {
            let appointmentID = Int.random(in: 1000...9999)
            let patientName = patients[patientID]?.name ?? "Unknown Patient"

            let newAppointment = Appointment(
                patientID: patientID,
                appointmentID: appointmentID,
                date: date,
                time: time,
                physiotherapistID: physioID,
                patientName: patientName,
                diagnosis: summary,
                status: true
            )

            // Add appointment to patient's history
            if var patient = patients[patientID] {
                // Remove any previous pending appointments for the same date/time
                patient.appointmentHistory.removeAll {
                    $0.date == date && $0.time == time
                }
                patient.appointmentHistory.append(newAppointment)
                updatePatient(patient)
            }

            // Add to physiotherapist's appointments
            if var physiotherapist = physiotherapists[physioID] {
                physiotherapist.appointments.removeAll {
                    $0.date == date && $0.time == time
                }
                physiotherapist.appointments.append(newAppointment)
                updatePhysiotherapist(physiotherapist)
            }

            // Remove any pending appointment requests for this time
            appointmentRequests.removeAll { request in
                request.patientID == patientID &&
                request.date == DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none) &&
                request.time == time
            }

            saveAppointmentsToStorage()
            objectWillChange.send()
        }
    }

        /// Request a new appointment (patient side)
    func requestAppointment(
        patientID: Int,
        patientName: String,
        date: String,
        time: String,
        notes: String = ""
    ) {
        // Create a new appointment with status set to false (pending)
        let appointmentID = Int.random(in: 10000...99999)
        let newAppointment = Appointment(
            patientID: patientID,
            appointmentID: appointmentID,
            date: parseRequestDate(dateString: date, timeString: time),
            time: time,
            physiotherapistID: patients[patientID]?.currentPhysiotherapistID ?? 0,
            patientName: patientName,
            diagnosis: notes,
            status: false  // Set status to false for pending appointments
        )
        
        // Add to patient's appointment history
        if var patient = patients[patientID] {
            patient.appointmentHistory.append(newAppointment)
            updatePatient(patient)
        }
        
        // Create appointment request
        let newRequest = AppointmentRequest(
            patientID: patientID,
            patientName: patientName,
            date: date,
            time: time,
            status: .pending,
            injury: patients[patientID]?.injury ?? .other(description: ""),
            notes: notes
        )
        
        appointmentRequests.append(newRequest)
        objectWillChange.send()
    }

    // Helper method to parse date
    private func parseRequestDate(dateString: String, timeString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy h:mm a"
        return dateFormatter.date(from: "\(dateString) \(timeString)") ?? Date()
    }

        /// Set all appointment requests (admin/dev/debug)
        func setAppointmentRequests(_ requests: [AppointmentRequest]) {
            self.appointmentRequests = requests
            objectWillChange.send()
        }

        /// Approve an appointment request (physiotherapist side)
        /// //Needs to be checked..
        func approveAppointmentRequest(request: AppointmentRequest, physioID: Int) {
            if let index = appointmentRequests.firstIndex(where: { $0.id == request.id }) {
                appointmentRequests[index].status = .approved
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            if let date = dateFormatter.date(from: request.date) {
                bookAppointment(
                    patientID: request.patientID,
                    physioID: physioID,
                    date: date,
                    time: request.time,
                    summary: request.notes.isEmpty ? "Initial Assessment" : request.notes
                )
            }

            // ✅ Add patient to physiotherapist only if not already added
            if let physio = physiotherapists[physioID], !physio.patients.contains(request.patientID) {
            physiotherapists[physioID]?.patients.append(request.patientID)
            }

            objectWillChange.send()
        }

        /// Reject an appointment request
        func rejectAppointmentRequest(request: AppointmentRequest) {
            if let index = appointmentRequests.firstIndex(where: { $0.id == request.id }) {
                appointmentRequests[index].status = .rejected
                objectWillChange.send()
            }
        }

        /// Get all active appointments for a patient
func getAllPatientAppointments(patientID: Int) -> [Appointment] {
        return patients[patientID]?.appointmentHistory.filter {
            $0.status && $0.date >= Date()
        } ?? []
    }

        /// Get all active appointments for a physiotherapist
        func getAllDoctorAppointments(physioID: Int) -> [Appointment] {
            return patients.values.flatMap { $0.appointmentHistory }
                .filter { $0.physiotherapistID == physioID }
        }

        /// Get full appointment history for a patient
        func getPatientAppointmentHistory(patientID: Int) -> [Appointment] {
            return patients[patientID]?.appointmentHistory ?? []
        }

        /// Get today's appointments for a physiotherapist
        func getTodayAppointments(physioID: Int) -> [Appointment] {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            return getAllDoctorAppointments(physioID: physioID)
                .filter { calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: today) && $0.status }
                .sorted { $0.date < $1.date }
        }

        /// Get upcoming appointments for a physiotherapist
        func getUpcomingAppointments(physioID: Int) -> [Appointment] {
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!

            return getAllDoctorAppointments(physioID: physioID)
                .filter { $0.date >= tomorrow && $0.status }
                .sorted { $0.date < $1.date }
        }
        
        // MARK: - Exercise Management Methods

    /// Log a patient's exercise performance
    func logExercise(patientID: Int, exerciseID: Int, reps: Int, sets: Int, painLevel: Int) {
        let logID = Int.random(in: 1000...9999)
        let newLog = ExerciseLog(
            logID: logID,
            exerciseID: exerciseID,
            userID: patientID,
            date: Date(),
            reps: reps,
            sets: sets,
            painLevel: painLevel
        )
        
        // Add to exercise logs
        exerciseLogs[patientID, default: []].append(newLog)
        
        // Also add to patient's exercise logs for consistency
        if var patient = patients[patientID] {
            patient.exerciseLogs.append(newLog)
            patients[patientID] = patient
        }
        
        // Save exercise logs to persistent storage
        saveExerciseLogs()
        
        // Update progress metrics for today
        calculateTodayProgress(for: patientID)
        
        // Notify of changes
        objectWillChange.send()
    }

    // Track today's progress metrics for quick access
//    @Published var todayProgressMetrics: [Int: (completed: Int, total: Int, painLevel: Double)] = [:]

    // Calculate today's progress for a specific patient
    func calculateTodayProgress(for patientID: Int) {
        guard let patient = patients[patientID] else { return }
        
        // Get total exercises assigned
        let totalExercises = patient.exercises.count
        
        // Get today's logs
        let calendar = Calendar.current
        let todayLogs = exerciseLogs[patientID, default: []].filter { calendar.isDateInToday($0.date) }
        
        // Count unique exercises completed today
        let uniqueExercisesCompleted = Set(todayLogs.map { $0.exerciseID }).count
        
        // Calculate average pain level for today
        let avgPain: Double
        if todayLogs.isEmpty {
            avgPain = 0.0
        } else {
            avgPain = Double(todayLogs.map { $0.painLevel }.reduce(0, +)) / Double(todayLogs.count)
        }
        
        // Store metrics for this patient
        todayProgressMetrics[patientID] = (uniqueExercisesCompleted, totalExercises, avgPain)
        
        // Do NOT call objectWillChange.send() here as it can be called during view updates
    }

    // Get today's progress percentage for a patient
    func getTodayProgressPercentage(for patientID: Int) -> Double {
        // Only calculate if needed, but don't trigger a view update
        if todayProgressMetrics[patientID] == nil {
            calculateTodayProgress(for: patientID)
        }
        
        guard let metrics = todayProgressMetrics[patientID],
              metrics.total > 0 else {
            return 0.0
        }
        
        return Double(metrics.completed) / Double(metrics.total) * 100.0
    }

    // Get today's average pain level
    func getTodayAveragePain(for patientID: Int) -> Double {
        // Only calculate if needed, but don't trigger a view update
        if todayProgressMetrics[patientID] == nil {
            calculateTodayProgress(for: patientID)
        }
        
        return todayProgressMetrics[patientID]?.painLevel ?? 0.0
    }

        /// Get exercise logs for a specific patient
        func getExerciseLogs(for patientID: Int) -> [ExerciseLog] {
            return exerciseLogs[patientID] ?? patients[patientID]?.exerciseLogs ?? []
        }
        
        /// Add exercise feedback from a patient
        func addExerciseFeedback(patientID: Int, exerciseID: Int, comment: String, painLevel: Int, completed: Bool) {
            // Get patient and exercise names
            let patientName = patients[patientID]?.name ?? "Unknown Patient"
            let exerciseName = exerciseLibrary.first(where: { $0.exerciseID == exerciseID })?.name ?? "Unknown Exercise"
            
            let feedbackID = Int.random(in: 1000...9999)
            let newFeedback = ExerciseFeedback(
                feedbackID: feedbackID,
                patientID: patientID,
                exerciseID: exerciseID,
                patientName: patientName,
                exerciseName: exerciseName,
                date: Date(),
                comment: comment,
                painLevel: painLevel,
                completed: completed
            )
            
            exerciseFeedbacks.append(newFeedback)
            objectWillChange.send()
        }
        
        /// Get all exercise feedback from patients
        func getAllExerciseFeedback() -> [ExerciseFeedback] {
            return exerciseFeedbacks
        }

        /// Get feedback for a specific patient
        func getExerciseFeedback(for patientID: Int) -> [ExerciseFeedback] {
            return exerciseFeedbacks.filter { $0.patientID == patientID }
        }
        
        // MARK: - Exercise Assignment Methods
        
        /// Assign exercises to a patient
        func assignExercisesToPatient(patientID: Int, exerciseIDs: [Int]) {
            guard var patient = patients[patientID] else { return }

            let allExercises = getAllExercises()
            let exercisesToAssign = allExercises.filter { exercise in
                exerciseIDs.contains(exercise.exerciseID)
            }

            for exercise in exercisesToAssign {
                if !patient.exercises.contains(where: { $0.exerciseID == exercise.exerciseID }) {
                    patient.exercises.append(exercise)
                }
            }

            patients[patientID] = patient
        }

        // MARK: - Progress Analysis Methods

        /// Generate pain level history for progress graphs
        func generatePainLevelHistory(for patientID: Int) -> [(date: Date, level: Int)] {
            let logs = getExerciseLogs(for: patientID)
                .sorted { $0.date < $1.date }
            
            return logs.map { (date: $0.date, level: $0.painLevel) }
        }
        
        /// Calculate exercise adherence for a patient (percentage of completed vs. assigned)
        func calculateAdherence(for patientID: Int, days: Int = 7) -> Double {
            guard let patient = patients[patientID] else { return 0.0 }
            
            // Calculate number of assigned exercise instances
            let totalAssigned = patient.exercises.count * days
            
            // If nothing assigned, return 100%
            if totalAssigned == 0 { return 100.0 }
            
            // Count logs within the period
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
            
            let completedLogs = patient.exerciseLogs.filter { $0.date >= startDate }.count
            
            // Calculate percentage
            return min(100.0, (Double(completedLogs) / Double(totalAssigned)) * 100.0)
        }

        // MARK: - Patient Management Methods

        /// Add a new patient to the system
        func addPatient(patient: Patient, appointment: Appointment? = nil) {
            patients[patient.id] = patient
            
            // If the patient has a physiotherapist assigned, update the physiotherapist's patient list
            if let physioID = patient.currentPhysiotherapistID {
                if physiotherapists[physioID]?.patients.contains(patient.id) == false {
                    physiotherapists[physioID]?.patients.append(patient.id)
                }
                
                // If an appointment is provided, add it to the physiotherapist's appointments
                if let appointment = appointment {
                    physiotherapists[physioID]?.appointments.append(appointment)
                }
            }
            
            // Notify of changes
            objectWillChange.send()
        }
        
        // MARK: - Exercise Log Management Methods

        // Load exercise logs from persistent storage
        private func loadExerciseLogs() {
            if let data = UserDefaults.standard.data(forKey: "exercise_logs") {
                do {
                    exerciseLogs = try JSONDecoder().decode([Int: [ExerciseLog]].self, from: data)
                } catch {
                    print("Error loading exercise logs: \(error)")
                    exerciseLogs = [:]
                }
            }
        }

        // Save exercise logs to persistent storage
        private func saveExerciseLogs() {
            do {
                let data = try JSONEncoder().encode(exerciseLogs)
                UserDefaults.standard.set(data, forKey: "exercise_logs")
            } catch {
                print("Error saving exercise logs: \(error)")
            }
        }

        // Add an exercise log
        func addExerciseLog(_ log: ExerciseLog) {
            // Get existing logs for this patient, or create a new array
            var patientLogs = exerciseLogs[log.userID] ?? []
            
            // Add the new log
            patientLogs.append(log)
            
            // Update the logs dictionary
            exerciseLogs[log.userID] = patientLogs
            
            // Also add to patient's exercise logs for consistency
            if var patient = patients[log.userID] {
                patient.exerciseLogs.append(log)
                patients[log.userID] = patient
            }
            
            // Trigger notification that model has changed
            objectWillChange.send()
            
            // Save to persistent storage
            saveExerciseLogs()
        }

        // Calculate adherence for a patient within a specific date range
        func calculateAdherence(patientID: Int, from startDate: Date, to endDate: Date) -> Double {
            // Get all logs for the patient within the date range
            let patientLogs = getExerciseLogs(for: patientID).filter { log in
                log.date >= startDate && log.date <= endDate && log.completed
            }
            
            // Get the patient
            guard let patient = patients[patientID] else { return 0.0 }
            
            // Get assigned exercises for the patient
            let assignedExercises = patient.exercises
            
            // If no exercises assigned, adherence is 0
            if assignedExercises.isEmpty { return 0.0 }
            
            // Calculate total expected exercises in this period
            // For simplicity, assuming each exercise should be done once per day
            let calendar = Calendar.current
            let numberOfDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            let totalExpectedSessions = assignedExercises.count * max(1, numberOfDays)
            
            // Get unique exercise sessions completed (one per exercise per day)
            var completedSessions = 0
            var processedExerciseDays = Set<String>()
            
            for log in patientLogs {
                // Create a unique key for each exercise per day
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: log.date)
                let exerciseKey = "\(log.exerciseID)-\(dateString)"
                
                // If we haven't counted this exercise for this day yet
                if !processedExerciseDays.contains(exerciseKey) {
                    completedSessions += 1
                    processedExerciseDays.insert(exerciseKey)
                }
            }
            
            // Calculate adherence percentage
            return Double(completedSessions) / Double(totalExpectedSessions) * 100.0
        }

        // Calculate average pain level for a patient within a specific date range
        func calculateAveragePain(patientID: Int, from startDate: Date, to endDate: Date) -> Double {
            // Get all logs for the patient within the date range
            let patientLogs = getExerciseLogs(for: patientID).filter { log in
                log.date >= startDate && log.date <= endDate
            }
            
            // If no logs, return 0
            if patientLogs.isEmpty { return 0.0 }
            
            // Calculate average pain
            let totalPain = patientLogs.reduce(0) { $0 + $1.painLevel }
            return Double(totalPain) / Double(patientLogs.count)
        }

        // Get weekly data for progress tracker
        func getWeeklyProgressData(patientID: Int, weeksAgo: Int = 0) -> [ExerciseLog] {
            let calendar = Calendar.current
            
            // Calculate the start of the requested week
            var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            dateComponents.weekOfYear = (dateComponents.weekOfYear ?? 0) - weeksAgo
            guard let startOfWeek = calendar.date(from: dateComponents) else { return [] }
            
            // Calculate the end of the week
            guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else { return [] }
            
            // Get logs for the week
            return getExerciseLogs(for: patientID).filter { log in
                log.date >= startOfWeek && log.date <= endOfWeek
            }
        }

        // Enhanced method to add exercise feedback with more parameters
        func addExerciseFeedback(_ feedback: ExerciseFeedback) {
            exerciseFeedbacks.append(feedback)
            objectWillChange.send()
        }

        // MARK: - Physiotherapist Management Methods
        
        /// Add a new physiotherapist to the system
        func addPhysiotherapist(_ physiotherapist: Physiotherapist) {
            physiotherapists[physiotherapist.id] = physiotherapist
            objectWillChange.send()
        }
        
        /// Update a physiotherapist's data
        func updatePhysiotherapist(_ physiotherapist: Physiotherapist) {
            physiotherapists[physiotherapist.id] = physiotherapist
            objectWillChange.send()
        }

        // MARK: - Physiotherapist Suggestion Methods

        /// Find physiotherapists near a location
        func findNearbyPhysiotherapists(userLocation: Location, maxDistance: Double = 10.0) -> [Physiotherapist] {
            return physiotherapists.values.filter { physio in
                let distance = calculateDistance(from: userLocation, to: physio.location)
                return distance <= maxDistance
            }
        }

        /// Get highly-rated physiotherapists
        func getHighlyRatedPhysiotherapists(minRating: Double = 4.0) -> [Physiotherapist] {
            return physiotherapists.values.filter { $0.rating ?? 0.0 >= minRating }
        }

        // MARK: - Chat Functionality Methods
            
        /// Send a new chat message
        func sendChatMessage(_ message: ChatMessage) {
            chatMessages.append(message)
            objectWillChange.send()
        }

        /// Add a new chat message with sender, receiver, and message content
        func addChatMessage(senderID: Int, receiverID: Int, message: String, senderName: String = "") {
            // Determine sender name if not provided
            var name = senderName
            if name.isEmpty {
                if let sender = getPatient(by: senderID) {
                    name = sender.name
                } else if let sender = getPhysiotherapist(by: senderID) {
                    name = sender.name
                } else {
                    name = "Unknown User"
                }
            }
            
            let newMessage = ChatMessage(
                senderID: senderID,
                receiverID: receiverID,
                timestamp: Date(),
                message: message,
                isRead: false,
                senderName: name
            )
            sendChatMessage(newMessage)
        }

        /// Mark messages as read
        func markMessagesAsRead(fromSenderID senderID: Int, toReceiverID receiverID: Int) {
            var messageUpdated = false
            
            for i in 0..<chatMessages.count {
                if chatMessages[i].senderID == senderID &&
                   chatMessages[i].receiverID == receiverID &&
                   !chatMessages[i].isRead {
                    chatMessages[i].isRead = true
                    messageUpdated = true
                }
            }
            
            if messageUpdated {
                objectWillChange.send()
            }
        }

        /// Get chat messages between two users
        func getChatMessages(between userID1: Int, and userID2: Int) -> [ChatMessage] {
            return chatMessages.filter { msg in
                (msg.senderID == userID1 && msg.receiverID == userID2) ||
                (msg.senderID == userID2 && msg.receiverID == userID1)
            }
        }

        /// Get all chat messages
        func getAllChatMessages() -> [ChatMessage] {
            return chatMessages
        }

        /// Get all unique chat partners for a user
        func getChatPartners(for userID: Int) -> [Int] {
            let messages = chatMessages.filter { msg in
                msg.senderID == userID || msg.receiverID == userID
            }
            
            var partnerIDs = Set<Int>()
            for message in messages {
                if message.senderID == userID {
                    partnerIDs.insert(message.receiverID)
                } else {
                    partnerIDs.insert(message.senderID)
                }
            }
            
            return Array(partnerIDs)
        }
        
        // MARK: - Helper Methods
        
        /// Format a date to a standard string format
        func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy" // Example: 18 Mar 2025
            return formatter.string(from: date)
        }
        
        /// Calculate distance between two locations using Haversine formula
        private func calculateDistance(from loc1: Location, to loc2: Location) -> Double {
            let earthRadius = 6371.0 // Radius in kilometers
            let dLat = (loc2.latitude - loc1.latitude) * .pi / 180
            let dLon = (loc2.longitude - loc1.longitude) * .pi / 180

            let a = sin(dLat / 2) * sin(dLat / 2) +
                    cos(loc1.latitude * .pi / 180) * cos(loc2.latitude * .pi / 180) *
                    sin(dLon / 2) * sin(dLon / 2)

            let c = 2 * atan2(sqrt(a), sqrt(1 - a))
            return earthRadius * c
        }
        
        /// Cleanup old data (remove expired appointments, etc.)
        func performMaintenance() {
            // This could be called periodically to clean up old data
            let calendar = Calendar.current
            let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
            
            // Remove exercise logs older than one month
            for (patientID, logs) in exerciseLogs {
                let filteredLogs = logs.filter { $0.date >= oneMonthAgo }
                if filteredLogs.count != logs.count {
                    exerciseLogs[patientID] = filteredLogs
                }
            }
            
            // Similarly, could clean up old appointments, messages, etc.
        }
    
    func addPatientVideo(
        patientID: Int,
        videoURL: URL,
        exerciseID: Int? = nil,
        duration: TimeInterval? = nil,
        fileSize: Int64? = nil
    ) {
        // Check file exists and is accessible
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            print("❌ Video file does not exist at path: \(videoURL.path)")
            return
        }
        
        // Get file attributes
        let attributes = try? FileManager.default.attributesOfItem(atPath: videoURL.path)
        let size = attributes?[.size] as? Int64 ?? fileSize
        
        // Create video entry
        let newVideo = PatientVideo(
            patientID: patientID,
            videoURL: videoURL,
            uploadDate: Date(),
            exerciseID: exerciseID,
            duration: duration ?? getDuration(of: videoURL),
            fileSize: size
        )
        
        // Add to patient videos
        _patientVideos.append(newVideo)
        
        // Notify observers of change
        objectWillChange.send()
    }

    // Helper method to get video duration
    private func getDuration(of videoURL: URL) -> TimeInterval? {
        let asset = AVAsset(url: videoURL)
        return CMTimeGetSeconds(asset.duration)
    }
        
        // Get videos for a specific patient
        func getPatientVideos(patientID: Int) -> [PatientVideo] {
            return _patientVideos.filter { $0.patientID == patientID }
        }
        
        // Helper method to get video duration
//        private func getDuration(of videoURL: URL) -> TimeInterval? {
//            let asset = AVAsset(url: videoURL)
//            return CMTimeGetSeconds(asset.duration)
//        }
        
        // Delete a specific video
        func deletePatientVideo(videoID: UUID) {
            // Remove from patient videos
            _patientVideos.removeAll { $0.id == videoID }
            
            // Optional: Delete physical file from filesystem
            if let video = _patientVideos.first(where: { $0.id == videoID }) {
                do {
                    try FileManager.default.removeItem(at: video.videoURL)
                } catch {
                    print("Error deleting video file: \(error)")
                }
            }
            
            // Notify observers
            objectWillChange.send()
        }
        
        // Check if a patient has any videos
        func hasVideos(patientID: Int) -> Bool {
            return !getPatientVideos(patientID: patientID).isEmpty
        }
        
        // Get total number of videos for a patient
        func videoCount(patientID: Int) -> Int {
            return getPatientVideos(patientID: patientID).count
        }
    }

    extension AnkleHealDataModel {
        // Verify patient login credentials
        func verifyPatientLogin(email: String, password: String) -> (success: Bool, patientID: Int?) {
            // For empty credentials in dev mode, auto-login as first patient
            if email.isEmpty && password.isEmpty {
                if let firstPatient = getAllPatients().first {
                    return (true, firstPatient.id)
                }
                return (true, 1) // Fallback to ID 1 if no patients
            }
            
            // Find patient by email
            let patient = getAllPatients().first { patient in
                patient.email.lowercased() == email.lowercased()
            }
            
            if let patient = patient {
                // In a real app, you would hash and verify the password
                // For this demo, accept any password for the matching email
                return (true, patient.id)
            }
            
            return (false, nil)
        }
    }

extension AnkleHealDataModel {
    // Function to initialize sample chat messages
    func initializeSampleChatMessages() {
        // Make sure we don't duplicate chat messages if they already exist
        if !chatMessages.isEmpty {
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        // Sample messages between physiotherapist 1 and patient 1
        chatMessages.append(ChatMessage(
            senderID: 1, // Physio ID
            receiverID: 1, // Patient ID
            timestamp: twoDaysAgo.addingTimeInterval(3600 * 10), // Morning
            message: "Hello John, how is your ankle feeling today?",
            isRead: true,
            senderName: "Dr. Sarah Chen"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 1, // Patient ID
            receiverID: 1, // Physio ID
            timestamp: twoDaysAgo.addingTimeInterval(3600 * 11), // An hour later
            message: "Hi Dr. Chen, it's still a bit stiff in the morning but getting better.",
            isRead: true,
            senderName: "John Doe"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 1, // Physio ID
            receiverID: 1, // Patient ID
            timestamp: yesterday.addingTimeInterval(3600 * 10), // Yesterday morning
            message: "Remember to do your exercises 3 times a day as we discussed. Are you able to bear weight on it now?",
            isRead: true,
            senderName: "Dr. Sarah Chen"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 1, // Patient ID
            receiverID: 1, // Physio ID
            timestamp: yesterday.addingTimeInterval(3600 * 14), // Yesterday afternoon
            message: "I did all the exercises today. The resistance band ones are getting easier. Yes, I can put more weight on it now.",
            isRead: true,
            senderName: "John Doe"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 1, // Physio ID
            receiverID: 1, // Patient ID
            timestamp: today.addingTimeInterval(-3600), // 1 hour ago
            message: "Great progress, John! Looking forward to seeing you at your appointment tomorrow. Please bring your supportive shoes.",
            isRead: false,
            senderName: "Dr. Sarah Chen"
        ))
        
        // Sample messages between physiotherapist 2 and patient 2
        chatMessages.append(ChatMessage(
            senderID: 2, // Physio ID
            receiverID: 2, // Patient ID
            timestamp: twoDaysAgo.addingTimeInterval(3600 * 13), // 2 days ago afternoon
            message: "Hi Jane, just checking in on your ankle. How's your pain level today?",
            isRead: true,
            senderName: "Dr. Michael Brown"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 2, // Patient ID
            receiverID: 2, // Physio ID
            timestamp: twoDaysAgo.addingTimeInterval(3600 * 15), // 2 hours later
            message: "Hello Dr. Brown. It's around 3/10 today. Better than yesterday. I've been icing regularly.",
            isRead: true,
            senderName: "Jane Smith"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 2, // Physio ID
            receiverID: 2, // Patient ID
            timestamp: yesterday.addingTimeInterval(3600 * 9), // Yesterday morning
            message: "That's good progress. Have you been able to do the heel raises I showed you?",
            isRead: false,
            senderName: "Dr. Michael Brown"
        ))
        
        // Additional messages between physiotherapist 1 and patient 3
        chatMessages.append(ChatMessage(
            senderID: 1, // Physio ID
            receiverID: 3, // Patient ID (Emily White)
            timestamp: yesterday.addingTimeInterval(3600 * 8), // Yesterday morning
            message: "Good morning Emily. How is your recovery progressing?",
            isRead: true,
            senderName: "Dr. Sarah Chen"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 3, // Patient ID
            receiverID: 1, // Physio ID
            timestamp: yesterday.addingTimeInterval(3600 * 9), // An hour later
            message: "Good morning Dr. Chen. I've been doing better with the balance exercises, but still have some pain when walking.",
            isRead: true,
            senderName: "Emily White"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 1, // Physio ID
            receiverID: 3, // Patient ID
            timestamp: today.addingTimeInterval(-5400), // 1.5 hours ago
            message: "Try applying ice after your exercises today. Let me know if the pain increases.",
            isRead: false,
            senderName: "Dr. Sarah Chen"
        ))
        
        // Additional messages between physiotherapist 1 and patient 4
        chatMessages.append(ChatMessage(
            senderID: 4, // Patient ID (David Lee)
            receiverID: 1, // Physio ID
            timestamp: twoDaysAgo.addingTimeInterval(3600 * 12), // 2 days ago
            message: "Dr. Chen, I wanted to ask about the ankle brace. Should I wear it while exercising or only when walking?",
            isRead: true,
            senderName: "David Lee"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 1, // Physio ID
            receiverID: 4, // Patient ID
            timestamp: twoDaysAgo.addingTimeInterval(3600 * 14), // 2 hours later
            message: "Hi David, wear it during walking and daily activities. You can remove it for the seated and lying exercises, but keep it on for standing exercises for now.",
            isRead: true,
            senderName: "Dr. Sarah Chen"
        ))
        
        chatMessages.append(ChatMessage(
            senderID: 4, // Patient ID
            receiverID: 1, // Physio ID
            timestamp: today.addingTimeInterval(-7200), // 2 hours ago
            message: "Thanks for the advice. I'll do that. Also, my next appointment is tomorrow, correct?",
            isRead: false,
            senderName: "David Lee"
        ))
        
        // Add an unread message from Dr. Brown to Jane Smith (Patient 2)
        chatMessages.append(ChatMessage(
            senderID: 2, // Physio ID
            receiverID: 2, // Patient ID
            timestamp: today.addingTimeInterval(-1800), // 30 minutes ago
            message: "Jane, I've uploaded some new heel raise variations to your exercise library. Let me know how they feel when you try them.",
            isRead: false,
            senderName: "Dr. Michael Brown"
        ))
    }
}

// MARK: - Improved Appointment Rescheduling Methods for DataModel

extension AnkleHealDataModel {
    // Create a reschedule request with improved handling
    func createRescheduleRequest(
        appointmentID: Int,
        patientID: Int,
        originalDate: Date,
        originalTime: String,
        suggestedNewDate: Date? = nil,
        suggestedNewTime: String? = nil
    ) {
        let newRequest = RescheduleRequest(
            appointmentID: appointmentID,
            patientID: patientID,
            originalDate: originalDate,
            originalTime: originalTime,
            suggestedNewDate: suggestedNewDate,
            suggestedNewTime: suggestedNewTime
        )
        
        // Add the new request to the list
        rescheduleRequests.append(newRequest)
        
        // Mark the appointment as being rescheduled - temporarily set status to false
        // to remove it from active appointments
        markAppointmentAsRescheduling(appointmentID: appointmentID)
        
        // Notify observers
        objectWillChange.send()
    }
    
    // Helper to mark an appointment as being rescheduled
    private func markAppointmentAsRescheduling(appointmentID: Int) {
        // Find the appointment in both physiotherapist and patient records
        for (physioID, physio) in physiotherapists {
            if let index = physio.appointments.firstIndex(where: { $0.appointmentID == appointmentID }) {
                // Mark as not active while rescheduling (status = false)
                physiotherapists[physioID]?.appointments[index].status = false
            }
        }
        
        // Also update patient side
        for (patientID, patient) in patients {
            if let index = patient.appointmentHistory.firstIndex(where: { $0.appointmentID == appointmentID }) {
                patients[patientID]?.appointmentHistory[index].status = false
            }
        }
    }
    
    // Get reschedule requests for a patient
    func getRescheduleRequests(for patientID: Int) -> [RescheduleRequest] {
        return rescheduleRequests.filter { $0.patientID == patientID && $0.status == .pending }
    }
    
    // Respond to a reschedule request
    func respondToReschedule(
        requestID: UUID,
        newDate: Date,
        newTime: String,
        accept: Bool
    ) {
        guard let index = rescheduleRequests.firstIndex(where: { $0.id == requestID }) else {
            return
        }
        
        if accept {
            // Find the original appointment
            if var originalAppointment = findOriginalAppointment(for: rescheduleRequests[index]) {
                // Update appointment with new date and time
                originalAppointment.date = newDate
                originalAppointment.time = newTime
                originalAppointment.status = true
                
                // Replace the original appointment
                replaceAppointment(originalAppointment)
            }
            
            // Mark request as accepted and update suggested times
            rescheduleRequests[index].status = .accepted
            rescheduleRequests[index].suggestedNewDate = newDate
            rescheduleRequests[index].suggestedNewTime = newTime
        } else {
            // Mark request as rejected
            rescheduleRequests[index].status = .rejected
            
            // If the patient rejects the reschedule, cancel the original appointment
            if let originalAppointment = findOriginalAppointment(for: rescheduleRequests[index]) {
                // Use the method to completely remove the appointment
                _ = cancelAppointment(appointmentID: originalAppointment.appointmentID)
            }
        }
        
        objectWillChange.send()
    }
    
    private func findOriginalAppointment(for request: RescheduleRequest) -> Appointment? {
        let currentCalendar = Calendar.current
        
        // Search through all patients' appointment histories
        for patient in patients.values {
            if let appointment = patient.appointmentHistory.first(where: { appointment in
                currentCalendar.isDate(appointment.date, inSameDayAs: request.originalDate) &&
                appointment.time == request.originalTime &&
                appointment.patientID == request.patientID
            }) {
                return appointment
            }
        }
        return nil
    }
    
    private func replaceAppointment(_ newAppointment: Appointment) {
        // Replace the appointment in patient's history
        for (patientID, var patient) in patients {
            if let index = patient.appointmentHistory.firstIndex(where: {
                $0.appointmentID == newAppointment.appointmentID
            }) {
                patient.appointmentHistory[index] = newAppointment
                patients[patientID] = patient
                break
            }
        }
        
        // Also replace in physiotherapists' appointments
        for (physiotherapistID, var physiotherapist) in physiotherapists {
            if let index = physiotherapist.appointments.firstIndex(where: {
                $0.appointmentID == newAppointment.appointmentID
            }) {
                physiotherapist.appointments[index] = newAppointment
                physiotherapists[physiotherapistID] = physiotherapist
                break
            }
        }
    }
    
    // Helper to restore an appointment after a rejected reschedule
    private func restoreOriginalAppointment(_ appointmentID: Int) {
        // Find the appointment in both physiotherapist and patient records
        for (physioID, physio) in physiotherapists {
            if let index = physio.appointments.firstIndex(where: { $0.appointmentID == appointmentID }) {
                // Restore active status (true)
                physiotherapists[physioID]?.appointments[index].status = true
            }
        }
        
        // Also update patient side
        for (patientID, patient) in patients {
            if let index = patient.appointmentHistory.firstIndex(where: { $0.appointmentID == appointmentID }) {
                patients[patientID]?.appointmentHistory[index].status = true
            }
        }
    }
    
    // Improved reschedule appointment implementation
    func rescheduleAppointment(appointmentID: Int, newDate: Date, newTime: String, newDiagnosis: String? = nil) -> Bool {
        var appointmentFound = false
        
        // Update physiotherapist appointment
        for (physioID, physio) in physiotherapists {
            if let index = physio.appointments.firstIndex(where: { $0.appointmentID == appointmentID }) {
                physiotherapists[physioID]?.appointments[index].date = newDate
                physiotherapists[physioID]?.appointments[index].time = newTime
                physiotherapists[physioID]?.appointments[index].status = true // Set to active (confirmed)
                
                if let newDiagnosis = newDiagnosis {
                    physiotherapists[physioID]?.appointments[index].diagnosis = newDiagnosis
                }
                appointmentFound = true
            }
        }
        
        // Update patient appointment
        for (patientID, patient) in patients {
            if let index = patient.appointmentHistory.firstIndex(where: { $0.appointmentID == appointmentID }) {
                patients[patientID]?.appointmentHistory[index].date = newDate
                patients[patientID]?.appointmentHistory[index].time = newTime
                patients[patientID]?.appointmentHistory[index].status = true // Set to active (confirmed)
                
                if let newDiagnosis = newDiagnosis {
                    patients[patientID]?.appointmentHistory[index].diagnosis = newDiagnosis
                }
                appointmentFound = true
            }
        }
        
        // Force an update
        objectWillChange.send()
        
        return appointmentFound
    }
    
    // Improved method for cancelling an appointment
        func cancelAppointment(appointmentID: Int,
                               cancellationReason: String? = nil,
                               notifyPhysiotherapist: Bool = true) -> Bool {
            // Find the appointment to cancel
            guard let appointment = findAppointmentToCancel(appointmentID: appointmentID) else {
                print("❌ Appointment with ID \(appointmentID) not found for cancellation")
                return false
            }
            
            // Remove from patient's appointment history
            removeAppointmentFromPatient(appointmentID: appointmentID)
            
            // Remove from physiotherapist's appointments
            removeAppointmentFromPhysiotherapist(appointmentID: appointmentID)
            
            // Clear any pending reschedule requests for this appointment
            removeRescheduleRequests(appointmentID: appointmentID)
            
            // Remove any pending appointment requests
            removeAppointmentRequests(appointment: appointment)
            
            // Optional: Send notification to physiotherapist
            if notifyPhysiotherapist {
                sendCancellationNotification(appointment: appointment,
                                             reason: cancellationReason)
            }
            
            // Update data model observers
            objectWillChange.send()
            
            print("✅ Appointment \(appointmentID) successfully cancelled")
            return true
        }
        
        // Helper method to find the appointment to cancel
        private func findAppointmentToCancel(appointmentID: Int) -> Appointment? {
            // Search in physiotherapists' appointments
            for physio in physiotherapists.values {
                if let appointment = physio.appointments.first(where: { $0.appointmentID == appointmentID }) {
                    return appointment
                }
            }
            
            // Search in patients' appointment histories
            for patient in patients.values {
                if let appointment = patient.appointmentHistory.first(where: { $0.appointmentID == appointmentID }) {
                    return appointment
                }
            }
            
            return nil
        }
        
        // Remove appointment from patient's history
        private func removeAppointmentFromPatient(appointmentID: Int) {
            for (patientID, var patient) in patients {
                patient.appointmentHistory.removeAll { $0.appointmentID == appointmentID }
                patients[patientID] = patient
            }
        }
        
        // Remove appointment from physiotherapist's appointments
        private func removeAppointmentFromPhysiotherapist(appointmentID: Int) {
            for (physiotherapistID, var physiotherapist) in physiotherapists {
                physiotherapist.appointments.removeAll { $0.appointmentID == appointmentID }
                physiotherapists[physiotherapistID] = physiotherapist
            }
        }
        
        // Remove related reschedule requests
        private func removeRescheduleRequests(appointmentID: Int) {
            rescheduleRequests.removeAll { $0.appointmentID == appointmentID }
        }
        
        // Remove related appointment requests
        private func removeAppointmentRequests(appointment: Appointment) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let dateString = dateFormatter.string(from: appointment.date)
            
            appointmentRequests.removeAll { request in
                request.patientID == appointment.patientID &&
                request.date == dateString &&
                request.time == appointment.time
            }
        }
        
        // Send cancellation notification
        private func sendCancellationNotification(appointment: Appointment, reason: String? = nil) {
            // Create a chat message to notify the physiotherapist
            let cancellationMessage = buildCancellationMessage(appointment: appointment, reason: reason)
            
            // Add the cancellation notification as a chat message
            addChatMessage(
                senderID: appointment.patientID,
                receiverID: appointment.physiotherapistID,
                message: cancellationMessage,
                senderName: appointment.patientName
            )
        }
        
        // Build a cancellation message with optional reason
        private func buildCancellationMessage(appointment: Appointment, reason: String? = nil) -> String {
            var message = "Appointment Cancellation: \(appointment.patientName) has cancelled the appointment scheduled for \(formatDate(appointment.date)) at \(appointment.time)"
            
            if let cancellationReason = reason {
                message += "\n\nReason: \(cancellationReason)"
            }
            
            return message
        }
        
//        // Format date for messages
//        private func formatDate(_ date: Date) -> String {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd MMM yyyy"
//            return formatter.string(from: date)
//        }
    }

    // New extension for additional appointment-related functionality
extension AnkleHealDataModel {
    // Retrieve the most recent appointment for a patient
    func getLatestAppointment(for patientID: Int) -> Appointment? {
        guard let patient = patients[patientID] else { return nil }
        
        return patient.appointmentHistory
            .filter { $0.status && $0.date <= Date() } // Confirmed past appointments
            .max(by: { $0.date < $1.date })
    }
    
    // Get upcoming appointments for a patient
    func getUpcomingPatientAppointments(patientID: Int) -> [Appointment] {
        guard let patient = patients[patientID] else { return [] }
        
        return patient.appointmentHistory
            .filter { $0.status && $0.date > Date() } // Confirmed future appointments
            .sorted { $0.date < $1.date }
    }
    
    // Check if patient has any active appointments
    func hasActiveAppointments(patientID: Int) -> Bool {
        return !getUpcomingPatientAppointments(patientID: patientID).isEmpty
    }
    
    // Soft cancel - mark as inactive without full removal
    func softCancelAppointment(appointmentID: Int) -> Bool {
        var appointmentFound = false
        
        // Update in patient's history
        for (patientID, var patient) in patients {
            if let index = patient.appointmentHistory.firstIndex(where: { $0.appointmentID == appointmentID }) {
                patient.appointmentHistory[index].status = false
                patients[patientID] = patient
                appointmentFound = true
            }
        }
        
        // Update in physiotherapist's appointments
        for (physiotherapistID, var physiotherapist) in physiotherapists {
            if let index = physiotherapist.appointments.firstIndex(where: { $0.appointmentID == appointmentID }) {
                physiotherapist.appointments[index].status = false
                physiotherapists[physiotherapistID] = physiotherapist
                appointmentFound = true
            }
        }
        
        // Notify observers
        objectWillChange.send()
        
        return appointmentFound
    }
}
