import Foundation

public enum ParserError: Error
{
	case ExpectedNumber
	case ExpectedIdentifier
	case ExpectedCharacter(Character)
	case ExpectedExpression
	case UndefinedOperator(String)
	case ExpectedOperator
}

private let operatorPrecedence: [String: Int] =
[
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
		self.tokens = Pile<Token>()
		self.tokens.start_by_list(list: tokens)
	}
	
	private func parseNumber () throws -> ExprNode
	{
		guard case let Token.NUMBER(value) = tokens.pop() else
		{
			throw ParserError.ExpectedNumber
		}
		
		return NumberNode(value: value)
	}
	
	private func parseIdentifier () throws -> ExprNode
	{
		guard case let Token.IDENTIFIER(name) = tokens.pop() else
		{
			throw ParserError.ExpectedIdentifier
		}
		
		return VariableNode(name: name)
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
			default:
				throw ParserError.ExpectedExpression
		}
	}
	
	private func getCurrentTokenPrecedence () throws -> Int
	{
		guard !tokens.isEmpty() else
		{
			return -1
		}
		
		guard case let Token.OTHER(op) = tokens.peek() else
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
			
			guard case let Token.OTHER(op) = tokens.pop() else
			{
				throw ParserError.ExpectedOperator
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
}
