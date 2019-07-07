import Foundation

/// - Define the enumeration for the error that can be throw during parsing.
public enum ImpParserError: Error
{
	case UndefinedOperator(String)
	case ExpectedArithmeticExpression
	case ExpectedLogicalExpression
	case ExpectedSameExpressionType
}

/// - Class that define all the logic behind the syntax analysis.
public class ImpParser: Parser
{
	/// - The tokens relative to the ImΠ program.
	private let tokens: Stack<ImpToken>

	/// - This class initializer.
	/// - Parameter(s)
	/// 	- A list of Tokens relative to a ImΠ program.
	required public init (tokens: [Token]) throws
	{
		if tokens is [ImpToken]
		{
			self.tokens = Stack<ImpToken>(list: (tokens as! [ImpToken]))
		}
		else
		{
			throw GenericError.InvalidArgument
		}
	}

	/// - The main logic of ImΠ grammar, this process <S> node.
	/// - Return
	/// 	- The relative forest to the argument ImΠ program.
	public func parse () throws -> [AbstractSyntaxTree]
	{
		var nodes = [AbstractSyntaxTreeImp]()
		while !tokens.isEmpty()
		{
			let node = try parseGrammar()
			nodes.append(node)
		}
		return nodes
	}

	/// - The dictionary that define the precedence of all accepted operators of ImΠ.
	private let OPERATOR_PRECEDENCE: [String: Int] =
	[
		"and": 10,
		"or": 10,
		"<": 40,
		"<=": 40,
		">": 40,
		">=": 40,
		"==": 40,
		"+": 60,
		"-": 60,
		"*": 80,
		"/": 80
	]

	/// - The collection that defines all arithmetic operators of ImΠ.
	private let ARITHMETIC_OPERATOR_COLLECTION: [String] =
	[
		"+",
		"-",
		"*",
		"/"
	]

	/// - The collection that defines all logical operators of ImΠ.
	private let INEQUALITY_OPERATOR_COLLECTION: [String] =
	[
		"<",
		"<=",
		">",
		">="
	]

	/// - The collection that defines all logical operators of ImΠ.
	private let LOGICAL_CONECTOR_COLLECTION: [String] =
	[
		"and",
		"or",
	]

	/// - Helper function for dealing with the NUMBER imp token processing(<number>).
	/// - Return
	/// 	- The relative number imp node to the given token.
	private func parseNumber (isNegative: Bool = false) throws -> NumberImpNode
	{
		guard case let ImpToken.NUMBER(value) = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.NUMBER")
		}

		if isNegative
		{
			return NumberImpNode(value: -value)
		}
		else
		{
			return NumberImpNode(value: value)
		}
	}
	
	/// - Helper function for dealing with the CLASSIFICATION imp token processing(<logical_classification>).
	/// - Return
	/// 	- The relative logical classification imp node to the given token.
	private func parseClassification () throws -> LogicalClassificationImpNode
	{
		guard case let ImpToken.CLASSIFICATION(value) = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.CLASSIFICATION")
		}
		
		return LogicalClassificationImpNode(value: value)
	}
	
	/// - Helper function for dealing with the IDENTIFIER imp token processing(<identifier>).
	/// - Return
	/// 	- The relative identifier imp node to the given token.
	private func parseIdentifier () throws -> IdentifierImpNode
	{
		guard case let ImpToken.IDENTIFIER(name) = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.IDENTIFIER")
		}
		
		return IdentifierImpNode(name: name)
	}
	
	/// - Helper function for dealing with the assign processing(<assign>).
	/// - Return
	/// 	- The relative assign imp node to the given token.
	private func parseAssign (identifier: IdentifierImpNode) throws -> AssignImpNode
	{
		guard case ImpToken.ASSIGN = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.ASSIGN")
		}
		
		let expression = try parseExpression()
		
		return AssignImpNode(identifier: identifier, expression: expression)
	}
	
	/// - Helper function for dealing with the nodes beginning with a IDENTIFIER imp token.
	/// - Return
	/// 	- The relative command imp node based in the tokens in the list.
	private func parseIdentifierWrapper () throws -> CommandImpNode
	{
		let identifier: IdentifierImpNode = try parseIdentifier()
		
		if (tokens.isEmpty())
		{
			return identifier
		}
		
		switch (tokens.peek())
		{
			case ImpToken.ASSIGN:
				return try parseAssign(identifier: identifier)
			case ImpToken.OPERATOR:
				return try parseBinaryOperation(node: identifier)
			case ImpToken.BRACKET_LEFT:
				return try parseCall(identifier: identifier)
			default:
				return identifier
		}
	}

	/// - Helper function for processing a function call, this will process the <call>.
	private func parseCall(identifier: IdentifierImpNode) throws -> CallImpNode
	{
		guard case ImpToken.BRACKET_LEFT = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.BRACKET_LEFT")
		}

		var actualForest: [ExpressionImpNode] = [ExpressionImpNode]()

		while(true)
		{
			if (tokens.isEmpty())
			{
				throw ParserError.ExpectedToken("ImpToken.BRACKET_RIGHT")
			}
			else if case ImpToken.BRACKET_RIGHT = tokens.peek()
			{
				tokens.skip()
				break
			}
			else if case ImpToken.COMMA = tokens.peek()
			{
				tokens.skip()
			}
			let actual: ExpressionImpNode = try parseExpression()
			actualForest.append(actual)
		}
		
		return CallImpNode(identifier: identifier, actual: actualForest)
	}
	
	/// - Helper function for dealing with the nodes that the imp token is part of a expression(<expression>).
	/// - Return
	/// 	- The relative expression imp node to the given tokens.
	public func parseExpression () throws -> ExpressionImpNode
	{
		let node = try parsePrimary()
		return try parseBinaryOperation(node: node)
	}
	
	/// - Helper function for dealing with the BRACKET imp token processing and expressions with brackets.
	/// - Return
	/// 	- The relative expression imp node inside the brackets.
	private func parseBrackets () throws -> ExpressionImpNode
	{
		guard case ImpToken.BRACKET_LEFT = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.BRACKET_LEFT")
		}
		
		let expression = try parseExpression()
		
		guard case ImpToken.BRACKET_RIGHT = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.BRACKET_RIGHT")
		}
		
		return expression
	}
	
	/// - Helper function for dealing with the NEGATION imp token processing(<negation>).
	/// - Return
	/// 	- The relative negation imp node to the given token.
	private func parseNegation () throws -> ExpressionImpNode
	{
		guard case ImpToken.NEGATION = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.NEGATION")
		}
		
		let expressionWrapper: ExpressionImpNode = try parseExpression()
		if !(expressionWrapper is LogicalExpressionImpNode)
		{
			throw ImpParserError.ExpectedLogicalExpression
		}
		let expression: LogicalExpressionImpNode = expressionWrapper as! LogicalExpressionImpNode
		return NegationImpNode(logicalExpression: expression)
	}
	
	/// - Helper function for processing a simple expressions, (<logical_expression>, <reference>, <arithmetic_expression>).
	/// - Return
	/// 	- The relative expression imp node to the given token.
	private func parsePrimary () throws -> ExpressionImpNode
	{
		switch(tokens.peek())
		{
			case ImpToken.IDENTIFIER:
				return try parseIdentifier()
			case ImpToken.OPERATOR("-"):
				tokens.skip()
				return try parseNumber(isNegative: true)
			case ImpToken.NUMBER:
				return try parseNumber()
			case ImpToken.CLASSIFICATION:
				return try parseClassification()
			case ImpToken.BRACKET_LEFT:
				return try parseBrackets()
			case ImpToken.NEGATION:
				return try parseNegation()
			case ImpToken.REFERENCE:
				return try parseReference()
			default:
				throw ParserError.UnexpectedToken(tokens.peek())
		}
	}
	
	/// - Helper fuction for processing the current token, if is a OPERATOR it will get it's precedence priority.
	/// - Return
	/// 	- The relative precedence priority for the given OPERATOR or '-1' case is not a OPERATOR.
	private func getCurrentTokenPrecedence () throws -> Int
	{
		guard !tokens.isEmpty() else
		{
			return -1
		}
		
		guard case let ImpToken.OPERATOR(op) = tokens.peek() else
		{
			return -1
		}
		
		guard let precedence = OPERATOR_PRECEDENCE[op] else
		{
			throw ImpParserError.UndefinedOperator(op)
		}
		
		return precedence
	}
	
	/// - This function wraps the logic for processing all forms of operators.
	/// - Parameter(s)
	/// 	- node: The expression imp node to try to combine to the next operator.
	/// 	- lastPrecedence: The precedence value of the last operator.
	/// - Return
	/// 	- The relative expression imp node to the operators combination.
	private func parseBinaryOperation (node: ExpressionImpNode, lastPrecedence: Int = 0) throws -> ExpressionImpNode
	{
		var lhs = node
		while true
		{
			let tokenPrecedence = try getCurrentTokenPrecedence()
			if tokenPrecedence < lastPrecedence
			{
				return lhs
			}
			
			guard case let ImpToken.OPERATOR(op) = tokens.pop() else
			{
				throw ParserError.ExpectedToken("ImpToken.OPERATOR")
			}
			
			var rhs = try parsePrimary()
			let nextPrecedence = try getCurrentTokenPrecedence()
			
			if tokenPrecedence < nextPrecedence
			{
				rhs = try parseBinaryOperation(node: rhs, lastPrecedence: tokenPrecedence+1)
			}

			if ARITHMETIC_OPERATOR_COLLECTION.contains(op)
			{
				if !(lhs is ArithmeticExpressionImpNode) || !(rhs is ArithmeticExpressionImpNode)
				{
					throw ImpParserError.ExpectedArithmeticExpression
				}
				lhs = ArithmeticOperationImpNode(op: op, lhs: lhs as! ArithmeticExpressionImpNode, rhs: rhs as! ArithmeticExpressionImpNode)
			}
			else if INEQUALITY_OPERATOR_COLLECTION.contains(op)
			{
				if !(lhs is ArithmeticExpressionImpNode) || !(rhs is ArithmeticExpressionImpNode)
				{
					throw ImpParserError.ExpectedArithmeticExpression
				}
				lhs = InequalityOperationImpNode(op: op, lhs: lhs as! ArithmeticExpressionImpNode, rhs: rhs as! ArithmeticExpressionImpNode)
			}
			else if LOGICAL_CONECTOR_COLLECTION.contains(op)
			{
				if !(lhs is LogicalExpressionImpNode) || !(rhs is LogicalExpressionImpNode)
				{
					throw ImpParserError.ExpectedLogicalExpression
				}
				lhs = LogicalConnectionImpNode(op: op, lhs: lhs as! LogicalExpressionImpNode, rhs: rhs as! LogicalExpressionImpNode)
			}
			else if op == "=="
			{
				if !((lhs is IdentifierImpNode && rhs is IdentifierImpNode)
					|| (lhs is ArithmeticExpressionImpNode && rhs is ArithmeticExpressionImpNode)
					|| (lhs is LogicalExpressionImpNode && rhs is LogicalExpressionImpNode))
				{
					throw ImpParserError.ExpectedSameExpressionType
				}
				lhs = EqualityImpNode(lhs: lhs, rhs: rhs)
			}
			else
			{
				throw ImpParserError.UndefinedOperator(op)
			}
		}
	}
	
	/// - Helper function for dealing with the WHILE imp token processing(<while>).
	/// - Return
	/// 	- The relative while imp node to the given token.
	private func parseWhile () throws -> WhileImpNode
	{
		guard case ImpToken.WHILE = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.WHILE")
		}
		
		let conditionHelper: ExpressionImpNode = try parseExpression()
		if !(conditionHelper is LogicalExpressionImpNode)
		{
			throw ImpParserError.ExpectedLogicalExpression
		}
		let condition: LogicalExpressionImpNode = conditionHelper as! LogicalExpressionImpNode
		
		guard case ImpToken.DO = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.DO")
		}
		
		var commandForest: [CommandImpNode] = [CommandImpNode]()
		while true
		{
			let command: CommandImpNode = try parseGrammar()
			commandForest.append(command)
			if tokens.isEmpty()
			{
				throw ParserError.ExpectedToken("ImpToken.END")
			}
			else if case ImpToken.END = tokens.peek()
			{
				tokens.skip()
				break
			}
		}
		
		return WhileImpNode(condition: condition, command: commandForest)
	}
	
	/// - Helper function for dealing with the CONDITIONAL imp token processing(<conditional>).
	/// - Return
	/// 	- The relative conditional imp node to the given token.
	private func parseConditional () throws -> ConditionalImpNode
	{
		guard case ImpToken.CONDITIONAL = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.CONDITIONAL")
		}
		
		let conditionHelper: ExpressionImpNode = try parseExpression()
		if !(conditionHelper is LogicalExpressionImpNode)
		{
			throw ImpParserError.ExpectedLogicalExpression
		}
		let condition: LogicalExpressionImpNode = conditionHelper as! LogicalExpressionImpNode
		
		guard case ImpToken.THEN = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.THEN")
		}
		
		var commandForest: [CommandImpNode] = [CommandImpNode]()
		var commandForestTrue: [CommandImpNode]! = nil
		var hasElse: Bool = false
		while(true)
		{
			let command: CommandImpNode = try parseGrammar()
			commandForest.append(command)
			if (tokens.isEmpty())
			{
				throw ParserError.ExpectedToken("ImpToken.END")
			}
			else if case ImpToken.ELSE = tokens.peek()
			{
				tokens.skip()
				hasElse = true
				commandForestTrue = commandForest
				commandForest = [CommandImpNode]()
			}
			else if case ImpToken.END = tokens.peek()
			{
				tokens.skip()
				break
			}
		}
		if hasElse
		{
			return ConditionalImpNode(condition: condition, commandTrue: commandForestTrue, commandFalse: commandForest)
		}
		else
		{
			return ConditionalImpNode(condition: condition, commandTrue: commandForest, commandFalse: [CommandImpNode]())
		}
	}
	
	/// - Helper function for dealing with the REFERENCE imp token processing(<reference>).
	/// - Return
	/// 	- The relative reference imp node to the given token.
	private func parseReference () throws -> ExpressionImpNode
	{
		guard case let ImpToken.REFERENCE(op) = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.REFERENCE")
		}
		
		let identifier: IdentifierImpNode = try parseIdentifier()
		
		switch(op)
		{
			case "&":
				return AddressReferenceImpNode(identifier: identifier)
			case "(*":
				guard case ImpToken.BRACKET_RIGHT = tokens.pop() else
				{
					throw ParserError.ExpectedToken("ImpToken.BRACKET_RIGHT")
				}
				return ValueReferenceImpNode(identifier: identifier)
			default:
				throw ImpParserError.UndefinedOperator(op)
		}
	}
	
	/// - Helper function for dealing with the DECLARATION imp token processing(<declaration>).
	/// - Return
	/// 	- The relative declaration imp node to the given token.
	private func parseDeclaration () throws -> DeclarationImpNode
	{
		var recursiveDeclaration: Bool = false
		if case  ImpToken.RECURSIVE = tokens.peek()
		{
			recursiveDeclaration = true
			tokens.skip()
		}

		guard case let ImpToken.DECLARATION(op) = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.DECLARATION")
		}
		let identifier: IdentifierImpNode = try parseIdentifier()

		switch(op)
		{
			case "var":
				if recursiveDeclaration
				{
					throw ParserError.UnexpectedToken(ImpToken.RECURSIVE)
				}
				return try parseVariableDeclaration(identifier: identifier)
			case "cons":
				if recursiveDeclaration
				{
					throw ParserError.UnexpectedToken(ImpToken.RECURSIVE)
				}
				return try parseConstantDeclaration(identifier: identifier)
			case "fn":
				return try parseFunctionDeclaration(identifier: identifier, isRecursive: recursiveDeclaration)
			default:
				throw ImpParserError.UndefinedOperator(op)
		}
	}

	/// - Helper function for dealing with the variable declaration(<variable_declaration>).
	private func parseVariableDeclaration (identifier: IdentifierImpNode) throws -> VariableDeclarationImpNode
	{
		guard case ImpToken.INITIALIZER = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.INITIALIZER")
		}
		
		let expression: ExpressionImpNode = try parseExpression()
		return VariableDeclarationImpNode(identifier: identifier, expression: expression)
	}

	/// - Helper function for dealing with the constant declaration(<constant_declaration>).
	private func parseConstantDeclaration (identifier: IdentifierImpNode) throws -> ConstantDeclarationImpNode
	{
		guard case ImpToken.INITIALIZER = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.INITIALIZER")
		}
		
		let expression: ExpressionImpNode = try parseExpression()
		return ConstantDeclarationImpNode(identifier: identifier, expression: expression)
	}

	/// - Helper function for dealing with the function declaration(<function_declaration>).
	private func parseFunctionDeclaration (identifier: IdentifierImpNode, isRecursive: Bool) throws -> FunctionDeclarationImpNode
	{
		guard case ImpToken.BRACKET_LEFT = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.BRACKET_LEFT")
		}
		
		var formalForest: [IdentifierImpNode] = [IdentifierImpNode]()

		while(true)
		{
			if (tokens.isEmpty())
			{
				throw ParserError.ExpectedToken("ImpToken.BRACKET_RIGHT")
			}
			else if case ImpToken.BRACKET_RIGHT = tokens.peek()
			{
				tokens.skip()
				break
			}
			else if case ImpToken.COMMA = tokens.peek()
			{
				tokens.skip()
			}
			let formal: IdentifierImpNode = try parseIdentifier()
			formalForest.append(formal)
		}

		guard case ImpToken.INITIALIZER = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.INITIALIZER")
		}

		let block: BlockImpNode = try parseBlock()

		return FunctionDeclarationImpNode(identifier: identifier, formal: formalForest, block: block, isRecursive: isRecursive)
	}

	/// - Helper function for dealing with the BLOCK imp token processing(<block>).
	/// - Return
	/// 	- The relative block imp node to the given token.
	private func parseBlock () throws -> BlockImpNode
	{
		guard case ImpToken.LET = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.LET")
		}

		var declarationForest: [DeclarationImpNode] = [DeclarationImpNode]()
		while(true)
		{
			if (tokens.isEmpty())
			{
				throw ParserError.ExpectedToken("ImpToken.IN")
			}
			else if case ImpToken.IN = tokens.peek()
			{
				tokens.skip()
				break
			}
			else if case ImpToken.COMMA = tokens.peek()
			{
				tokens.skip()
			}
			let declaration: DeclarationImpNode = try parseDeclaration()
			declarationForest.append(declaration)
		}

		var commandForest: [CommandImpNode] = [CommandImpNode]()
		while true
		{
			let command: CommandImpNode = try parseGrammar()
			commandForest.append(command)
			if tokens.isEmpty()
			{
				throw ParserError.ExpectedToken("ImpToken.END")
			}
			else if case ImpToken.END = tokens.peek()
			{
				tokens.skip()
				break
			}
		}
		return BlockImpNode(declaration: declarationForest, command: commandForest)
	}
	
	/// - Helper function for dealing with the PRINT imp token processing(<print>).
	/// - Return
	/// 	- The relative print imp node to the given token.
	private func parsePrint () throws -> PrintImpNode
	{
		guard case ImpToken.PRINT = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.PRINT")
		}
		
		guard case ImpToken.BRACKET_LEFT = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.BRACKET_LEFT")
		}
		
		let expression: ExpressionImpNode = try parseExpression()
		
		guard case ImpToken.BRACKET_RIGHT = tokens.pop() else
		{
			throw ParserError.ExpectedToken("ImpToken.BRACKET_RIGHT")
		}

		return PrintImpNode(expression: expression)
	}
	
	/// - Helper function for delegate the command for the given imp token(<command>).
	/// - Return
	/// 	- The relative command imp node to the given token.
	private func parseGrammar () throws -> CommandImpNode
	{
		switch (tokens.peek())
		{
			case ImpToken.IDENTIFIER:
				return try parseIdentifierWrapper()
			case ImpToken.WHILE:
				return try parseWhile()
			case ImpToken.CONDITIONAL:
				return try parseConditional()
			case ImpToken.NOP:
				tokens.skip()
				return NoOpImpNode()
			case ImpToken.LET:
				return try parseBlock()
			case ImpToken.PRINT:
				return try parsePrint()
			default:
				// return try parseExpression()
				throw ParserError.UnexpectedToken(tokens.peek())
		}
	}
}
