import Foundation

// MARK: - Vocabulary Model

struct Vocabulary: Codable, Identifiable {
    let id = UUID()
    let word: String
    let translation: String
    let partOfSpeech: String
    let difficulty: DifficultyLevel
    
    enum CodingKeys: String, CodingKey {
        case word
        case translation
        case partOfSpeech = "partOfSpeech"
        case difficulty
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(String.self, forKey: .word)
        translation = try container.decode(String.self, forKey: .translation)
        partOfSpeech = try container.decode(String.self, forKey: .partOfSpeech)
        
        let difficultyString = try container.decode(String.self, forKey: .difficulty)
        difficulty = DifficultyLevel(rawValue: difficultyString) ?? .medium
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encode(translation, forKey: .translation)
        try container.encode(partOfSpeech, forKey: .partOfSpeech)
        try container.encode(difficulty.rawValue, forKey: .difficulty)
    }
}

enum DifficultyLevel: String, Codable {
    case easy
    case medium
    case hard
}

// MARK: - Vocabulary Container

struct VocabularyData: Codable {
    let vocabulary: [Vocabulary]
}

// MARK: - Number Model

struct BisayaNumber: Codable, Identifiable {
    let id: Int
    let value: Int
    let bisaya: String
    
    enum CodingKeys: String, CodingKey {
        case value
        case bisaya
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Int.self, forKey: .value)
        bisaya = try container.decode(String.self, forKey: .bisaya)
        id = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(bisaya, forKey: .bisaya)
    }
}

// MARK: - Numbers Container

struct NumbersData: Codable {
    let numbers: [BisayaNumber]
}
