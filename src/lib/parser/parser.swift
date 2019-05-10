import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during parsing.
/// #END_DOC
public enum ParserError: Error
{
	case UnexpectedToken
	case UndefinedOperator(String)
	
	case ExpectedCharacter(Character)
	case ExpectedExpressionToken(Token)
	case ExpectedToken(Token)
	
	case ExpectedAnyExpr
	case ExpectedArithExpr
	case ExpectedBoolExpr
	
	case NotImplemented(String)
}

/// #START_DOC
/// - The dictionary that define the precedence of all accepted operators of ImΠ.
/// #END_DOC
private let operatorPrecedence: [String: Int] =
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

/// #START_DOC
/// - The collection that defines all arithmetic operators of ImΠ.
/// #END_DOC
private let arith_operator_collection: [String] =
[
	"+",
	"-",
	"*",
	"/"
]

/// #START_DOC
/// - The collection that defines all boolean operators of ImΠ.
/// #END_DOC
private let bool_operator_collection: [String] =
[
	"and",
	"or",
	"<",
	"<=",
	">",
	">=",
	"=="
]

/// #START_DOC
/// - Class that define all the logic behind the syntax analysis.
/// #END_DOC
public class Parser
{
	private let tokens: Pile<Token>
	
	/// #START_DOC
	/// - This class initializer.
	/// - Parameter(s)
	/// 	- A list of Tokens relative to a ImΠ program.
	/// #END_DOC
	init (tokens: [Token])
	{
		self.tokens = Pile<Token>(list: tokens)
	}
	
	/// #START_DOC
	/// - Helper function for dealing with the Number token processing.
	/// - Return
	/// 	- The relative Number node to the given token.
	/// #END_DOC
	private func parseNumber () throws -> ExpressionNode
	{
		guard case let Token.NUMBER(value) = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		return NumberNode(value: value)
	}
	
	/// #START_DOC
	/// - Helper function for dealing with the Number token processing.
	/// - Return
	/// 	- The relative Number node to the given token.
	/// #END_DOC
	private func parseBoolean () throws -> ExpressionNode
	{
		guard case let Token.BOOLEAN(value) = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		return TruthNode(value: value)
	}
	
	/// #START_DOC
	/// - Helper function for dealing with the Number token processing.
	/// - Return
	/// 	- The relative Number node to the given token.
	/// #END_DOC
	private func parseIdentifier () throws -> AST_Imp
	{
		guard case let Token.IDENTIFIER(name) = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		if (tokens.isEmpty())
		{
			return IdentifierNode(name: name)
		}
		
		guard case Token.ASSIGN = tokens.peek() else
		{
			return IdentifierNode(name: name)
		}
		
		// skip assign
		tokens.skip()
		
		let expression = try parseExpression()
		
		return AssignNode(variable: IdentifierNode(name: name), expression: expression)
	}
	
	/// #START_DOC
	/// - Helper function for dealing with the Number token processing.
	/// - Return
	/// 	- The relative Number node to the given token.
	/// #END_DOC
	public func parseExpression () throws -> ExpressionNode
	{
		let node = try parsePrimary()
		return try parseBinaryOp(node: node)
	}
	
	/// #START_DOC
	/// - Helper function for dealing with the Number token processing.
	/// - Return
	/// 	- The relative Number node to the given token.
	/// #END_DOC
	private func parseBrackets () throws -> ExpressionNode
	{
		guard case Token.BRACKET_LEFT = tokens.pop() else
		{
			throw ParserError.ExpectedCharacter("(")
		}
		
		let expression = try parseExpression()
		
		guard case Token.BRACKET_RIGHT = tokens.pop() else
		{
			throw ParserError.ExpectedCharacter(")")
		}
		
		return expression
	}
	
	/// #START_DOC
	/// - Helper function for dealing with the Number token processing.
	/// - Return
	/// 	- The relative Number node to the given token.
	/// #END_DOC
	private func parseNegation () throws -> ExpressionNode
	{
		guard case Token.NEGATION = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		let expressionWrapper: ExpressionNode = try parseExpression()
		if !(expressionWrapper is BoolNode)
		{
			throw ParserError.ExpectedBoolExpr
		}
		let expression: BoolNode = expressionWrapper as! BoolNode
		return NegationNode(expression: expression)
	}
	
	/// #START_DOC
	/// - Helper function for dealing with the Number token processing.
	/// - Return
	/// 	- The relative Number node to the given token.
	/// #END_DOC
	private func parsePrimary () throws -> ExpressionNode
	{
		switch(tokens.peek())
		{
			case Token.IDENTIFIER:
				return try parseIdentifier() as! ExpressionNode
			case Token.NUMBER:
				return try parseNumber()
			case Token.BOOLEAN:
				return try parseBoolean()
			case Token.BRACKET_LEFT:
				return try parseBrackets()
			case Token.NEGATION:
				return try parseNegation()
			default:
				throw ParserError.ExpectedExpressionToken(tokens.peek())
		}
	}
	
	/// #START_DOC
	/// - Helper fuction for processing the current token, if is a operator will process and get its precedence.
	/// - Return
	/// 	- The relative value for the given operator.
	/// #END_DOC
	private func getCurrentTokenPrecedence () throws -> Int
	{
		guard !tokens.isEmpty() else
		{
			return -1
		}
		
		guard case let Token.OPERATOR(op) = tokens.peek() else
		{
			return -1
		}
		
		guard let precedence = operatorPrecedence[op] else
		{
			throw ParserError.UndefinedOperator(op)
		}
		
		return precedence
	}
	
	/// #START_DOC
	/// - This function wraps the logic for processing all forms operators.
	/// #END_DOC
	private func parseBinaryOp (node: ExpressionNode, exprPrecedence: Int = 0) throws -> ExpressionNode
	{
		var lhs = node
		while true
		{
			let tokenPrecedence = try getCurrentTokenPrecedence()
			if tokenPrecedence < exprPrecedence
			{
				return lhs
			}
			
			guard case let Token.OPERATOR(op) = tokens.pop() else
			{
				throw ParserError.UnexpectedToken
			}
			
			var rhs = try parsePrimary()
			let nextPrecedence = try getCurrentTokenPrecedence()
			
			if tokenPrecedence < nextPrecedence
			{
				rhs = try parseBinaryOp(node: rhs, exprPrecedence: tokenPrecedence+1)
			}
			if arith_operator_collection.contains(op)
			{
				if !(lhs is ArithNode) || !(rhs is ArithNode)
				{
					print("\(op), \(lhs), \(rhs)")
					throw ParserError.ExpectedArithExpr
				}
				lhs = ArithOpNode(op: op, lhs: lhs as! ArithNode, rhs: rhs as! ArithNode)
			}
			else if bool_operator_collection.contains(op)
			{
				if lhs is IdentifierNode && rhs is IdentifierNode
				{
					// just skip this
				}
				else if lhs is ArithNode && rhs is ArithNode
				{
					if op == "and" || op == "or"
					{
						print("'\(op)' l:\(lhs), r:\(rhs)")
						throw ParserError.ExpectedArithExpr
					}
				}
				else if lhs is BoolNode && rhs is BoolNode
				{
					if op != "and" && op != "or" && op != "=="
					{
						print("'\(op)' l:\(lhs), r:\(rhs)")
						throw ParserError.ExpectedBoolExpr
					}
				}
				else
				{
					print("'\(op)' l:\(lhs), r:\(rhs)")
					throw ParserError.ExpectedAnyExpr
				}
				lhs = BoolOpNode(op: op, lhs: lhs, rhs: rhs)
			}
		}
	}
	
	/// #START_DOC
	/// - This will process the <while> node.
	/// #END_DOC
	private func parseLoop () throws -> WhileNode
	{
		guard case Token.WHILE = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		let conditionWrapper: ExpressionNode = try parseExpression()
		if !(conditionWrapper is BoolNode)
		{
			throw ParserError.ExpectedBoolExpr
		}
		let condition: BoolNode = conditionWrapper as! BoolNode
		
		guard case Token.DO = tokens.pop() else
		{
			throw ParserError.ExpectedToken(Token.DO)
		}
		
		var commandForest: [AST_Imp] = [AST_Imp]()
		while(true)
		{
			let command = try parseGrammar()
			commandForest.append(command)
			if (tokens.isEmpty())
			{
				throw ParserError.ExpectedToken(Token.END)
			}
			else if case Token.END = tokens.peek()
			{
				tokens.skip()
				break
			}
		}
		
		return WhileNode(condition: condition, command: commandForest)
	}
	
	/// #START_DOC
	/// - This will process the <conditional> node.
	/// #END_DOC
	private func parseConditional () throws -> ConditionalNode
	{
		guard case Token.IF = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		let conditionWrapper: ExpressionNode = try parseExpression()
		if !(conditionWrapper is BoolNode)
		{
			throw ParserError.ExpectedBoolExpr
		}
		let condition: BoolNode = conditionWrapper as! BoolNode
		
		guard case Token.THEN = tokens.pop() else
		{
			throw ParserError.ExpectedToken(Token.THEN)
		}
		
		var commandForest: [AST_Imp] = [AST_Imp]()
		var commandForestTrue: [AST_Imp] = [AST_Imp]()
		var hasElse: Bool = false
		while(true)
		{
			let command = try parseGrammar()
			commandForest.append(command)
			if (tokens.isEmpty())
			{
				throw ParserError.ExpectedToken(Token.END)
			}
			else if case Token.ELSE = tokens.peek()
			{
				tokens.skip()
				hasElse = true
				commandForestTrue = commandForest
				commandForest = [AST_Imp]()
			}
			else if case Token.END = tokens.peek()
			{
				tokens.skip()
				break
			}
		}
		if (hasElse)
		{
			return ConditionalNode(condition: condition, commandTrue: commandForestTrue, commandFalse: commandForest)
		}
		else
		{
			return ConditionalNode(condition: condition, commandTrue: commandForest, commandFalse: [AST_Imp]())
		}
	}
	
	/// #START_DOC
	/// - This process the logic of the <cmd> node.
	/// #END_DOC
	private func parseGrammar () throws -> AST_Imp
	{
		switch (tokens.peek())
		{
			case Token.IDENTIFIER:
				let node = try parseIdentifier()
				return node
			case Token.WHILE:
				let node = try parseLoop()
				return node
			case Token.IF:
				let node = try parseConditional()
				return node
			case Token.NOP:
				return NoOpNode()
			default:
				let expr = try parseExpression()
				return expr
		}
	}
	
	/// #START_DOC
	/// - The main logic of ImΠ grammar, this process <S> node.
	/// #END_DOC
	public func parse () throws -> [AST_Imp]
	{
		var nodes = [AST_Imp]()
		while !tokens.isEmpty()
		{
			let node = try parseGrammar()
			nodes.append(node)
		}
		
		return nodes
	}
}
