import Foundation

/// - Define the enumeration for the error that can be throw during call node handling.
public enum CallHandlerError: Error
{
	case MissingParametersInCall
    case ExpectedFunctionIdentifier
}


/// - This defines the pi node for the call operation, this is a concept for the closures.
public struct CallPiNode: CommandPiNode
{
	let identifier: IdentifierPiNode
	let actualList: [ExpressionPiNode]
	public var description: String
	{
		return "Call(\(identifier), [\(actualList) - \(actualList.count)])"
	}
}

/// - This defines the pi automaton operation code for the call operation.
public struct CallOperationCode: OperationCode
{
	public let code: String = "CALL"
    let identifier: IdentifierPiNode
    public var description: String
    {
        return "#\(code)(\(identifier))"
    }
}

/// - This defines the closure bindable node
public protocol ClosurePiNode: AutomatonBindable
{
	var formalList: [IdentifierPiNode] { get }
	var block: BlockPiNode { get }
    var environment: [String: AutomatonBindable] { get }
}

public struct ClosurePiNodeImpl: ClosurePiNode
{
    public let formalList: [IdentifierPiNode]
	public let block: BlockPiNode
    public let environment: [String: AutomatonBindable]
    public var description: String
	{
		return "Closure([\(formalList) - \(formalList.count)], \(block), \(environment))"
	}
}

/// - This defines the recusive closure bindable node
public struct RecursiveClosurePiNode: ClosurePiNode
{
    public let formalList: [IdentifierPiNode]
	public let block: BlockPiNode
    public let environment: [String: AutomatonBindable]
    var recursiveEnvironment: [String: AutomatonBindable]
    public var description: String
	{
		return "Rec([\(formalList) - \(formalList.count)], \(block), \(environment), \(recursiveEnvironment))"
	}
}

/// Addition of the handlers for the declaration operations.
public extension PiFrameworkHandler
{
    /// - Handler for the analysis of a node contening a call operation.
    /// 	Here the below delta match will occur.
    ///     δ(Call(W, [X₁, X₂, ..., Xᵤ])) :: C, V, E, S, L) = δ(Xᵤ :: Xᵤ₋₁ :: ... :: X₁ :: #CALL(W, u) :: C, V, E, S, L)
    func processCallPiNode (node: CallPiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
    {
        controlStack.push(value: CallOperationCode(identifier: node.identifier))
        for actual in node.actualList
        {
            controlStack.push(value: actual)
        }
    }

    /// - Handler for the analysis of the operation relative to a call operation.
    /// 	Here the below delta match will occur.
    ///     δ(#CALL(W, u) ::C, V₁ :: V₂ :: ... :: Vᵤ :: V, E, S, L) = δ(B :: #BLKCMD :: C, E :: V, E', S, L)
    ///     where E = {W ↦ Closure(F, B, E₁)} ∪ E₂, E'= E₁ / match(F, [V₁, V₂, ..., Vᵤ])
    ///     where E = {W ↦ Rec(F, B, E₁, E₂)} ∪ E₃, E'= E₁ / unfold(E₂) / match(F, [V₁, V₂, ..., Vᵤ])
    func processCallOperationCode (code: CallOperationCode, controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>, environment: inout [String: AutomatonBindable]) throws
    {
        // get the closure from the environment
        let bindableHelper: AutomatonBindable = try getBindableValueFromEnvironment(key: code.identifier.name, environment: environment)
        if !(bindableHelper is ClosurePiNode)
        {
            throw CallHandlerError.ExpectedFunctionIdentifier
        }
        let closure: ClosurePiNode = bindableHelper as! ClosurePiNode

        // get the parameters values from the value stack and make the association between formal and actual
        var associatedEnv: [String: AutomatonBindable] = [String: AutomatonBindable]()
        for formal in closure.formalList
        {
            do
            {
                associatedEnv[formal.name] = try popBindableValue(valueStack: valueStack)
            }
            catch
            {
                throw CallHandlerError.MissingParametersInCall
            }
        }

        // push the function body into the control stack
        controlStack.push(value: BlockCommandOperationCode())
        controlStack.push(value: closure.block)
        valueStack.push(value: LocationCollection(collection: [Location]()))

        // push the old environment into the value stack
        let oldEnvironment: EnvironmentCollection = EnvironmentCollection(collection: environment)
        valueStack.push(value: oldEnvironment)

        // create the new environment for the call
        environment = closure.environment
        environment.merge(associatedEnv) { (_, new) in new }

        // add the recursive call in the environment if it's a recursive closure
        if closure is RecursiveClosurePiNode
        {
            let recursiveClosure: RecursiveClosurePiNode = closure as! RecursiveClosurePiNode
            environment.merge(try unfold(environment: recursiveClosure.recursiveEnvironment)) { (_, new) in new }
        }
    }

    /// - Function for dealing with the recursive closure handling
    func unfold(environment: [String: AutomatonBindable]) throws -> [String: AutomatonBindable]
    {
        let environment: [String: AutomatonBindable] = try reclose(baseEnvironment: environment, entry: environment)
        return environment
    }

    /// - Function for dealing with the recursive closure handling
    func reclose(baseEnvironment: [String: AutomatonBindable], entry: [String: AutomatonBindable]) throws -> [String: AutomatonBindable]
    {
        if entry.count == 1
        {
            for (key, value) in entry
            {
                var resultValue: AutomatonBindable = value
                if value is RecursiveClosurePiNode
                {
                    var resultHelper: RecursiveClosurePiNode = resultValue as! RecursiveClosurePiNode
                    resultHelper.recursiveEnvironment = baseEnvironment
                }
                else if value is ClosurePiNodeImpl
                {
                    let resultHelper: ClosurePiNodeImpl = resultValue as! ClosurePiNodeImpl
                    resultValue = RecursiveClosurePiNode(formalList: resultHelper.formalList, block: resultHelper.block, environment: resultHelper.environment, recursiveEnvironment: baseEnvironment)
                }
                return [key: resultValue]
            }
        }
        else
        {
            var resultEnvironment: [String: AutomatonBindable] = [String: AutomatonBindable]()
            for (key, value) in entry
            {
                resultEnvironment.merge(try reclose(baseEnvironment: baseEnvironment, entry: [key: value])) { (_, new) in new }
            }
            return resultEnvironment
        }
        throw GenericError.InvalidArgument
    }
}
