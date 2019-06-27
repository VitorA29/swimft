public protocol AtomicPiNode: AbstractSyntaxTreePi
{
}

public struct IdentifierPiNode: AtomicPiNode, ArithmeticExpressionPiNode, LogicalExpressionPiNode, AutomatonValue
{
    let name: String
    public var description: String
	{
		return "Id(\(name))"
	}
}

public struct NumberPiNode: AtomicPiNode, ArithmeticExpressionPiNode
{
    let value: Float
    public var description: String
	{
		return "Num(\(value))"
	}
}

public struct LogicalClassificationPiNode: AtomicPiNode, LogicalExpressionPiNode
{
    let value: Bool
    public var description: String
	{
		return "Boo(\(value))"
	}
}

extension Float: AutomatonValue, AutomatonBindable, AutomatonStorable
{
}

extension Bool: AutomatonValue, AutomatonBindable, AutomatonStorable
{
}

public extension PiFrameworkHandler
{
	func processIdentifierPiNode (node: IdentifierPiNode, valueStack: Stack<AutomatonValue>, storage: [Int: AutomatonStorable], environment: [String: AutomatonBindable]) throws
	{
		let bindable: AutomatonBindable = try getBindableValueFromEnvironment(key: node.name, environment: environment)
		if bindable is Location
		{
			let location: Location = bindable as! Location
			let storageValue: AutomatonStorable = try getStorableValueFromStorage(address: location.address, storage: storage)
			valueStack.push(value: storageValue)
		}
		else
		{
			valueStack.push(value: bindable)
		}
	}

	func processNumberPiNode (node: NumberPiNode, valueStack: Stack<AutomatonValue>) throws
	{
		valueStack.push(value: node.value)
	}

	func processLogicalClassificationPiNode (node: LogicalClassificationPiNode, valueStack: Stack<AutomatonValue>) throws
	{
		valueStack.push(value: node.value)
	}
}