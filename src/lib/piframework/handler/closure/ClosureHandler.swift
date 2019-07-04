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
    let count: Int
    public var description: String
    {
        return "#\(code)(\(identifier), \(count))"
    }
}

/// - This defines the closure bindable node
public struct ClosurePiNode: AutomatonBindable
{
	let formalList: [IdentifierPiNode]
	let block: BlockPiNode
    let environment: [String: AutomatonBindable]
    public var description: String
	{
		return "Closure([\(formalList) - \(formalList.count)], \(block), \(environment))"
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
        controlStack.push(value: CallOperationCode(identifier: node.identifier, count: node.actualList.count))
        for actual in node.actualList
        {
            controlStack.push(value: actual)
        }
    }

    /// - Handler for the analysis of the operation relative to a call operation.
    /// 	Here the below delta match will occur.
    ///     δ(#CALL(W, u) ::C, V₁ :: V₂ :: ... :: Vᵤ :: V, E, S, L) = δ(B :: #BLKCMD :: C, E :: V, E', S, L)
    ///     where E = {W ↦ Closure(F, B, E₁)} ∪ E₂, E'= E₁ / match(F, [V₁, V₂, ..., Vᵤ])
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
    }
}
