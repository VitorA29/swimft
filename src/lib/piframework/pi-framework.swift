import Foundation

public enum TranformerError: Error
{
	case UndefinedOperator(String)
	case UndefinedASTNode(AST_Node)
}

public enum AutomatonError: Error
{
	case UndefinedOperation(String)
	case UndefinedCommand(String)
	case UnexpectedNilValue
	case InvalidValueExpected
}

public class PiFramework
{
	public func transformer (ast_imp: AST_Node) throws -> AST_Pi
	{
		var ast_pi: AST_Pi
		if ast_imp is BinaryOpNode
		{
			let node: BinaryOpNode = ast_imp as! BinaryOpNode
			var operation: String
			switch (node.op)
			{
				// Aritimetic Operators
				case "*":
					operation = "MUL"
					break
				case "/":
					operation = "DIV"
					break
				case "+":
					operation = "SUM"
					break
				case "-":
					operation = "SUB"
					break
				// Logical Operators
				case "<":
					operation = "LOW"
					break
				case "<=":
					operation = "LEQ"
					break
				case ">":
					operation = "GTR"
					break
				case ">=":
					operation = "GEQ"
					break
				case "==":
					operation = "EQL"
					break
				default:
					throw TranformerError.UndefinedOperator(node.op)
			}
			let lhs: ExpressionNode = try transformer(ast_imp: node.lhs) as! ExpressionNode
			let rhs: ExpressionNode = try transformer(ast_imp: node.rhs) as! ExpressionNode
			
			ast_pi = BinaryOperatorNode(operation: operation, lhs: lhs, rhs: rhs)
		}
		else if ast_imp is AssignNode
		{
			let node: AssignNode = ast_imp as! AssignNode
			let lhs: ExpressionNode = try transformer(ast_imp: node.variable) as! ExpressionNode
			let rhs: ExpressionNode = try transformer(ast_imp: node.expression) as! ExpressionNode
			ast_pi = BinaryOperatorNode(operation: "ASSIGN", lhs: lhs, rhs: rhs)
		}
		else if ast_imp is NumberNode
		{
			let node: NumberNode = ast_imp as! NumberNode
			ast_pi = AtomNode(function: "NUM", value: "\(node.value)")
		}
		else if ast_imp is VariableNode
		{
			let node: VariableNode = ast_imp as! VariableNode
			ast_pi = AtomNode(function: "ID", value: "\(node.name)")
		}
		else if ast_imp is BooleanNode
		{
			let node: BooleanNode = ast_imp as! BooleanNode
			ast_pi = AtomNode(function: "BOOL", value: "\(node.value)")
		}
		else
		{
			throw TranformerError.UndefinedASTNode(ast_imp)
		}
		return ast_pi
	}
}
