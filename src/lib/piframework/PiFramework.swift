import Foundation

/// - Define the enumeration for the error that can be throw during automaton.
public enum AutomatonError: Error
{
	case UndefinedOperationCode(OperationCode)
	case UndefinedAbstractSyntaxTreePiNode(AbstractSyntaxTreePiExtended)
}

/// - Define the concept for the Pi-Framework, where the magic will happen.
public class PiFramework
{
	var memoryPosition: Int
	let abstractSyntaxTreePi: AbstractSyntaxTreePi
	
	let piFrameworkHandler: PiFrameworkHandler = PiFrameworkHandler()
	
	/// - This class initializer.
	init (ast_pi: AbstractSyntaxTreePi)
	{
		self.memoryPosition = 0
		self.abstractSyntaxTreePi = ast_pi
	}

	/// - Function for define the concept of the Pi-Framework automaton.
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
				if !envConfiguration.ignore_error && !envConfiguration.state_print && envConfiguration.state_n_print != steps_count 
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
	
	/// - Helper function for the automaton, this define the logic for changing the state of the automaton based in the argument values.
	private func delta (controlStack: Stack<AbstractSyntaxTreePiExtended>, valueStack: Stack<AutomatonValue>, storage: inout [Int: AutomatonStorable], environment: inout [String: AutomatonBindable], locationList: inout [Location]) throws
	{
		let command: AbstractSyntaxTreePiExtended = controlStack.pop()
		if command is OperationCode
		{
			if command is MultiplicationOperationCode
			{
				try piFrameworkHandler.processMultiplicationOperationCode(valueStack: valueStack)
			}
			else if command is DivisionOperationCode
			{
				try piFrameworkHandler.processDivisionOperationCode(valueStack: valueStack)
			}
			else if command is SumOperationCode
			{
				try piFrameworkHandler.processSumOperationCode(valueStack: valueStack)
			}
			else if command is SubtractionOperationCode
			{
				try piFrameworkHandler.processSubtractionOperationCode(valueStack: valueStack)
			}
			else if command is EqualToOperationCode
			{
				try piFrameworkHandler.processEqualToOperationCode(valueStack: valueStack)
			}
			else if command is AndConnectiveOperationCode
			{
				try piFrameworkHandler.processAndConnectiveOperationCode(valueStack: valueStack)
			}
			else if command is OrConnectiveOperationCode
			{
				try piFrameworkHandler.processOrConnectiveOperationCode(valueStack: valueStack)
			}
			else if command is LowerThanOperationCode
			{
				try piFrameworkHandler.processLowerThanOperationCode(valueStack: valueStack)
			}
			else if command is LowerEqualToOperationCode
			{
				try piFrameworkHandler.processLowerEqualToOperationCode(valueStack: valueStack)
			}
			else if command is GreaterThanOperationCode
			{
				try piFrameworkHandler.processGreaterThanOperationCode(valueStack: valueStack)
			}
			else if command is GreaterEqualToOperationCode
			{
				try piFrameworkHandler.processGreaterEqualToOperationCode(valueStack: valueStack)
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
				try piFrameworkHandler.processBlockDeclarationOperationCode(code: command as! BlockDeclarationOperationCode, valueStack: valueStack, environment: &environment)
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
			else if command is CallOperationCode
			{
				try piFrameworkHandler.processCallOperationCode(code: command as! CallOperationCode, controlStack: controlStack, valueStack: valueStack, environment: &environment)
			}
			else
			{
				throw AutomatonError.UndefinedOperationCode(command as! OperationCode)
			}
		}
		else if command is MultiplicationOperationPiNode
		{
			try piFrameworkHandler.processMultiplicationOperationPiNode(node: command as! MultiplicationOperationPiNode, controlStack: controlStack)
		}
		else if command is DivisionOperationPiNode
		{
			try piFrameworkHandler.processDivisionOperationPiNode(node: command as! DivisionOperationPiNode, controlStack: controlStack)
		}
		else if command is SumOperationPiNode
		{
			try piFrameworkHandler.processSumOperationPiNode(node: command as! SumOperationPiNode, controlStack: controlStack)
		}
		else if command is SubtractionOperationPiNode
		{
			try piFrameworkHandler.processSubtractionOperationPiNode(node: command as! SubtractionOperationPiNode, controlStack: controlStack)
		}
		else if command is IdentifierPiNode
		{
			try piFrameworkHandler.processIdentifierPiNode(node: command as! IdentifierPiNode, valueStack: valueStack, storage: storage, environment: environment)
		}
		else if command is NumberPiNode
		{
			piFrameworkHandler.processNumberPiNode(node: command as! NumberPiNode, valueStack: valueStack)
		}
		else if command is LogicalClassificationPiNode
		{
			piFrameworkHandler.processLogicalClassificationPiNode(node: command as! LogicalClassificationPiNode, valueStack: valueStack)
		}
		else if command is EqualToOperationPiNode
		{
			try piFrameworkHandler.processEqualToOperationPiNode(node: command as! EqualToOperationPiNode, controlStack: controlStack)
		}
		else if command is AndConnectivePiNode
		{
			try piFrameworkHandler.processAndConnectivePiNode(node: command as! AndConnectivePiNode, controlStack: controlStack)
		}
		else if command is OrConnectivePiNode
		{
			try piFrameworkHandler.processOrConnectivePiNode(node: command as! OrConnectivePiNode, controlStack: controlStack)
		}
		else if command is LowerThanOperationPiNode
		{
			try piFrameworkHandler.processLowerThanOperationPiNode(node: command as! LowerThanOperationPiNode, controlStack: controlStack)
		}
		else if command is LowerEqualToOperationPiNode
		{
			try piFrameworkHandler.processLowerEqualToOperationPiNode(node: command as! LowerEqualToOperationPiNode, controlStack: controlStack)
		}
		else if command is GreaterThanOperationPiNode
		{
			try piFrameworkHandler.processGreaterThanOperationPiNode(node: command as! GreaterThanOperationPiNode, controlStack: controlStack)
		}
		else if command is GreaterEqualToOperationPiNode
		{
			try piFrameworkHandler.processGreaterEqualToOperationPiNode(node: command as! GreaterEqualToOperationPiNode, controlStack: controlStack)
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
		else if command is RecursiveBindableOperationPiNode
		{
			try piFrameworkHandler.processRecursiveBindableOperationPiNode(node: command as! RecursiveBindableOperationPiNode, valueStack: valueStack, environment: environment)
		}
		else if command is AllocateReferencePiNode
		{
			piFrameworkHandler.processAllocateReferencePiNode(node: command as! AllocateReferencePiNode, controlStack: controlStack)
		}
		else if command is AbstractionPiNode
		{
			piFrameworkHandler.processAbstractionPiNode(node: command as! AbstractionPiNode, valueStack: valueStack, environment: environment)
		}
		else if command is CallPiNode
		{
			piFrameworkHandler.processCallPiNode(node: command as! CallPiNode, controlStack: controlStack)
		}
		else
		{
			throw AutomatonError.UndefinedAbstractSyntaxTreePiNode(command)
		}
	}
}
