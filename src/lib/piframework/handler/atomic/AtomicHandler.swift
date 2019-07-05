/// - This defines the pi node for the pi identifier operation.
public struct IdentifierPiNode: ArithmeticExpressionPiNode, LogicalExpressionPiNode, AutomatonValue
{
    let name: String
    public var description: String
	{
		return "Id(\(name))"
	}
}

/// - This defines the pi node for the pi number operation.
public struct NumberPiNode: ArithmeticExpressionPiNode
{
    let value: Float
    public var description: String
	{
		return "Num(\(value))"
	}
}

/// - This defines the pi node for the pi logical classification operation.
public struct LogicalClassificationPiNode: LogicalExpressionPiNode
{
    let value: Bool
    public var description: String
	{
		return "Boo(\(value))"
	}
}

/// - Extends the float for being accepted in the pi framework as the number pi node unwrapping.
extension Float: AutomatonBindable, AutomatonStorable
{
}

/// - Extends the bool for being accepted in the pi framework as the logical classificarion pi node unwrapping.
extension Bool: AutomatonBindable, AutomatonStorable
{
}

/// Addition of the handlers for the pi framework atomic values.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a identifier.
	/// 	Here the below delta match will occur.
	/// 	δ(Id(W) :: C, V, E, S, L) = δ(T :: C, W :: V, E, S, L), T = S[E[W]]
	/// 	δ(Id(W) :: C, V, E, S, L) = δ(V :: C, W :: V, E, S, L), V = E[W]
	func processIdentifierPiNode (node: IdentifierPiNode, valueStack: Stack<AutomatonValue>, storage: [Int: AutomatonStorable], environment: [String: AutomatonBindable]) throws
	{
		let bindable: AutomatonBindable = try getBindableValueFromEnvironment(key: node.name, environment: environment)
		if bindable is Location
		{
			let location: Location = bindable as! Location
			let storable: AutomatonStorable = try getStorableValueFromStorage(address: location.address, storage: storage)
			valueStack.push(value: storable)
		}
		else
		{
			valueStack.push(value: bindable)
		}
	}

	/// - Handler for the analysis of a node contening a number.
	/// 	Here the below delta match will occur.
	/// 	δ(Num(N) :: C, V, E, S, L) = δ(N :: C, W :: V, E, S, L)
	func processNumberPiNode (node: NumberPiNode, valueStack: Stack<AutomatonValue>)
	{
		valueStack.push(value: node.value)
	}

	/// - Handler for the analysis of a node contening a boo.
	/// 	Here the below delta match will occur.
	/// 	δ(Boo(B) :: C, V, E, S, L) = δ(B :: C, W :: V, E, S, L)
	func processLogicalClassificationPiNode (node: LogicalClassificationPiNode, valueStack: Stack<AutomatonValue>)
	{
		valueStack.push(value: node.value)
	}
}