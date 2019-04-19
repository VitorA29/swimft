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
	"<": 10,
	"<=": 10,
	">": 10,
	">=": 10,
	"==": 10,
	"+": 20,
	"-": 20,
	"*": 40,
	"/": 40
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
		
		guard case Token.BRACKET_LEFT = tokens.peek() else
		{
			guard case Token.ASSIGN = tokens.peek() else
			{
				return VariableNode(name: name)
			}
			
			// skip assign
			tokens.skip()
			
			let expression = try parseExpression()
			
			return AssignNode(variable: VariableNode(name: name), expression: expression)
		}
		
		// skip '('
		tokens.skip()
		
		var arguments = [ExprNode]()
		if case Token.BRACKET_RIGHT = tokens.peek()
		{
		}
		else
		{
			while true
			{
				let argument = try parseExpression()
				arguments.append(argument)
				
				if case Token.BRACKET_RIGHT = tokens.peek()
				{
					break
				}
				
				guard case Token.COMMA = tokens.pop() else
				{
					throw ParserError.ExpectedArgumentList
				}
			}
		}
		
		// skip ')'
		tokens.skip()
		return CallNode(call: name, arguments: arguments)
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
	
	private func parseCall () throws -> PrototypeNode
	{
		guard case let Token.IDENTIFIER(name) = tokens.pop() else
		{
			throw ParserError.ExpectedFunctionName
		}
		
		guard case Token.BRACKET_LEFT = tokens.pop() else
		{
			throw ParserError.ExpectedCharacter("(")
		}
		
		var argumentNames = [String]()
		while case let Token.IDENTIFIER(name) = tokens.peek()
		{
			tokens.skip()
			argumentNames.append(name)
			
			if case Token.BRACKET_RIGHT = tokens.peek()
			{
				break
			}
			
			guard case Token.COMMA = tokens.pop() else
			{
				throw ParserError.ExpectedArgumentList
			}
		}
		
		// skip ')'
		tokens.skip()
		return PrototypeNode(name: name, argumentNames: argumentNames)
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
		
		let command = try parse()
		
		return WhileNode(condition: condition, command: command)
	}
	
	public func parse () throws -> [AST_Node]
	{
		var nodes = [AST_Node]()
		while !tokens.isEmpty()
		{
			switch (tokens.peek())
			{
				case Token.IDENTIFIER:
					let node = try parseIdentifier()
					nodes.append(node)
					break
				case Token.WHILE:
					let node = try parseLoop()
					nodes.append(node)
					break
				default:
					let expr = try parseExpression()
					nodes.append(expr)
					break
			}
		}
		
		return nodes
	}
}
