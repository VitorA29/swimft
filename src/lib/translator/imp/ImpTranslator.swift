/// Class defining all the logic behind the translation of a Abstract Syntax Tree relative to a ImΠ programm to it's relative Abstract Syntrax Tree of Πr.
public class ImpTranslator: Translator
{
	let abstractSyntaxTreeImp: [CommandImpNode]

	/// - This class' constructor.
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
	
	/// - Function for convert a abstract syntax tree of imp into it's correlative abstract syntax tree pi.
	public func translate () throws -> AbstractSyntaxTreePi
	{
		return try combineCommandImpNodes(forest: abstractSyntaxTreeImp)
	}

	/// - Helper function for converting a command imp node into it's correlative command pi node
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
		else if node is CallImpNode
		{
			return try translateCallImpNode(node: node as! CallImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	/// - Helper function for combining a abstract syntax tree pi forest into a abstract syntax tree single pi node using CSeq.
	/// 	This converts the <cmd>+ into a single AbstractSyntaxTreePi node.
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

	/// - Helper function for combining a pi forest node into a single pi node using DSeq.
	/// 	This converts the <dec>+ into a single AbstractSyntaxTreePi node.
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

	/// - Helper function for converting a assign imp node into it's correlative assign pi node
	private func translateAssignImpNode (node: AssignImpNode) throws -> AssignPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return AssignPiNode(identifier: identifier, expression: expression)
	}

	/// - Helper function for converting a while imp node into it's correlative loop pi node
	private func translateWhileImpNode (node: WhileImpNode) throws -> LoopPiNode
	{
		let condition: LogicalExpressionPiNode = try translateLogicalExpressionImpNode(node: node.condition)
		let command: CommandPiNode = try combineCommandImpNodes(forest: node.command)
		return LoopPiNode(condition: condition, command: command)
	}

	/// - Helper function for converting a conditional imp node into it's correlative conditional pi node
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

	/// - Helper function for converting a expression imp node into it's correlative expression pi node
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

	/// - Helper function for converting a block imp node into it's correlative block pi node
	private func translateBlockImpNode (node: BlockImpNode) throws -> BlockPiNode
	{
		var declaration: DeclarationPiNode? = nil
		if node.declaration.count > 0
		{
			declaration = try combineDeclarationImpNodes(forest: node.declaration)
		}
		let command: CommandPiNode = try combineCommandImpNodes(forest: node.command)
		return BlockPiNode(declaration: declaration, command: command)
	}

	/// - Helper function for converting a print imp node into it's correlative print pi node
	private func translatePrintImpNode (node: PrintImpNode) throws -> PrintPiNode
	{
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return PrintPiNode(expression: expression)
	}

	/// - Helper function for converting a call imp node into it's correlative call pi node
	private func translateCallImpNode (node: CallImpNode) throws -> CallPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		var actualList: [ExpressionPiNode] = [ExpressionPiNode]()
		for actual in node.actual
		{
			actualList.append(try translateExpressionImpNode(node: actual))
		}
		return CallPiNode(identifier: identifier, actualList: actualList)
	}

	/// - Helper function for converting a identifier imp node into it's correlative identifier pi node
	private func translateIdentifierImpNode (node: IdentifierImpNode) -> IdentifierPiNode
	{
		return IdentifierPiNode(name: node.name)
	}

	/// - Helper function for converting a reference imp node into it's correlative reference pi node
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

	/// - Helper function for converting a logical expression imp node into it's correlative logical expression pi node
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

	/// - Helper function for converting a arithmetic expression imp node into it's correlative arithmetic expression pi node
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

	/// - Helper function for converting a declaration imp node into it's correlative declaration pi node
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
		else if node is FunctionDeclarationImpNode
		{
			return try translateFunctionDeclarationImpNode(node: node as! FunctionDeclarationImpNode)
		}
		else
		{
			throw TranslatorError.UndefinedAbstractSyntaxTreeNode(node)
		}
	}

	/// - Helper function for converting a address reference imp node into it's correlative address reference pi node
	private func translateAddressReferenceImpNode (node: AddressReferenceImpNode) -> AddressReferencePiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		return AddressReferencePiNode(identifier: identifier)
	}

	/// - Helper function for converting a value reference imp node into it's correlative value reference pi node
	private func translateValueReferenceImpNode (node: ValueReferenceImpNode) -> ValueReferencePiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		return ValueReferencePiNode(identifier: identifier)
	}

	/// - Helper function for converting a logical classification imp node into it's correlative logical classification pi node
	private func translateLogicalClassificationImpNode (node: LogicalClassificationImpNode) -> LogicalClassificationPiNode
	{
		return LogicalClassificationPiNode(value: node.value)
	}

	/// - Helper function for converting a negation imp node into it's correlative negation pi node
	private func translateNegationImpNode (node: NegationImpNode) throws -> NegationPiNode
	{
		let logicalExpression: LogicalExpressionPiNode = try translateLogicalExpressionImpNode(node: node.logicalExpression)
		return NegationPiNode(logicalExpression: logicalExpression)
	}

	/// - Helper function for converting a number imp node into it's correlative number pi node
	private func translateNumberImpNode (node: NumberImpNode) -> NumberPiNode
	{
		return NumberPiNode(value: node.value)
	}

	/// - Helper function for converting a logical operation imp node into it's correlative logical expression pi node
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

	/// - Helper function for converting a arithmetic operation imp node into it's correlative arithmetic operation pi node
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

	/// - Helper function for converting a variable declaration imp node into it's correlative bindable operation pi node
	private func translateVariableDeclarationImpNode (node: VariableDeclarationImpNode) throws -> BindableOperationPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return BindableOperationPiNode(identifier: identifier, expression: AllocateReferencePiNode(expression: expression))
	}

	/// - Helper function for converting a constant declaration imp node into it's correlative bindable operation pi node
	private func translateConstantDeclarationImpNode (node: ConstantDeclarationImpNode) throws -> BindableOperationPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		let expression: ExpressionPiNode = try translateExpressionImpNode(node: node.expression)
		return BindableOperationPiNode(identifier: identifier, expression: expression)
	}

	/// - Helper function for converting a function declaration imp node into it's correlative bindable operation pi node
	private func translateFunctionDeclarationImpNode (node: FunctionDeclarationImpNode) throws -> BindableOperationPiNode
	{
		let identifier: IdentifierPiNode = translateIdentifierImpNode(node: node.identifier)
		var formalList: [IdentifierPiNode] = [IdentifierPiNode]()
		for formal in node.formal
		{
			formalList.append(translateIdentifierImpNode(node: formal))
		}
		let block: BlockPiNode = try translateBlockImpNode(node: node.block)
		return BindableOperationPiNode(identifier: identifier, expression: AbstractionPiNode(formalList: formalList, block: block))
	}

	/// - Helper function for converting a equality imp node into it's correlative equal to operation pi node
	private func translateEqualityImpNode (node: EqualityImpNode) throws -> EqualToOperationPiNode
	{
		let lhs: ExpressionPiNode = try translateExpressionImpNode(node: node.lhs)
		let rhs: ExpressionPiNode = try translateExpressionImpNode(node: node.rhs)
		return EqualToOperationPiNode(lhs: lhs, rhs: rhs)
	}

	/// - Helper function for converting a logical connection imp node into it's correlative logical connection pi node
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

	/// - Helper function for converting a inequality operation imp node into it's correlative inequality operation pi node
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
