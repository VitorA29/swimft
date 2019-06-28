import Foundation

/// - Define the enumeration for the error that can be throw during reference nodes handling.
public enum ReferenceHandlerError: Error
{
	case ExpectedLocationValue
}

/// - This defines the generic pi node for the references pi nodes.
public protocol ReferencePiNode: ExpressionPiNode
{
	var identifier: IdentifierPiNode { get }
}

/// - This defines the pi node for the address reference pi node.
public struct AddressReferencePiNode: ReferencePiNode
{
	public let identifier: IdentifierPiNode
	public var description: String
	{
		return "DeRef(\(identifier))"
	}
}

/// - This defines the pi node for the value reference pi node.
public struct ValueReferencePiNode: ReferencePiNode, ArithmeticExpressionPiNode, LogicalExpressionPiNode
{
	public let identifier: IdentifierPiNode
	public var description: String
	{
		return "ValRef(\(identifier))"
	}
}

/// Addition of the handlers for the reference
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a address reference operation.
	/// 	Here the below delta match will occur.
	/// 	δ(DeRef(Id(W)) :: C, V, E, S, L) = δ(C, l :: V, E, S, L), where l = E[W]
	func processAddressReferencePiNode (node: AddressReferencePiNode, valueStack: Stack<AutomatonValue>, environment: [String: AutomatonBindable]) throws
	{
		let identifier: IdentifierPiNode = node.identifier
		let location: Location = try getLocationFromEnvironment(key: identifier.name, environment: environment)
		valueStack.push(value: location)
	}

	/// - Handler for the analysis of a node contening a value reference operation.
	/// 	Here the below delta match will occur.
	/// 	δ(ValRef(Id(W)) :: C, V, E, S, L) = δ(C, T :: V, E, S, L), where T = S[S[E[W]]]
	func processValueReferencePiNode (node: ValueReferencePiNode, valueStack: Stack<AutomatonValue>, storage: [Int: AutomatonStorable], environment: [String: AutomatonBindable]) throws
	{
		let identifier: IdentifierPiNode = node.identifier
		let location: Location = try getLocationFromEnvironment(key: identifier.name, environment: environment)
		let addressLocation: Location = try getLocationFromStorage(address: location.address, storage: storage)
		let storable: AutomatonStorable = try getStorableValueFromStorage(address: addressLocation.address, storage: storage)
		valueStack.push(value: storable)
	}

	/// - Helper function for getting a location value from the environment for the given key.
	func getLocationFromEnvironment (key: String, environment: [String: AutomatonBindable]) throws -> Location
	{
		let locationHelper: AutomatonBindable = try getBindableValueFromEnvironment(key: key, environment: environment)
		if !(locationHelper is Location)
		{
			throw ReferenceHandlerError.ExpectedLocationValue
		}
		return locationHelper as! Location
	}

	/// - Helper function for getting a location value from the storage for the given address.
	func getLocationFromStorage (address: Int, storage: [Int: AutomatonStorable]) throws -> Location
	{
		let locationHelper: AutomatonStorable = try getStorableValueFromStorage(address: address, storage: storage)
		if !(locationHelper is Location)
		{
			throw ReferenceHandlerError.ExpectedLocationValue
		}
		return locationHelper as! Location
	}
}
