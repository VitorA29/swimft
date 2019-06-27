import Foundation

/// #START_DOC
/// - Define the enumeration for the error that can be throw during automaton.
/// #END_DOC
public enum AutomatonError: Error
{
	case UndefinedOperationCode(OperationCode)
	case UndefinedAbstractSyntaxTreePiNode(AbstractSyntaxTreePiExtended)
}

/// #START_DOC
/// - Define the concept for the Pi-Framework, where the magic will happen.
/// #END_DOC
public class PiFramework
{
	var memoryPosition: Int
	let abstractSyntaxTreePi: AbstractSyntaxTreePi
	
	// handlers
	let piFrameworkHandler: PiFrameworkHandler = PiFrameworkHandler()
	// let arithmeticExpressionHandler: ArithmeticExpressionHandler = ArithmeticExpressionHandler()
	// let atomicHandler: AtomicHandler = AtomicHandler()
	// let logicalExpressionHandler: LogicalExpressionHandler = LogicalExpressionHandler()
	
	/// #START_DOC
	/// - This class initializer.
	/// #END_DOC
	init (ast_pi: AbstractSyntaxTreePi)
	{
		self.memoryPosition = 0
		self.abstractSyntaxTreePi = ast_pi
	}

	/// #START_DOC
	/// - Function for define the concept of the Pi-Framework automaton, for executing a AST_Pi.
	/// #END_DOC
	public func execute () throws
	{
		let controlStack: Stack<AbstractSyntaxTreePiExtended> = Stack<AbstractSyntaxTreePiExtended>()
		controlStack.push(value: abstractSyntaxTreePi)
		let valueStack: Stack<AutomatonValue> = Stack<AutomatonValue>()
		var storage: [Int: AutomatonStorable] = [Int: AutomatonStorable]()
		var environment: [String: AutomatonBindable] = [String: AutomatonBindable]()
		var locationList: [Location] = [Location]()
		var steps_count: Int = 0
		var last_state: String = "{ n: \(steps_count), c: \(controlStack), v: \(valueStack), s: \(storage), e: \(environment), l: \(locationList) }"
		repeat
		{
			if envConfiguration.state_print || envConfiguration.state_n_print == steps_count
			{
				print("\(last_state)")
			}
			do
			{
				try self.delta(controlStack: controlStack, valueStack: valueStack, storage: &storage, environment: &environment, locationList: &locationList)
			}
			catch
			{
				if !envConfiguration.state_print && envConfiguration.state_n_print != steps_count
				{
					print("\(last_state)")
				}
				throw error
			}
			steps_count += 1
			last_state = "{ n: \(steps_count), c: \(controlStack), v: \(valueStack), s: \(storage), e: \(environment), l: \(locationList) }"
		}while(!controlStack.isEmpty())
		if envConfiguration.state_print || envConfiguration.last_state_print
		{
			print("\(last_state)")
		}
	}
	
	/// #START_DOC
	/// - Helper function for the automaton, this define the logic for change the state of the automaton based in the argument values.
	/// #END_DOC
	private func delta (controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>, storage: inout [Int: AutomatonStorable], environment: inout [String: AutomatonBindable], locationList: inout [Location]) throws
	{
		let command: AbstractSyntaxTreePiExtended = controlStack.pop()
		if command is OperationCode
		{
			if command is ArithmeticOperationCode
			{
				try piFrameworkHandler.processArithmeticOperationCode(operationCode: command as! ArithmeticOperationCode, valueStack: valueStack)
			}
			else if command is EqualToOperationCode
			{
				try piFrameworkHandler.processEqualToOperationCode(valueStack: valueStack)
			}
			else if command is LogicalConnectionOperationCode
			{
				try piFrameworkHandler.processLogicalConnectionOperationCode(operationCode: command as! LogicalConnectionOperationCode, valueStack: valueStack)
			}
			else if command is InequalityOperationCode
			{
				try piFrameworkHandler.processInequalityOperationCode(operationCode: command as! InequalityOperationCode, valueStack: valueStack)
			}
			else if command is NegationOperationCode
			{
				try piFrameworkHandler.processNegationOperationCode(valueStack: valueStack)
			}
			else if command is AssignOperationCode
			{
				try piFrameworkHandler.processAssignOperationCode(valueStack: valueStack, storage: &storage, environment: environment)
			}
			else if command is BindableOperationCode
			{
				try piFrameworkHandler.processBindableOperationCode(valueStack: valueStack)
			}
			else if command is AllocateReferenceOperationCode
			{
				try piFrameworkHandler.processAllocateReferenceOperationCode(valueStack: valueStack, memoryPosition: &memoryPosition, storage: &storage, locationList: &locationList)
			}
			else if command is BlockCommandOperationCode
			{
				try piFrameworkHandler.processBlockCommandOperationCode(valueStack: valueStack, storage: &storage, environment: &environment, locationList: &locationList)
			}
			else if command is BlockDeclarationOperationCode
			{
				try piFrameworkHandler.processBlockDeclarationOperationCode(valueStack: valueStack, environment: &environment)
			}
			else if command is ConditionalOperationCode
			{
				try piFrameworkHandler.processConditionalOperationCode(controlStack: controlStack, valueStack: valueStack)
			}
			else if command is LoopOperationCode
			{
				try piFrameworkHandler.processLoopOperationCode(controlStack: controlStack, valueStack: valueStack)
			}
			else if command is PrintOperationCode
			{
				try piFrameworkHandler.processPrintOperationCode(valueStack: valueStack)
			}
			else
			{
				throw AutomatonError.UndefinedOperationCode(command as! OperationCode)
			}
		}
		else if command is ArithmeticOperationPiNode
		{
			try piFrameworkHandler.processArithmeticOperationPiNode(node: command as! ArithmeticOperationPiNode, controlStack: controlStack)
		}
		else if command is IdentifierPiNode
		{
			try piFrameworkHandler.processIdentifierPiNode(node: command as! IdentifierPiNode, valueStack: valueStack, storage: storage, environment: environment)
		}
		else if command is NumberPiNode
		{
			try piFrameworkHandler.processNumberPiNode(node: command as! NumberPiNode, valueStack: valueStack)
		}
		else if command is LogicalClassificationPiNode
		{
			try piFrameworkHandler.processLogicalClassificationPiNode(node: command as! LogicalClassificationPiNode, valueStack: valueStack)
		}
		else if command is EqualToOperationPiNode
		{
			try piFrameworkHandler.processEqualToOperationPiNode(node: command as! EqualToOperationPiNode, controlStack: controlStack)
		}
		else if command is LogicalConnectionPiNode
		{
			try piFrameworkHandler.processLogicalConnectionPiNode(node: command as! LogicalConnectionPiNode, controlStack: controlStack)
		}
		else if command is InequalityOperationPiNode
		{
			try piFrameworkHandler.processInequalityOperationPiNode(node: command as! InequalityOperationPiNode, controlStack: controlStack)
		}
		else if command is NegationPiNode
		{
			try piFrameworkHandler.processNegationPiNode(node: command as! NegationPiNode, controlStack: controlStack)
		}
		else if command is NoOperationPiNode
		{
			piFrameworkHandler.processNoOperationPiNode()
		}
		else if command is DeclarationSequencePiNode
		{
			piFrameworkHandler.processDeclarationSequencePiNode(node: command as! DeclarationSequencePiNode, controlStack: controlStack)
		}
		else if command is CommandSequencePiNode
		{
			piFrameworkHandler.processCommandSequencePiNode(node: command as! CommandSequencePiNode, controlStack: controlStack)
		}
		else if command is AssignPiNode
		{
			piFrameworkHandler.processAssignPiNode(node: command as! AssignPiNode, controlStack: controlStack, valueStack: valueStack)
		}
		else if command is LoopPiNode
		{
			piFrameworkHandler.processLoopPiNode(node: command as! LoopPiNode, controlStack: controlStack, valueStack: valueStack)
		}
		else if command is ConditionalPiNode
		{
			piFrameworkHandler.processConditionalPiNode(node: command as! ConditionalPiNode, controlStack: controlStack, valueStack: valueStack)
		}
		else if command is BlockPiNode
		{
			piFrameworkHandler.processBlockPiNode(node: command as! BlockPiNode, controlStack: controlStack, valueStack: valueStack, locationList: &locationList)
		}
		else if command is PrintPiNode
		{
			piFrameworkHandler.processPrintPiNode(node: command as! PrintPiNode, controlStack: controlStack)
		}
		else if command is AddressReferencePiNode
		{
			try piFrameworkHandler.processAddressReferencePiNode(node: command as! AddressReferencePiNode, valueStack: valueStack, environment: environment)
		}
		else if command is ValueReferencePiNode
		{
			try piFrameworkHandler.processValueReferencePiNode(node: command as! ValueReferencePiNode, valueStack: valueStack, storage: storage, environment: environment)
		}
		else if command is BindableOperationPiNode
		{
			piFrameworkHandler.processBindableOperationPiNode(node: command as! BindableOperationPiNode, controlStack: controlStack, valueStack: valueStack)
		}
		else if command is AllocateReferencePiNode
		{
			piFrameworkHandler.processAllocateReferencePiNode(node: command as! AllocateReferencePiNode, controlStack: controlStack)
		}
		else
		{
			throw AutomatonError.UndefinedAbstractSyntaxTreePiNode(command)
		}
	}
}
