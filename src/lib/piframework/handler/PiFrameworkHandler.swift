import Foundation

/// - Define the enumeration for the error that can be throw during automaton basic nodes handling.
public enum AutomatonHandlerError: Error
{
	case ExpectedIdentifierNode
    case ExpectedNumValue
    case ExpectedBooValue
    case ExpectedStorableValue
	case ExpectedBindableValue
	case UndefinedVariable(String)
	case UndefinedStorageAddress
}

/// - Protocol that defines the basic operation needed in all handlers.
public class PiFrameworkHandler
{
	/// - Helper function for getting a <number> value from the value stack.
	public func popNumValue(valueStack: Stack<AutomatonValue>) throws -> Float
	{
		if valueStack.isEmpty() || !(valueStack.peek() is Float)
		{
			throw AutomatonHandlerError.ExpectedNumValue
		}
		return valueStack.pop() as! Float
	}
	
	/// - Helper function for getting a <truth> value from the value stack.
	public func popBooValue(valueStack: Stack<AutomatonValue>) throws -> Bool
	{
		if valueStack.isEmpty() || !(valueStack.peek() is Bool)
		{
			throw AutomatonHandlerError.ExpectedBooValue
		}
		return valueStack.pop() as! Bool
	}

	/// - Helper function for getting a storable from the value stack.
	public func popStorableValue(valueStack: Stack<AutomatonValue>) throws -> AutomatonStorable
	{
		if valueStack.isEmpty() || !(valueStack.peek() is AutomatonStorable)
		{
			throw AutomatonHandlerError.ExpectedStorableValue
		}
		return valueStack.pop() as! AutomatonStorable
	}

	/// - Helper function for getting a identifier from the value stack.
	public func popIdValue(valueStack: Stack<AutomatonValue>) throws -> String
	{
		if valueStack.isEmpty() || !(valueStack.peek() is IdentifierPiNode)
		{
			throw AutomatonHandlerError.ExpectedIdentifierNode
		}
		let nodeHelper: IdentifierPiNode = valueStack.pop() as! IdentifierPiNode
		return nodeHelper.name
	}

	/// - Helper function for getting a bindable from the value stack.
	public func popBindableValue(valueStack: Stack<AutomatonValue>) throws -> AutomatonBindable
	{
		if valueStack.isEmpty() || !(valueStack.peek() is AutomatonBindable)
		{
			throw AutomatonHandlerError.ExpectedBindableValue
		}
		return valueStack.pop() as! AutomatonBindable
	}

	/// - Helper function for getting a bindable value from the environment for the given key.
	public func getBindableValueFromEnvironment (key: String, environment: [String: AutomatonBindable]) throws -> AutomatonBindable
	{
		if environment[key] == nil
		{
			throw AutomatonHandlerError.UndefinedVariable(key)
		}
		return environment[key]!
	}

	/// - Helper function for getting a storable value from the storage for the given address.
	public func getStorableValueFromStorage (address: Int, storage: [Int: AutomatonStorable]) throws -> AutomatonStorable
	{
		if storage[address] == nil
		{
			throw AutomatonHandlerError.UndefinedStorageAddress
		}
		return storage[address]!
	}
}
