import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during translations.
/// #END_DOC
public enum TranslatorError: Error
{
	case UndefinedOperator(String)
	case UndefinedASTNode(AST_Imp)
}

/// #START_DOC
/// - Define the enumeration for the error that can be throw during automaton.
/// #END_DOC
public enum AutomatonError: Error
{
	case UndefinedOperation(String)
	case UndefinedArithOperation(String)
	case UndefinedTruthOperation(String)
	case UndefinedOpCode(String)
	case UndefinedArithOpCode(String)
	case UndefinedTruthOpCode(String)
	case UndefinedASTPi(AST_Pi_Extended)
	case UnexpectedNilValue
	case InvalidValueExpected
	case ExpectedIdentifier
	case ExpectedAtomNode
	case ExpectedNumValue
	case ExpectedBooValue
	case ExpectedIdValue
	case UnexpectedTypeValue
	case ExpectedLocalizable
	case ExpectedBindableNode
	case ExpectedStorableNode
	case UndefinedVariable
	case UnexpectedImmutableVariable
	case ExpectedEnviroment
}

/// #START_DOC
/// - Define the concept for the Pi-Framework, where the magic will happen.
/// #END_DOC
public class PiFramework
{
	var memorySpace: Int
	
	// handlers
	let arithHandler: ArithExpressionHandler = ArithExpressionHandler()
	let truthHandler: TruthExpressionHandler = TruthExpressionHandler()
	
	/// #START_DOC
	/// - This class initializer.
	/// #END_DOC
	init ()
	{
		self.memorySpace = 0
	}

	/// #START_DOC
	/// - Helper function for combining a pi forest node into a single pi node using CSeq.
	/// 	This converts the <cmd>+ into a single AST_Pi node.
	/// #END_DOC
	private func combineAST_PiCmdNodes (ast_pi_forest: [AST_Pi]) -> AST_Pi
	{
		let head: AST_Pi = ast_pi_forest[0]
		var tail: [AST_Pi] = ast_pi_forest
		tail.remove(at: 0)
		if tail.isEmpty
		{
			return head
		}
		let rhs: AST_Pi = combineAST_PiCmdNodes(ast_pi_forest: tail)
		return BinaryOperatorNode(operation: "CSeq", lhs: head, rhs: rhs)
	}

	/// #START_DOC
	/// - Helper function for combining a pi forest node into a single pi node using DSeq.
	/// 	This converts the <dec>+ into a single AST_Pi node.
	/// #END_DOC
	private func combineAST_PiDecNodes (ast_pi_forest: [AST_Pi]) -> AST_Pi
	{
		let head: AST_Pi = ast_pi_forest[0]
		var tail: [AST_Pi] = ast_pi_forest
		tail.remove(at: 0)
		if tail.isEmpty
		{
			return head
		}
		let rhs: AST_Pi = combineAST_PiDecNodes(ast_pi_forest: tail)
		return BinaryOperatorNode(operation: "DSeq", lhs: head, rhs: rhs)
	}

	/// #START_DOC
	/// - Function for convert a AST_Imp forest into it's correlative AST_Pi.
	/// #END_DOC
	public func translate (ast_imp: [AST_Imp]) throws -> AST_Pi
	{
		var ast_pi_forest: [AST_Pi] = [AST_Pi]()
		for node in ast_imp
		{
			let ast_pi = try translateNode(ast_imp: node)
			ast_pi_forest.append(ast_pi)
		}
		if ast_imp is [DeclarationNode]
		{
			return combineAST_PiDecNodes(ast_pi_forest: ast_pi_forest)
		}
		else
		{
			return combineAST_PiCmdNodes(ast_pi_forest: ast_pi_forest)
		}
	}

	/// #START_DOC
	/// - Helper function for converting a AST_Imp into a AST_Pi.
	/// #END_DOC
	private func translateNode (ast_imp: AST_Imp) throws -> AST_Pi
	{
		if ast_imp is ArithOpNode
		{
			let node: ArithOpNode = ast_imp as! ArithOpNode
			var operation: String
			switch (node.op)
			{
				case "*":
					operation = "Mul"
					break
				case "/":
					operation = "Div"
					break
				case "+":
					operation = "Sum"
					break
				case "-":
					operation = "Sub"
					break
				default:
					throw TranslatorError.UndefinedOperator(node.op)
			}
			let lhs: AST_Pi = try translateNode(ast_imp: node.lhs)
			let rhs: AST_Pi = try translateNode(ast_imp: node.rhs)
			return BinaryOperatorNode(operation: operation, lhs: lhs, rhs: rhs)
		}
		else if ast_imp is BoolOpNode
		{
			let node: BoolOpNode = ast_imp as! BoolOpNode
			var operation: String
			switch (node.op)
			{
				case "<":
					operation = "Lt"
					break
				case "<=":
					operation = "Le"
					break
				case ">":
					operation = "Gt"
					break
				case ">=":
					operation = "Ge"
					break
				case "==":
					operation = "Eq"
					break
				case "and":
					operation = "And"
					break
				case "or":
					operation = "Or"
					break
				default:
					throw TranslatorError.UndefinedOperator(node.op)
			}
			let lhs: AST_Pi = try translateNode(ast_imp: node.lhs)
			let rhs: AST_Pi = try translateNode(ast_imp: node.rhs)
			return BinaryOperatorNode(operation: operation, lhs: lhs, rhs: rhs)
		}
		else if ast_imp is AssignNode
		{
			let node: AssignNode = ast_imp as! AssignNode
			let lhs: AST_Pi = try translateNode(ast_imp: node.identifier)
			let rhs: AST_Pi = try translateNode(ast_imp: node.expression)
			return BinaryOperatorNode(operation: "Assign", lhs: lhs, rhs: rhs)
		}
		else if ast_imp is WhileNode
		{
			let node: WhileNode = ast_imp as! WhileNode
			let lhs: AST_Pi = try translateNode(ast_imp: node.condition)
			let rhs: AST_Pi = try translate(ast_imp: node.command)
			return BinaryOperatorNode(operation: "Loop", lhs: lhs, rhs: rhs)
		}
		else if ast_imp is ConditionalNode
		{
			let node: ConditionalNode = ast_imp as! ConditionalNode
			let lhs: AST_Pi = try translateNode(ast_imp: node.condition)
			let chs: AST_Pi = try translate(ast_imp: node.commandTrue)
			var rhs: AST_Pi? = nil
			if (!node.commandFalse.isEmpty)
			{
				rhs = try translate(ast_imp: node.commandFalse)
			}
			return TernaryOperatorNode(operation: "Cond", lhs: lhs, chs: chs, rhs: rhs)
		}
		else if ast_imp is NegationNode
		{
			let node: NegationNode = ast_imp as! NegationNode
			let expression: AST_Pi = try translateNode(ast_imp: node.expression)
			return UnaryOperatorNode(operation: "Not", expression: expression)
		}
		else if ast_imp is NumberNode
		{
			let node: NumberNode = ast_imp as! NumberNode
			return AtomNode(operation: "Num", value: "\(node.value)")
		}
		else if ast_imp is IdentifierNode
		{
			let node: IdentifierNode = ast_imp as! IdentifierNode
			return AtomNode(operation: "Id", value: "\(node.name)")
		}
		else if ast_imp is TruthNode
		{
			let node: TruthNode = ast_imp as! TruthNode
			return AtomNode(operation: "Boo", value: "\(node.value)")
		}
		else if ast_imp is NoOpNode
		{
			return OnlyOperatorNode(operation: "Nop")
		}
		else if ast_imp is ReferenceNode
		{
			let node: ReferenceNode = ast_imp as! ReferenceNode
			let identifier: AtomNode = try translateNode(ast_imp: node.identifier) as! AtomNode
			var operation: String
			switch (node.operation)
			{
				case "address":
					operation = "DeRef"
					break
				case "value":
					operation = "ValRef"
					break
				default:
					throw TranslatorError.UndefinedOperator(node.operation)
			}
			return UnaryOperatorNode(operation: operation, expression: identifier)
		}
		else if ast_imp is VariableNode
		{
			let node: VariableNode = ast_imp as! VariableNode
			let identifier: AtomNode = try translateNode(ast_imp: node.identifier) as! AtomNode
			let expression: AST_Pi = try translateNode(ast_imp: node.expression)
			return BinaryOperatorNode(operation: "Bind", lhs: identifier, rhs: UnaryOperatorNode(operation: "Ref", expression: expression))
		}
		else if ast_imp is ConstantNode
		{
			let node: ConstantNode = ast_imp as! ConstantNode
			let identifier: AtomNode = try translateNode(ast_imp: node.identifier) as! AtomNode
			let expression: AST_Pi = try translateNode(ast_imp: node.expression)
			return BinaryOperatorNode(operation: "Bind", lhs: identifier, rhs: expression)
		}
		else if ast_imp is BlockNode
		{
			let node: BlockNode = ast_imp as! BlockNode
			let declaration: AST_Pi = try translate(ast_imp: node.declaration)
			let command: AST_Pi = try translate(ast_imp: node.command)
			return BinaryOperatorNode(operation: "Block", lhs: declaration, rhs: command)
		}
		else if ast_imp is PrintNode
		{
			let node: PrintNode = ast_imp as! PrintNode
			let expression: AST_Pi = try translateNode(ast_imp: node.expression)
			return UnaryOperatorNode(operation: "Print", expression: expression)
		}
		else
		{
			throw TranslatorError.UndefinedASTNode(ast_imp)
		}
	}

	/// #START_DOC
	/// - Function for define the concept of the Pi-Framework automaton, for executing a AST_Pi.
	/// #END_DOC
	public func pi_automaton (ast_pi: AST_Pi) throws
	{
		let control_pile: Pile<AST_Pi_Extended> = Pile<AST_Pi_Extended>()
		control_pile.push(value: ast_pi)
		let value_pile: Pile<Automaton_Value> = Pile<Automaton_Value>()
		var storage_pile: [Int: Automaton_Storable] = [Int: Automaton_Storable]()
		var enviroment_pile: [String: Automaton_Bindable] = [String: Automaton_Bindable]()
		var localizableList: [Localizable] = [Localizable]()
		var steps_count: Int = 0
		repeat
		{
			let last_state: String = "{ n: \(steps_count), c: \(control_pile), v: \(value_pile), s: \(storage_pile), e: \(enviroment_pile), l: \(localizableList) }"
			do
			{
				if envConfiguration.state_print
				{
					print("\(last_state)")
				}
				try self.delta(control: control_pile, value: value_pile, storage: &storage_pile, enviroment: &enviroment_pile, localizableList: &localizableList)
			}
			catch
			{
				if !envConfiguration.state_print
				{
					print("\(last_state)")
				}
				throw error
			}
			steps_count += 1
		}while(!control_pile.isEmpty())
		print("{ v: \(value_pile), s: \(storage_pile), e: \(enviroment_pile), l: \(localizableList) }")
	}
	
	/// #START_DOC
	/// - Helper function for getting a <truth> value from the value pile.
	/// #END_DOC
	private func popBooValue(value: Pile<Automaton_Value>) throws -> Bool
	{
		if value.isEmpty() || !(value.peek() is AtomNode)
		{
			throw AutomatonError.ExpectedAtomNode
		}
		let nodeHelper: AtomNode = value.pop() as! AtomNode
		if nodeHelper.operation != "Boo"
		{
			throw AutomatonError.ExpectedBooValue
		}
		return Bool(nodeHelper.value)!
	}
	
	/// #START_DOC
	/// - Helper function for getting a <identifier> value from the value pile.
	/// #END_DOC
	private func popIdValue(value: Pile<Automaton_Value>) throws -> String
	{
		if value.isEmpty() || !(value.peek() is AtomNode)
		{
			throw AutomatonError.ExpectedAtomNode
		}
		let nodeHelper: AtomNode = value.pop() as! AtomNode
		if nodeHelper.operation != "Id"
		{
			throw AutomatonError.ExpectedIdValue
		}
		return nodeHelper.value
	}
	
	/// #START_DOC
	/// - Helper function for the automaton, this define the logic for change the state of the automaton based in the argument values.
	/// #END_DOC
	private func delta (control: Pile<AST_Pi_Extended>, value: Pile<Automaton_Value>, storage: inout [Int: Automaton_Storable], enviroment: inout [String: Automaton_Bindable], localizableList: inout [Localizable]) throws
	{
		let command_tree: AST_Pi_Extended = control.pop()
		if command_tree is PiOpCodeNode
		{
			let functNode: PiOpCodeNode = command_tree as! PiOpCodeNode
			switch(functNode.function)
			{
				// Aritimetical Operators
				case "#MUL", "#DIV", "#SUM", "#SUB":
					try arithHandler.processOpCode(code: functNode.function, value: value)
					break
				// Logical Operators
				case "#LT", "#LE", "#GT", "#GE", "#AND", "#OR", "#EQ", "#NOT":
					try truthHandler.processOpCode(code: functNode.function, value: value)
					break
				// Other functions
				case "#ASSIGN":
					if value.isEmpty() || !(value.peek() is AtomNode)
					{
						throw AutomatonError.ExpectedAtomNode
					}
					let nodeAsgValue: AtomNode = value.pop() as! AtomNode
					let idName: String = try popIdValue(value: value)
					if enviroment[idName] == nil
					{
						throw AutomatonError.UndefinedVariable
					}
					let bindable: Automaton_Bindable = enviroment[idName]!
					if !(bindable is Localizable)
					{
						throw AutomatonError.UnexpectedImmutableVariable
					}
					let localizable: Localizable = bindable as! Localizable
					storage[localizable.address] = nodeAsgValue
					break
				case "#LOOP":
					let conditionValue: Bool = try popBooValue(value: value)
					let loop_node: BinaryOperatorNode = value.pop() as! BinaryOperatorNode
					if (conditionValue)
					{
						control.push(value: loop_node)
						control.push(value: loop_node.rhs)
					}
					break
				case "#COND":
					let conditionValue: Bool = try popBooValue(value: value)
					let cond_node: TernaryOperatorNode = value.pop() as! TernaryOperatorNode
					if (conditionValue)
					{
						control.push(value: cond_node.chs)
					}
					else
					{
						control.push(value: cond_node.rhs)
					}
					break
				case "#BIND":
					if value.isEmpty() || !(value.peek() is Automaton_Bindable)
					{
						throw AutomatonError.ExpectedBindableNode
					}
					let bindValue: Automaton_Bindable = value.pop() as! Automaton_Bindable
					let idName: String = try popIdValue(value: value)
					var bindableCollection: BindableCollection
					if !value.isEmpty() && value.peek() is BindableCollection
					{
						bindableCollection = value.pop() as! BindableCollection
					}
					else
					{
						bindableCollection = BindableCollection()
					}
					bindableCollection.add(key: idName, value: bindValue)
					value.push(value: bindableCollection)
					break
				case "#REF":
					if value.isEmpty() || !(value.peek() is Automaton_Storable)
					{
						throw AutomatonError.ExpectedStorableNode
					}
					let storableValue: Automaton_Storable = value.pop() as! Automaton_Storable
					let localizable: Localizable = Localizable(address: memorySpace)
					memorySpace += 1
					storage[localizable.address] = storableValue
					localizableList.append(localizable)
					value.push(value: localizable)
					break
				case "#BLKDEC":
					let oldEnviroment: BindableCollection = BindableCollection(collection: enviroment)
					if value.isEmpty() || !(value.peek() is BindableCollection)
					{
						throw AutomatonError.ExpectedEnviroment
					}
					let bindableCollection: BindableCollection = value.pop() as! BindableCollection
					enviroment.merge(bindableCollection.getCollection()) { (_, new) in new }
					value.push(value: oldEnviroment)
					break
				case "#BLKCMD":
					if value.isEmpty() || !(value.peek() is BindableCollection)
					{
						throw AutomatonError.ExpectedEnviroment
					}
					let oldEnviroment: BindableCollection = value.pop() as! BindableCollection
					enviroment = oldEnviroment.getCollection()
					
					let localizableToRemove: [Localizable] = localizableList
					if value.isEmpty() || !(value.peek() is LocalizableCollection)
					{
						throw AutomatonError.ExpectedLocalizable
					}
					let localizableCollection: LocalizableCollection = value.pop() as! LocalizableCollection
					localizableList = localizableCollection.getCollection()
					
					for localizable in localizableToRemove
					{
						storage.removeValue(forKey: localizable.address)
					}
					break
				case "#PRINT":
					if value.isEmpty() || !(value.peek() is Automaton_Bindable)
					{
						throw AutomatonError.ExpectedBindableNode
					}
					let bindNode: Automaton_Bindable = value.pop() as! Automaton_Bindable
					print("\(bindNode)")
					break
				default:
					throw AutomatonError.UndefinedOpCode(functNode.function)
			}
		}
		else if command_tree is TernaryOperatorNode
		{
			let operatorNode: TernaryOperatorNode = command_tree as! TernaryOperatorNode
			switch (operatorNode.operation)
			{
				case "Cond":
					control.push(value: PiOpCodeNode(function: "#COND"))
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			control.push(value: operatorNode.lhs)
			value.push(value: operatorNode)
		}
		else if command_tree is BinaryOperatorNode
		{
			let operatorNode: BinaryOperatorNode = command_tree as! BinaryOperatorNode
			switch (operatorNode.operation)
			{
				// Arithmetic Operators
				case "Mul", "Div", "Sum", "Sub":
					try arithHandler.processNode(node: operatorNode, control: control)
					return
				// Logical Operators
				case "Lt", "Le", "Gt", "Ge", "Eq", "And", "Or":
					try truthHandler.processNode(node: operatorNode, control: control)
					return
				// Other functions
				case "Assign":
					control.push(value: PiOpCodeNode(function: "#ASSIGN"))
					break
				case "Loop":
					control.push(value: PiOpCodeNode(function: "#LOOP"))
					break
				case "CSeq","DSeq":
					break
				case "Bind":
					control.push(value: PiOpCodeNode(function: "#BIND"))
					break
				case "Block":
					control.push(value: PiOpCodeNode(function: "#BLKCMD"))
					control.push(value: operatorNode.rhs)
					control.push(value: PiOpCodeNode(function: "#BLKDEC"))
					control.push(value: operatorNode.lhs)
					let localizableCollection: LocalizableCollection = LocalizableCollection(collection: localizableList)
					localizableList = [Localizable]()
					value.push(value: localizableCollection)
					return
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			switch (operatorNode.operation)
			{
				case "Loop":
					control.push(value: operatorNode.lhs)
					value.push(value: operatorNode)
					break
				case "CSeq", "DSeq":
					control.push(value: operatorNode.rhs)
					control.push(value: operatorNode.lhs)
					break
				case "Assign", "Bind":
					value.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break
				default:
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
			}
		}
		else if command_tree is UnaryOperatorNode
		{
			let operatorNode: UnaryOperatorNode = command_tree as! UnaryOperatorNode
			switch (operatorNode.operation)
			{
				case "Not":
					try truthHandler.processNode(node: operatorNode, control: control)
					break
				case "DeRef":
					let identifier: AtomNode = operatorNode.expression as! AtomNode
					if enviroment[identifier.value] == nil || !(enviroment[identifier.value] is Localizable)
					{
						throw AutomatonError.ExpectedLocalizable
					}
					let localizable: Localizable = enviroment[identifier.value]! as! Localizable
					value.push(value: localizable)
					break
				case "ValRef":
					let identifier: AtomNode = operatorNode.expression as! AtomNode
					if enviroment[identifier.value] == nil || !(enviroment[identifier.value] is Localizable)
					{
						throw AutomatonError.ExpectedLocalizable
					}
					let localizable: Localizable = enviroment[identifier.value]! as! Localizable
					
					if storage[localizable.address] == nil || !(storage[localizable.address] is Localizable)
					{
						throw AutomatonError.ExpectedLocalizable
					}
					let addressLocale: Localizable = storage[localizable.address]! as! Localizable
					if storage[addressLocale.address] == nil
					{
						throw AutomatonError.ExpectedStorableNode
					}
					let desiredValue: Automaton_Storable = storage[addressLocale.address]!
					value.push(value: desiredValue)
					break
				case "Ref":
					control.push(value: PiOpCodeNode(function: "#REF"))
					control.push(value: operatorNode.expression)
					break
				case "Print":
					control.push(value: PiOpCodeNode(function: "#PRINT"))
					control.push(value: operatorNode.expression)
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
		}
		else if command_tree is AtomNode
		{
			let operatorNode: AtomNode = command_tree as! AtomNode
			switch (operatorNode.operation)
			{
				case "Num":
					break
				case "Boo":
					break
				case "Id":
					if enviroment[operatorNode.value] == nil
					{
						throw AutomatonError.ExpectedBindableNode
					}
					if enviroment[operatorNode.value]! is Localizable
					{
						let localizable: Localizable = enviroment[operatorNode.value]! as! Localizable
						if storage[localizable.address] == nil
						{
							throw AutomatonError.ExpectedStorableNode
						}
						let desiredValue: Automaton_Storable = storage[localizable.address]!
						value.push(value: desiredValue)
					}
					else
					{
						value.push(value: enviroment[operatorNode.value]!)
					}
					return
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
			value.push(value: operatorNode)
		}
		else if command_tree is OnlyOperatorNode
		{
			let operatorNode: OnlyOperatorNode = command_tree as! OnlyOperatorNode
			switch (operatorNode.operation)
			{
				case "Nop":
					break
				default:
					throw AutomatonError.UndefinedOperation(operatorNode.operation)
			}
		}
		else
		{
			throw AutomatonError.UndefinedASTPi(command_tree)
		}
	}
}