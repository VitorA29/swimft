import Foundation

public enum ReferenceHandlerError: Error
{
	case ExpectedLocationValue
}

public struct AddressReferencePiNode: ExpressionPiNode
{
	let identifier: IdentifierPiNode
	public var description: String
	{
		return "DeRef(\(identifier))"
	}
}

public struct ValueReferencePiNode: ArithmeticExpressionPiNode, LogicalExpressionPiNode
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
		let storable: AutomatonStorable = try getStorableValueFromStorage(address: addressLocale.address, storage: storage)
		valueStack.push(value: storable)
	}

	func getLocationFromEnvironment (key: String, environment: [String: AutomatonBindable]) throws -> Location
	{
		let locationHelper: AutomatonBindable = try getBindableValueFromEnvironment(key: key, environment: environment)
		if !(locationHelper is Location)
		{
			throw ReferenceHandlerError.ExpectedLocationValue
		}
		return locationHelper as! Location
	}

	func getLocationFromStorage (key: Int, storage: [Int: AutomatonStorable]) throws -> Location
	{
		let locationHelper: AutomatonStorable = try getStorableValueFromStorage(address: key, storage: storage)
		if !(locationHelper is Location)
		{
			throw ReferenceHandlerError.ExpectedLocationValue
		}
		return locationHelper as! Location
	}
}
