public class ImpTranslator: Translator
{
	let abstractSyntaxTreeImp: [CommandImpNode]

	/// #START_DOC
	/// - This class' constructor.
	/// #END_DOC
	required public init (ast: [AbstractSyntaxTree]) throws
	{
		if ast is [CommandImpNode]
		{
        	self.abstractSyntaxTreeImp = ast as! [CommandImpNode]
		}
		else
		{
			throw GenericError.InvalidArgument
		}
	}
	
	/// #START_DOC
	/// - Function for convert a abstract syntax tree of imp into it's correlative abstract syntax tree pi.
	/// #END_DOC
	public func translate () throws -> AbstractSyntaxTreePi
	{
		return try combineCommandImpNodes(forest: abstractSyntaxTreeImp)
	}

	private func translateCommandImpNode (node: CommandImpNode) throws -> CommandPiNode
	{
		if node is NoOpImpNode
		{
			return NoOperationPiNode()
		}
		else if node is AssignImpNode
		{
			return try translateAssignImpNode(node: node as! AssignImpNode)
		}
		else if node is WhileImpNode
		{
			return try translateWhileImpNode(node: node as! WhileImpNode)
		}
		else if node is ConditionalImpNode
		{
			return try translateConditionalImpNode(node: node as! ConditionalImpNode)
		}
		else if node is ExpressionImpNode
		{
			return try translateExpressionImpNode(node: node as! ExpressionImpNode)
		}
		else if node is BlockImpNode
		{
			return try translateBlockImpNode(node: node as! BlockImpNode)
		}
		else if node is PrintImpNode
		{
			return try translatePrintImpNode(node: node as! PrintImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

    /// #START_DOC
	/// - Helper function for combining a abstract syntax tree pi forest into a abstract syntax tree single pi node using CSeq.
	/// 	This converts the <cmd>+ into a single AbstractSyntaxTreePi node.
	/// #END_DOC
	private func combineCommandImpNodes (forest: [CommandImpNode]) throws -> CommandPiNode
	{
		let head: CommandPiNode = try translateCommandImpNode(node: forest[0])
		var tail: [CommandImpNode] = forest
		tail.remove(at: 0)
		if tail.isEmpty
		{
			return head
		}
		let rhs: CommandPiNode = try combineCommandImpNodes(forest: tail)
		return CommandSequencePiNode(lhs: head, rhs: rhs)
	}

	/// #START_DOC
	/// - Helper function for combining a pi forest node into a single pi node using DSeq.
	/// 	This converts the <dec>+ into a single AbstractSyntaxTreePi node.
	/// #END_DOC
	private func combineDeclarationImpNodes (forest: [DeclarationImpNode]) throws -> DeclarationPiNode
	{
		let head: DeclarationPiNode = try translateDeclarationImpNode(node: forest[0])
		var tail: [DeclarationImpNode] = forest
		tail.remove(at: 0)
		if tail.isEmpty
		{
			return head
		}
		let rhs: DeclarationPiNode = try combineDeclarationImpNodes(forest: tail)
		return DeclarationSequencePiNode(lhs: head, rhs: rhs)
	}

	private func translateAssignImpNode (node: AssignImpNode) throws -> AssignPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return AssignPiNode(identifier: identifier, expression: expression)
	}

	private func translateWhileImpNode (node: WhileImpNode) throws -> LoopPiNode
	{
		let condition: LogicalExpressionPiNode = try translateLogicalExpressionImpNode(node: node.condition)
		let command: CommandPiNode = try combineCommandImpNodes(forest: node.command)
		return LoopPiNode(condition: condition, command: command)
	}

	private func translateConditionalImpNode (node: ConditionalImpNode) throws -> ConditionalPiNode
	{
		let condition: LogicalExpressionPiNode = try translateLogicalExpressionImpNode(node: node.condition)
		let commandTrue: CommandPiNode = try combineCommandImpNodes(forest: node.commandTrue)
		var commandFalse: CommandPiNode? = nil
		if (!node.commandFalse.isEmpty)
		{
			commandFalse = try combineCommandImpNodes(forest: node.commandFalse)
		}
		return ConditionalPiNode(condition: condition, commandTrue: commandTrue, commandFalse: commandFalse)
	}

	private func translateExpressionImpNode (node: ExpressionImpNode) throws -> ExpressionPiNode
	{
		if node is LogicalExpressionImpNode
		{
			return try translateLogicalExpressionImpNode(node: node as! LogicalExpressionImpNode)
		}
		else if node is ReferenceImpNode
		{
			return try translateReferenceImpNode(node: node as! ReferenceImpNode)
		}
		else if node is ArithmeticExpressionImpNode
		{
			return try translateArithmeticExpressionImpNode(node: node as! ArithmeticExpressionImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	private func translateBlockImpNode (node: BlockImpNode) throws -> BlockPiNode
	{
		let declaration: DeclarationPiNode = try combineDeclarationImpNodes(forest: node.declaration)
		let command: CommandPiNode = try combineCommandImpNodes(forest: node.command)
		return BlockPiNode(declaration: declaration, command: command)
	}

	private func translatePrintImpNode (node: PrintImpNode) throws -> PrintPiNode
	{
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return PrintPiNode(expression: expression)
	}

	private func translateIdentifierImpNode (node: IdentifierImpNode) -> IdentifierPiNode
	{
		return IdentifierPiNode(name: node.name)
	}

	private func translateReferenceImpNode (node: ReferenceImpNode) throws -> ReferencePiNode
	{
		if node is AddressReferenceImpNode
		{
			return translateAddressReferenceImpNode(node: node as! AddressReferenceImpNode)
		}
		else if node is ValueReferenceImpNode
		{
			return translateValueReferenceImpNode(node: node as! ValueReferenceImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	private func translateLogicalExpressionImpNode (node: LogicalExpressionImpNode) throws -> LogicalExpressionPiNode
	{
		if node is IdentifierImpNode
		{
			return translateIdentifierImpNode(node: node as! IdentifierImpNode)
		}
		else if node is ValueReferenceImpNode
		{
			return translateValueReferenceImpNode(node: node as! ValueReferenceImpNode)
		}
		else if node is LogicalClassificationImpNode
		{
			return translateLogicalClassificationImpNode(node: node as! LogicalClassificationImpNode)
		}
		else if node is NegationImpNode
		{
			return try translateNegationImpNode(node: node as! NegationImpNode)
		}
		else if node is LogicalOperationImpNode
		{
			return try translateLogicalOperationImpNode(node: node as! LogicalOperationImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	private func translateArithmeticExpressionImpNode (node: ArithmeticExpressionImpNode) throws -> ArithmeticExpressionPiNode
	{
		if node is IdentifierImpNode
		{
			return translateIdentifierImpNode(node: node as! IdentifierImpNode)
		}
		else if node is ValueReferenceImpNode
		{
			return translateValueReferenceImpNode(node: node as! ValueReferenceImpNode)
		}
		else if node is NumberImpNode
		{
			return translateNumberImpNode(node: node as! NumberImpNode)
		}
		else if node is ArithmeticOperationImpNode
		{
			return try translateArithmeticOperationImpNode(node: node as! ArithmeticOperationImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	private func translateDeclarationImpNode (node: DeclarationImpNode) throws -> DeclarationPiNode
	{
		if node is VariableDeclarationImpNode
		{
			return try translateVariableDeclarationImpNode(node: node as! VariableDeclarationImpNode)
		}
		else if node is ConstantDeclarationImpNode
		{
			return try translateConstantDeclarationImpNode(node: node as! ConstantDeclarationImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	private func translateAddressReferenceImpNode (node: AddressReferenceImpNode) -> AddressReferencePiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		return AddressReferencePiNode(identifier: identifier)
	}
	
	private func translateValueReferenceImpNode (node: ValueReferenceImpNode) -> ValueReferencePiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		return ValueReferencePiNode(identifier: identifier)
	}

	private func translateLogicalClassificationImpNode (node: LogicalClassificationImpNode) -> LogicalClassificationPiNode
	{
		return LogicalClassificationPiNode(value: node.value)
	}

	private func translateNegationImpNode (node: NegationImpNode) throws -> NegationPiNode
	{
		let logicalExpression: LogicalExpressionPiNode = try translateLogicalExpressionImpNode(node: node.logicalExpression)
		return NegationPiNode(logicalExpression: logicalExpression)
	}

	private func translateNumberImpNode (node: NumberImpNode) -> NumberPiNode
	{
		return NumberPiNode(value: node.value)
	}

	private func translateLogicalOperationImpNode (node: LogicalOperationImpNode) throws  -> LogicalExpressionPiNode
	{
		if node is EqualityImpNode
		{
			return try translateEqualityImpNode(node: node as! EqualityImpNode)
		}
		else if node is LogicalConnectionImpNode
		{
			return try translateLogicalConnectionImpNode(node: node as! LogicalConnectionImpNode)
		}
		else if node is InequalityOperationImpNode
		{
			return try translateInequalityOperationImpNode(node: node as! InequalityOperationImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	private func translateArithmeticOperationImpNode (node: ArithmeticOperationImpNode) throws -> ArithmeticOperationPiNode
	{
		let lhs: ArithmeticExpressionPiNode = try translateArithmeticExpressionImpNode(node: node.lhs)
		let rhs: ArithmeticExpressionPiNode = try translateArithmeticExpressionImpNode(node: node.rhs)
		switch (node.op)
		{
			case "*":
				return MultiplicationOperationPiNode(lhs: lhs, rhs: rhs)
			case "/":
				return DivisionOperationPiNode(lhs: lhs, rhs: rhs)
			case "+":
				return SumOperationPiNode(lhs: lhs, rhs: rhs)
			case "-":
				return SubtractionOperationPiNode(lhs: lhs, rhs: rhs)
			default:
				throw TranslatorError.UndefinedOperator(node.op)
		}
	}

	private func translateVariableDeclarationImpNode (node: VariableDeclarationImpNode) throws -> BindableOperationPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return BindableOperationPiNode(identifier: identifier, expression: AllocateReferencePiNode(expression: expression))
	}

	private func translateConstantDeclarationImpNode (node: ConstantDeclarationImpNode) throws -> BindableOperationPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return BindableOperationPiNode(identifier: identifier, expression: expression)
	}

	private func translateEqualityImpNode (node: EqualityImpNode) throws -> EqualToOperationPiNode
	{
		let lhs: ExpressionPiNode = try translateExpressionImpNode(node: node.lhs)
		let rhs: ExpressionPiNode = try translateExpressionImpNode(node: node.rhs)
		return EqualToOperationPiNode(lhs: lhs, rhs: rhs)
	}

	private func translateLogicalConnectionImpNode (node: LogicalConnectionImpNode) throws -> LogicalConnectionPiNode
	{
		let lhs: LogicalExpressionPiNode = try translateLogicalExpressionImpNode(node: node.lhs)
		let rhs: LogicalExpressionPiNode = try translateLogicalExpressionImpNode(node: node.rhs)
		switch (node.op)
		{
			case "and":
				return AndConnectivePiNode(lhs: lhs, rhs: rhs)
			case "or":
				return OrConnectivePiNode(lhs: lhs, rhs: rhs)
			default:
				throw TranslatorError.UndefinedOperator(node.op)
		}
	}

	private func translateInequalityOperationImpNode (node: InequalityOperationImpNode) throws -> InequalityOperationPiNode
	{
		let lhs: ArithmeticExpressionPiNode = try translateArithmeticExpressionImpNode(node: node.lhs)
		let rhs: ArithmeticExpressionPiNode = try translateArithmeticExpressionImpNode(node: node.rhs)
		switch (node.op)
		{
			case "<":
				return LowerThanOperationPiNode(lhs: lhs, rhs: rhs)
			case "<=":
				return LowerEqualToOperationPiNode(lhs: lhs, rhs: rhs)
			case ">":
				return GreaterThanOperationPiNode(lhs: lhs, rhs: rhs)
			case ">=":
				return GreaterEqualToOperationPiNode(lhs: lhs, rhs: rhs)
			default:
				throw TranslatorError.UndefinedOperator(node.op)
		}
	}
}
