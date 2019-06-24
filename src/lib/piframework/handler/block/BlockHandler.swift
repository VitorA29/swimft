import Foundation

public enum BlockHandlerError: Error
{
	case ExpectedEnvironmentCollection
    case ExpectedLocationCollection
}

public struct BlockPiNode: CommandPiNode
{
    let declaration: DeclarationPiNode
    let command: CommandPiNode
    public var description: String
    {
        return "Blk(\(declaration), \(command))"
    }
}

public struct BlockCommandOperationCode: OperationCode
{
	public let code: String = "BLKCMD"
}

public struct BlockDeclarationOperationCode: OperationCode
{
	public let code: String = "BLKDEC"
}

public extension PiFrameworkHandler
{
    func processBlockPiNode (node: BlockPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>, locationList: inout [Location])
    {
        controlStack.push(value: BlockCommandOperationCode())
        controlStack.push(value: node.command)
        controlStack.push(value: BlockDeclarationOperationCode())
        controlStack.push(value: node.declaration)
        let locationCollection: LocationCollection = LocationCollection(collection: locationList)
        locationList = [Location]()
        valueStack.push(value: locationCollection)
    }

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

    func processBlockDeclarationOperationCode (valueStack: Stack<AutomatonValue>, environment: inout [String: AutomatonBindable]) throws
    {
        let oldEnvironment: EnvironmentCollection = EnvironmentCollection(collection: environment)
        let environmentCollection: EnvironmentCollection = try popEnvironmentCollectionValue(valueStack: valueStack)
        environment.merge(environmentCollection.getCollection()) { (_, new) in new }
        valueStack.push(value: oldEnvironment)
    }
    
    func popEnvironmentCollectionValue (valueStack: Stack<AutomatonValue>) throws -> EnvironmentCollection
    {
        if valueStack.isEmpty() || !(valueStack.peek() is EnvironmentCollection)
		{
			throw BlockHandlerError.ExpectedEnvironmentCollection
		}
        return valueStack.pop() as! EnvironmentCollection
    }

    func popLocationCollectionValue (valueStack: Stack<AutomatonValue>) throws -> LocationCollection
    {
        if valueStack.isEmpty() || !(valueStack.peek() is LocationCollection)
		{
			throw BlockHandlerError.ExpectedLocationCollection
		}
        return valueStack.pop() as! LocationCollection
    }
}
