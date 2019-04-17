import Foundation

public enum ParserError: Error
{
	case UnexpectedToken
	case UndefinedOperator(String)
	
	case ExpectedCharacter(Character)
	case ExpectedExpression
	case ExpectedArgumentList
	case ExpectedFunctionName
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
			return VariableNode(name: name)
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
	
	private func parsePrototype () throws -> PrototypeNode
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
	
	private func parseDefinition () throws -> FunctionNode
	{
		tokens.skip()
		let prototype = try parsePrototype()
		let body = try parseExpression()
		return FunctionNode(prototype: prototype, body: body)
	}
	
	private func parseExtern () throws -> PrototypeNode
	{
		tokens.skip()
		return try parsePrototype()
	}
	
	private func parseTopLevelExpr () throws -> FunctionNode
	{
		let prototype = PrototypeNode(name: "", argumentNames: [])
		let body = try parseExpression()
		return FunctionNode(prototype: prototype, body: body)
	}
	
	public func parse () throws -> [AST_Node]
	{
		var nodes = [AST_Node]()
		while !tokens.isEmpty()
		{
			switch (tokens.peek())
			{
				case Token.SEMICOLON:
					tokens.skip()
					break
				case Token.DEFINE:
					let node = try parseDefinition()
					nodes.append(node)
					break
				case Token.EXTERN:
					let node = try parseExtern()
					nodes.append(node)
					break
				default:
					let expr = try parseExpression()
					nodes.append(expr)
			}
		}
		
		return nodes
	}
}
