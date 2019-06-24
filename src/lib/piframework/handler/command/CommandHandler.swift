public protocol CommandPiNode: AbstractSyntaxTreePi
{
}

public struct CommandSequencePiNode: CommandPiNode
{
    let lhs: CommandPiNode
    let rhs: CommandPiNode
    public var description: String
	{
		return "CSeq(\(lhs), \(rhs))"
	}
}

public protocol ExpressionPiNode: CommandPiNode
{
}

public struct NoOperationPiNode: CommandPiNode
{
    public var description: String
    {
        return "NOp()"
    }
}

public extension PiFrameworkHandler
{
    func processNoOperationPiNode ()
    {
        // just skip this node, since it's the no operation node
    }

    func processCommandSequencePiNode (node: CommandSequencePiNode, controlStack: Stack<AbstractSyntaxTreePiExtended>)
    {
        controlStack.push(value: node.rhs)
        controlStack.push(value: node.lhs)
    }
}