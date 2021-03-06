/// - This defines the pi node for all pi declarations.
public protocol DeclarationPiNode: AbstractSyntaxTreePi
{
}

/// - This defines the pi node for the pi declaration sequence operation.
public struct DeclarationSequencePiNode: DeclarationPiNode
{
    let lhs: DeclarationPiNode
    let rhs: DeclarationPiNode
    public var description: String
	{
		return "DSeq(\(lhs), \(rhs))"
	}
}

// - This defines the pi nodes that can be associated in the environment to a identifier.
public protocol BindablePiNode: AbstractSyntaxTreePi
{
}

/// - This defines the pi node for the pi bindable operation.
public struct BindableOperationPiNode: DeclarationPiNode
{
    let identifier: IdentifierPiNode
    let expression: BindablePiNode
    public var description: String
	{
		return "Bind(\(identifier), \(expression))"
	}
}

/// - This defines the pi node for the pi recursive bindable operation.
public struct RecursiveBindableOperationPiNode: DeclarationPiNode
{
    let identifier: IdentifierPiNode
    let abstraction: AbstractionPiNode
    public var description: String
	{
		return "Rbnd(\(identifier), \(abstraction))"
	}
}

/// - This defines the pi node for the pi allocate reference operation.
public struct AllocateReferencePiNode: BindablePiNode
{
	let expression: ExpressionPiNode
	public var description: String
	{
		return "Ref(\(expression))"
	}
}

/// - This defines the pi node for the abstraction operation, this is a concept for the closures.
public struct AbstractionPiNode: BindablePiNode
{
	let formalList: [IdentifierPiNode]
	let block: BlockPiNode
	public var description: String
	{
		return "Abs([\(formalList) - \(formalList.count)], \(block))"
	}
}

/// - This defines the pi automaton operation code for the bindable operation.
public struct BindableOperationCode: OperationCode
{
	public let code: String = "BIND"
}

/// - This defines the pi automaton operation code for the allocate reference operation.
public struct AllocateReferenceOperationCode: OperationCode
{
	public let code: String = "REF"
}

/// Addition of the handlers for the declaration operations.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a bindable operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Bind(Id(W), X) :: C, V, E, S, L) = δ(X :: #BIND :: C, Id(W) :: V, E, S, L)
	func processBindableOperationPiNode (node: BindableOperationPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>)
	{
		controlStack.push(value: BindableOperationCode())
		valueStack.push(value: node.identifier)
		controlStack.push(value: node.expression)
	}

	/// - Handler for perform the relative bindable operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#BIND :: C, B :: W :: E' :: V, E, S, L) = δ(C, ({W ↦ B} ∪ E') :: V, E, S, L), where E' ∈ Env,
	/// 	δ(#BIND :: C, B :: W :: H :: V, E, S, L) = δ(C, {W ↦ B} :: H :: V, E, S, L), where H ∉ Env
	func processBindableOperationCode (valueStack: Stack<AutomatonValue>) throws
	{
		let bindable: AutomatonBindable = try popBindableValue(valueStack: valueStack)
		let identifier: String = try popIdValue(valueStack: valueStack)
		let environmentCollection: EnvironmentCollection = try getOrCreateEnvironmentCollectionFromValueStack(valueStack: valueStack)
		environmentCollection.add(key: identifier, value: bindable)
		valueStack.push(value: environmentCollection)
	}

	/// - Get from the value stack or create a new enviroment collection.
	func getOrCreateEnvironmentCollectionFromValueStack (valueStack: Stack<AutomatonValue>) throws -> EnvironmentCollection
	{
		if !valueStack.isEmpty() && valueStack.peek() is EnvironmentCollection
		{
			return valueStack.pop() as! EnvironmentCollection
		}
		else
		{
			return EnvironmentCollection()
		}
	}

	/// - Handler for the analysis of a node contening a allocate reference operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Ref(X) :: C, V, E, S, L) = δ(X :: #REF :: C, V, E, S, L)
	func processAllocateReferencePiNode (node: AllocateReferencePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
	{
		controlStack.push(value: AllocateReferenceOperationCode())
		controlStack.push(value: node.expression)
	}

	/// - Handler for perform the relative allocate reference operation.
	/// 	Here the below delta match will occur.
	/// 	δ(#REF :: C, T :: V, E, S, L) = δ(C, l :: V, E, S', L'), where S' = S ∪ [l ↦ T], l ∉ S, L' = L ∪ {l}
	func processAllocateReferenceOperationCode (valueStack: Stack<AutomatonValue>, memoryPosition: inout Int, storage: inout [Int: AutomatonStorable], locationList: inout [Location]) throws
	{
		let storable: AutomatonStorable = try popStorableValue(valueStack: valueStack)
		let location: Location = Location(address: memoryPosition)
		memoryPosition += 1

		storage[location.address] = storable
		locationList.append(location)
		valueStack.push(value: location)
	}

	/// - Handler for the analysis of a node contening a declaration sequence operation.
	/// 	Here the below delta match will occur.
	/// 	δ(DSeq(D₁, D₂) :: C, V, E, S, L) = δ(D₁ :: D₂ :: C, V, E, S, L)
	func processDeclarationSequencePiNode (node: DeclarationSequencePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
    {
        controlStack.push(value: node.rhs)
        controlStack.push(value: node.lhs)
    }

	/// - Handler for the analysis of a node contening a function creation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Abs(F, B) :: C, V, E, S, L) = δ(C, Closure(F, B, E) :: V, E, S, L)
	func processAbstractionPiNode (node: AbstractionPiNode, valueStack: Stack<AutomatonValue>, environment: [String: AutomatonBindable])
	{
		let closure: ClosurePiNode = ClosurePiNode(formalList: node.formalList, block: node.block, environment: environment)
		valueStack.push(value: closure)
	}

	/// - Handler for the analysis of a node contening a function creation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Rbnd(W, Abs(F, B)) :: C, E' :: V, E, S, L) = δ(C, ({unfold(W ↦ Closure(F, B, E)} ∪ E') :: V, E, S, L), where E' ∈ Env
    /// 	δ(Rbnd(W, Abs(F, B)) :: C, H :: V, E, S, L) = δ(C, {unfold(W ↦ Closure(F, B, E)} :: H :: V, E, S, L), where H ∉ Env
	func processRecursiveBindableOperationPiNode (node: RecursiveBindableOperationPiNode, valueStack: Stack<AutomatonValue>, environment: [String: AutomatonBindable]) throws
	{
		// process the abstraction pi node
		let abstraction: AbstractionPiNode = node.abstraction
		let closure: ClosurePiNode = ClosurePiNode(formalList: abstraction.formalList, block: abstraction.block, environment: environment)

		// add the new recursive closure to the environment collection
		let environmentCollection: EnvironmentCollection = try getOrCreateEnvironmentCollectionFromValueStack(valueStack: valueStack)
		let environmentEntry: [String: AutomatonBindable] = [node.identifier.name: closure]
		environmentCollection.add(entry: try unfold(environment: environmentEntry))
		valueStack.push(value: environmentCollection)
	}
}
