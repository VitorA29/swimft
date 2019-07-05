import Foundation

/// - Define the enumeration for the error that can be throw during block handling.
public enum BlockHandlerError: Error
{
	case ExpectedEnvironmentCollection
    case UnexpectedEmptyEnvironment
    case ExpectedLocationCollection
}

/// - This defines the pi node for the block pi node.
public struct BlockPiNode: CommandPiNode
{
    let declaration: DeclarationPiNode?
    let command: CommandPiNode
    public var description: String
    {
        if declaration == nil
        {
            return "Blk(nil, \(command))"
        }
        else
        {
            return "Blk(\(declaration!), \(command))"
        }
    }
}

/// - This defines the pi automaton operation code for the block declaration operation.
public struct BlockDeclarationOperationCode: OperationCode
{
    let empty: Bool
	public let code: String = "BLKDEC"
    public var description: String
    {
        return "#\(code)(\(empty))"
    }
}

/// - This defines the pi automaton operation code for the block command operation.
public struct BlockCommandOperationCode: OperationCode
{
	public let code: String = "BLKCMD"
}

/// Addition of the handlers for the block operation.
public extension PiFrameworkHandler
{
	/// - Handler for the analysis of a node contening a block creation operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Blk(D, M) :: C, V, E, S, L) = δ(D :: #BLKDEC :: M :: #BLKCMD :: C, L :: V, E, S, ∅)
    func processBlockPiNode (node: BlockPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>, locationList: inout [Location])
    {
        controlStack.push(value: BlockCommandOperationCode())
        controlStack.push(value: node.command)
        controlStack.push(value: BlockDeclarationOperationCode(empty: node.declaration == nil))
        controlStack.push(value: node.declaration)
        let locationCollection: LocationCollection = LocationCollection(collection: locationList)
        locationList = [Location]()
        valueStack.push(value: locationCollection)
    }

	/// - Handler for perform the relative operations for the block declarations operation code.
	/// 	Here the below delta match will occur.
	/// 	δ(#BLKDEC(False) :: C, E' :: V, E, S, L) = δ(C, E :: V, E / E', S, L)
    /// 	δ(#BLKDEC(True) :: C, V, E, S, L) = δ(C, E :: V, E, S, L)
    func processBlockDeclarationOperationCode (code: BlockDeclarationOperationCode, valueStack: Stack<AutomatonValue>, environment: inout [String: AutomatonBindable]) throws
    {
        let oldEnvironment: EnvironmentCollection = EnvironmentCollection(collection: environment)
        if !code.empty
        {
            let environmentCollection: EnvironmentCollection = try popEnvironmentCollectionValue(valueStack: valueStack)
            if environmentCollection.getCollection().count == 0
            {
                throw BlockHandlerError.UnexpectedEmptyEnvironment
            }
            environment.merge(environmentCollection.getCollection()) { (_, new) in new }
        }
        valueStack.push(value: oldEnvironment)
    }
    
	/// - Handler for perform the relative operations for the block commands operation code.
	/// 	Here the below delta match will occur.
	/// 	δ(#BLKCMD :: C, E :: L :: V, E', S, L') = δ(C, V, E, S', L), where S' = S / L'
    func processBlockCommandOperationCode (valueStack: Stack<AutomatonValue>, storage: inout [Int: AutomatonStorable], environment: inout [String: AutomatonBindable], locationList: inout [Location]) throws
    {
        let oldEnvironment: EnvironmentCollection = try popEnvironmentCollectionValue(valueStack: valueStack)
        environment = oldEnvironment.getCollection()
        
        let locationToRemove: [Location] = locationList
        let locationCollection: LocationCollection = try popLocationCollectionValue(valueStack: valueStack)
        locationList = locationCollection.getCollection()
        
        for location in locationToRemove
        {
            storage.removeValue(forKey: location.address)
        }
    }

    /// - Helper function for getting a environment collection from the value stack.
    func popEnvironmentCollectionValue (valueStack: Stack<AutomatonValue>) throws -> EnvironmentCollection
    {
        if valueStack.isEmpty() || !(valueStack.peek() is EnvironmentCollection)
		{
			throw BlockHandlerError.ExpectedEnvironmentCollection
		}
        return valueStack.pop() as! EnvironmentCollection
    }

    /// - Helper function for getting a location collection from the value stack.
    func popLocationCollectionValue (valueStack: Stack<AutomatonValue>) throws -> LocationCollection
    {
        if valueStack.isEmpty() || !(valueStack.peek() is LocationCollection)
		{
			throw BlockHandlerError.ExpectedLocationCollection
		}
        return valueStack.pop() as! LocationCollection
    }
}
