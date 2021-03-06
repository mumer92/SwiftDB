//
// Copyright (c) Vatsal Manot
//

import CoreData
import Swallow
import Task

extension _CoreData {
    public struct DatabaseObject {
        public struct ID: Hashable {
            let base: NSManagedObjectID
            
            init(base: NSManagedObjectID) {
                self.base = base
            }
        }
        
        let base: NSManagedObject
        
        init(base: NSManagedObject) {
            self.base = base
        }
    }
}

extension _CoreData.DatabaseObject: DatabaseObject {
    public var isInitialized: Bool {
        base.managedObjectContext != nil
    }
    
    public var allKeys: [CodingKey] {
        base.entity.attributesByName.map({ AnyStringKey(stringValue: $0.key) })
    }
    
    public func contains(_ key: CodingKey) -> Bool {
        base.entity.attributesByName[key.stringValue] != nil
    }
    
    public func containsValue(forKey key: CodingKey) -> Bool {
        base.primitiveValueExists(forKey: key.stringValue)
    }
    
    public func setValue<Value: PrimitiveAttributeDataType>(_ value: Value, forKey key: CodingKey) throws {
        base.setValue(value, forKey: key.stringValue)
    }
    
    public func encode<Value>(_ value: Value, forKey key: CodingKey) throws {
        if let value = value as? NSAttributeCoder {
            try value.encodePrimitive(to: base, forKey: AnyCodingKey(key))
        } else if let value = value as? Codable {
            try value.encode(to: self, forKey: AnyCodingKey(key))
        }
    }
    
    fileprivate enum DecodingError: Error {
        case some
    }
    
    public func decode<Value>(_ valueType: Value.Type, forKey key: CodingKey) throws -> Value {
        if let valueType = valueType as? NSPrimitiveAttributeCoder.Type {
            return try valueType.decode(from: base, forKey: AnyCodingKey(key)) as! Value
        } else if let valueType = valueType as? NSAttributeCoder.Type {
            return try valueType.decode(from: base, forKey: AnyCodingKey(key)) as! Value
        } else if let valueType = valueType as? Codable.Type {
            return try valueType.decode(from: self, forKey: key) as! Value
        } else {
            throw DecodingError.some
        }
    }
}

// MARK: - Auxiliary Implementation -

fileprivate extension Decodable where Self: Encodable {
    static func decode(from object: _CoreData.DatabaseObject, forKey key: CodingKey) throws -> Self {
        return try _CodableToNSAttributeCoder<Self>.decode(
            from: object.base,
            forKey: AnyCodingKey(key)
        )
        .value
    }
    
    func encode(to object: _CoreData.DatabaseObject, forKey key: CodingKey) throws  {
        try _CodableToNSAttributeCoder<Self>(self).encode(
            to: object.base,
            forKey: AnyCodingKey(key)
        )
    }
}
