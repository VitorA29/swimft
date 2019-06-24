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
		if environment[node.name] == nil
		{
			throw AutomatonHandlerError.ExpectedBindableValue
		}
		if environment[node.name]! is Location
		{
			let location: Location = environment[node.name]! as! Location
			if storage[location.address] == nil
			{
				throw AutomatonHandlerError.ExpectedStorableValue
			}
			valueStack.push(value: storage[location.address]!)
		}
		else
		{
			valueStack.push(value: environment[node.name]!)
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