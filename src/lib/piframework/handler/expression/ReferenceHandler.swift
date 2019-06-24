import Foundation

public enum ReferenceHandlerError: Error
{
	case ExpectedLocationValue
	case ExpectedStorableValue
}

public struct AddressReferencePiNode: ExpressionPiNode
{
	let identifier: IdentifierPiNode
	public var description: String
	{
		return "DeRef(\(identifier))"
	}
}

public struct ValueReferencePiNode: ExpressionPiNode
{
	let identifier: IdentifierPiNode
	public var description: String
	{
		return "ValRef(\(identifier))"
	}
}

public extension PiFrameworkHandler
{
	func processAddressReferencePiNode (node: AddressReferencePiNode, valueStack: Stack<AutomatonValue>, environment: [String: AutomatonBindable]) throws
	{
		let identifier: IdentifierPiNode = node.identifier
		let location: Location = try getLocationFromEnvironment(key: identifier.name, environment: environment)
		valueStack.push(value: location)
	}

	func processValueReferencePiNode (node: ValueReferencePiNode, valueStack: Stack<AutomatonValue>, storage: [Int: AutomatonStorable], environment: [String: AutomatonBindable]) throws
	{
		let identifier: IdentifierPiNode = node.identifier
		let location: Location = try getLocationFromEnvironment(key: identifier.name, environment: environment)
		let addressLocale: Location = try getLocationFromStorage(key: location.address, storage: storage)
		if storage[addressLocale.address] == nil
		{
			throw ReferenceHandlerError.ExpectedStorableValue
		}
		valueStack.push(value: storage[addressLocale.address]!)
	}

	func getLocationFromEnvironment (key: String, environment: [String: AutomatonBindable]) throws -> Location
	{
		if environment[key] == nil || !(environment[key] is Location)
		{
			throw ReferenceHandlerError.ExpectedLocationValue
		}
		return environment[key]! as! Location
	}

	func getLocationFromStorage (key: Int, storage: [Int: AutomatonStorable]) throws -> Location
	{
		if storage[key] == nil || !(storage[key] is Location)
		{
			throw ReferenceHandlerError.ExpectedLocationValue
		}
		return storage[key]! as! Location
	}
}
