public protocol DeclarationPiNode: AbstractSyntaxTreePi
{
}

public struct DeclarationSequencePiNode: DeclarationPiNode
{
    let lhs: DeclarationPiNode
    let rhs: DeclarationPiNode
    public var description: String
	{
		return "DSeq(\(lhs), \(rhs))"
	}
}

public struct BindableOperationPiNode: DeclarationPiNode
{
    let identifier: IdentifierPiNode
    let expression: ExpressionPiNode
    public var description: String
	{
		return "Bind(\(identifier), \(expression))"
	}
}

public struct AllocateReferencePiNode: ExpressionPiNode
{
	let expression: ExpressionPiNode
	public var description: String
	{
		return "Ref(\(expression))"
	}
}

public struct BindableOperationCode: OperationCode
{
	public let code: String = "BIND"
}

public struct AllocateReferenceOperationCode: OperationCode
{
	public let code: String = "REF"
}

public extension PiFrameworkHandler
{
	func processBindableOperationPiNode (node: BindableOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: BindableOperationCode())
		valueStack.push(value: node.identifier)
		controlStack.push(value: node.expression)
	}

	func processBindableOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let bindable: AutomatonBindable = try popBindableValue(valueStack: valueStack)
		let identifier: String = try popIdValue(valueStack: valueStack)
		var environmentCollection: EnvironmentCollection
		if !valueStack.isEmpty() && valueStack.peek() is EnvironmentCollection
		{
			environmentCollection = valueStack.pop() as! EnvironmentCollection
		}
		else
		{
			environmentCollection = EnvironmentCollection()
		}
		environmentCollection.add(key: identifier, value: bindable)
		valueStack.push(value: environmentCollection)
	}

	func processAllocateReferencePiNode (node: AllocateReferencePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
	{
		controlStack.push(value: AllocateReferenceOperationCode())
		controlStack.push(value: node.expression)
	}

	func processAllocateReferenceOperationCode (valueStack: Stack<AutomatonValue>, memoryPosition: inout Int, storage: inout [Int: AutomatonStorable], locationList: inout [Location]) throws
	{
		let storable: AutomatonStorable = try popStorableValue(valueStack: valueStack)
		let location: Location = Location(address: memoryPosition)
		memoryPosition += 1

		storage[location.address] = storable
		locationList.append(location)
		valueStack.push(value: location)
	}

	func processDeclarationSequencePiNode (node: DeclarationSequencePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
    {
        controlStack.push(value: node.rhs)
        controlStack.push(value: node.lhs)
    }
}