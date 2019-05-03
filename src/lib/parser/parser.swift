import Foundation

public enum ParserError: Error
{
	case UnexpectedToken
	case UndefinedOperator(String)
	
	case ExpectedCharacter(Character)
	case ExpectedExpressionToken(Token)
	case ExpectedArgumentList
	case ExpectedFunctionName
	case ExpectedToken(Token)
	
	case NotImplemented(String)
}

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

public class Parser
{
	private let tokens: Pile<Token>
	
	init (tokens: [Token])
	{
		self.tokens = Pile<Token>(list: tokens)
	}
	
	private func parseNumber () throws -> ExprNode
	{
		guard case let Token.NUMBER(value) = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		return NumberNode(value: value)
	}
	
	private func parseIdentifier () throws -> ExprNode
	{
		guard case let Token.IDENTIFIER(name) = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		if (tokens.isEmpty())
		{
			return VariableNode(name: name)
		}
		
		guard case Token.ASSIGN = tokens.peek() else
		{
			return VariableNode(name: name)
		}
		
		// skip assign
		tokens.skip()
		
		let expression = try parseExpression()
		
		return AssignNode(variable: VariableNode(name: name), expression: expression)
	}
	
	public func parseExpression () throws -> ExprNode
	{
		let node = try parsePrimary()
		return try parseBinaryOp(node: node)
	}
	
	private func parseBrackets () throws -> ExprNode
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
	
	private func parseNegation () throws -> ExprNode
	{
		guard case Token.NEGATION = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		let expression = try parseExpression()
		
		return NegationNode(expression: expression)
	}
	
	private func parsePrimary () throws -> ExprNode
	{
		switch(tokens.peek())
		{
			case Token.IDENTIFIER:
				return try parseIdentifier()
			case Token.NUMBER:
				return try parseNumber()
			case Token.BRACKET_LEFT:
				return try parseBrackets()
			case Token.NEGATION:
				return try parseNegation()
			default:
				throw ParserError.ExpectedExpressionToken(tokens.peek())
		}
	}
	
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
	
	private func parseBinaryOp (node: ExprNode, exprPrecedence: Int = 0) throws -> ExprNode
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
			lhs = BinaryOpNode(op: op, lhs: lhs, rhs: rhs)
		}
	}
	
	private func parseLoop () throws -> WhileNode
	{
		guard case Token.WHILE = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		let condition = try parseExpression()
		
		guard case Token.DO = tokens.pop() else
		{
			throw ParserError.ExpectedToken(Token.DO)
		}
		
		var commandForest: [AST_Node] = [AST_Node]()
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
	
	private func parseConditional () throws -> ConditionalNode
	{
		guard case Token.IF = tokens.pop() else
		{
			throw ParserError.UnexpectedToken
		}
		
		let condition = try parseExpression()
		
		guard case Token.THEN = tokens.pop() else
		{
			throw ParserError.ExpectedToken(Token.THEN)
		}
		
		var commandForest: [AST_Node] = [AST_Node]()
		var commandForestTrue: [AST_Node] = [AST_Node]()
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
				commandForest = [AST_Node]()
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
			return ConditionalNode(condition: condition, commandTrue: commandForest, commandFalse: [AST_Node]())
		}
	}
	
	private func parseGrammar () throws -> AST_Node
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
	
	public func parse () throws -> [AST_Node]
	{
		var nodes = [AST_Node]()
		while !tokens.isEmpty()
		{
			let node = try parseGrammar()
			nodes.append(node)
		}
		
		return nodes
	}
}
