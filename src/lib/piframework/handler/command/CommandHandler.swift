/// - This defines the pi node for all pi commands.
public protocol CommandPiNode: AbstractSyntaxTreePi
{
}

/// - This defines the pi node for the pi command sequence operation.
public struct CommandSequencePiNode: CommandPiNode
{
    let lhs: CommandPiNode
    let rhs: CommandPiNode
    public var description: String
	{
		return "CSeq(\(lhs), \(rhs))"
	}
}

/// - This defines the pi node for all pi expressions.
public protocol ExpressionPiNode: CommandPiNode
{
}

/// - This defines the pi node for the pi no operation.
public struct NoOperationPiNode: CommandPiNode
{
    public var description: String
    {
        return "NOp()"
    }
}

/// Addition of the handlers for the basic command operations.
public extension PiFrameworkHandler
{
    /// - Handler for the analysis of a node contening a no operation.
	/// 	Here the below delta match will occur.
	/// 	δ(Nop() :: C, V, E, S, L) = δ(C, V, E, S, L)
    func processNoOperationPiNode ()
    {
        // just skip this node, since it's the no operation node
    }

    /// - Handler for the analysis of a node contening a command sequence operation.
	/// 	Here the below delta match will occur.
	/// 	δ(CSeq(M₁, M₂) :: C, V, E, S, L) = δ(M₁ :: M₂ :: C, V, E, S, L)
    func processCommandSequencePiNode (node: CommandSequencePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
    {
        controlStack.push(value: node.rhs)
        controlStack.push(value: node.lhs)
    }
}