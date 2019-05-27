# piframework

This package wraps all the pi-framework logic, here is where all associated functions and objects are defined.


----------------
###### NUM
- δ(Num(N) :: C, V, S) = δ(C, N :: V, S)
		case "Num":
					value.push(value: operatorNode)
					break

----------------
###### SUM
- δ(Sum(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #SUM :: C, V, S)
        case "Sum":
                    control.push(value: PiFuncNode(function: "#SUM"))
                    control.push(value: operatorNode.lhs)
                    control.push(value: operatorNode.rhs)
                    break

- δ(#SUM :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ + N₂ :: V, S)
        case "#SUM":
                    operationResultFunction = "Num"
                    let values: [Float] = try popNumValues(value: value)
                    operationResult = "\(values[0]+values[1])"
                    break

----------------
###### SUB
- δ(Sub(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #SUB :: C, V, S)
        case "Sub":
                    control.push(value: PiFuncNode(function: "#SUB"))
                    control.push(value: operatorNode.lhs)
                    control.push(value: operatorNode.rhs)
                    break

- δ(#SUB :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ - N₂ :: V, S)
        case "#SUB":
                    operationResultFunction = "Num"
                    let values: [Float] = try popNumValues(value: value)
                    operationResult = "\(values[0]-values[1])"
                    break

----------------
###### MUL
- δ(Mul(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #MUL :: C, V, S)
        case "Mul":
                    control.push(value: PiFuncNode(function: "#MUL"))
                    control.push(value: operatorNode.lhs)
                    control.push(value: operatorNode.rhs)
                    break

- δ(#MUL :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ * N₂ :: V, S)
        case "#MUL":
                    operationResultFunction = "Num"
                    let values: [Float] = try popNumValues(value: value)
                    operationResult = "\(values[0]*values[1])"
                    break

----------------
###### DIV
- δ(Div(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #MUL :: C, V, S)
        case "Div":
                    control.push(value: PiFuncNode(function: "#DIV"))
                    control.push(value: operatorNode.lhs)
                    control.push(value: operatorNode.rhs)
                    break

- δ(#DIV :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ / N₂ :: V, S) if N₂ ≠ 0
        case "#DIV":
                    operationResultFunction = "Num"
                    let values: [Float] = try popNumValues(value: value)
                    operationResult = "\(values[0]/values[1])"
                    break

----------------
###### EQ
- δ(Eq(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #EQ :: C, V, S)
		case "Eq":
					control.push(value: PiFuncNode(function: "#EQ"))
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break

- δ(#EQ :: C, Boo(B₁) :: Boo(B₂) :: V, S) = δ(C, B₁ = B₂ :: V, S)
		case "#EQ":
					operationResultFunction = "Boo"
					var nodeHelper: AtomNode = value.pop() as! AtomNode
					let type1: String = nodeHelper.operation
					let value1: String = nodeHelper.value
					
					nodeHelper = value.pop() as! AtomNode
					let type2: String = nodeHelper.operation
					let value2: String = nodeHelper.value
					if type1 != type2
					{
						if type1 == "Num"
						{
							throw AutomatonError.ExpectedNumValue
						}
						else if type1 == "Boo"
						{
							throw AutomatonError.ExpectedBooValue
						}
					}
					operationResult = "\(value1==value2)"
					break

----------------
###### LT
- δ(Lt(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #LT :: C, V, S)
		case "Lt":
					control.push(value: PiFuncNode(function: "#LT"))
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break
- δ(#LT :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ < N₂ :: V, S)
		case "#LT":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]<values[1])"
					break

----------------
###### LE
- δ(Le(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #LE :: C, V, S)
		case "Le":
					control.push(value: PiFuncNode(function: "#LE"))
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break

- δ(#LE :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ ≤ N₂ :: V, S)
		case "#LE":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]<=values[1])"
					break

----------------
###### GT
- δ(Gt(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #GT :: C, V, S)
		case "Gt":
					control.push(value: PiFuncNode(function: "#GT"))
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break
- δ(#GT :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ > N₂ :: V, S)
		case "#GT":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]>values[1])"
					break

----------------
###### GE
- δ(Ge(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #GE :: C, V, S)
		case "Ge":
					control.push(value: PiFuncNode(function: "#GE"))
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break

- δ(#GE :: C, Num(N₁) :: Num(N₂) :: V, S) = δ(C, N₁ ≥ N₂ :: V, S)
		case "#GE":
					operationResultFunction = "Boo"
					let values: [Float] = try popNumValues(value: value)
					operationResult = "\(values[0]>=values[1])"
					break

----------------
###### AND
- δ(And(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #AND :: C, V, S)
		case "And":
					control.push(value: PiFuncNode(function: "#AND"))
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break

- δ(#AND :: C, Boo(B₁) :: Boo(B₂) :: V, S) = δ(C, B₁ ∧ B₂ :: V, S)
		case "#AND":
					operationResultFunction = "Boo"
					let values: [Bool] = try popBooValues(value: value)
					operationResult = "\(values[0]&&values[1])"
					break

----------------
###### OR
- δ(Or(E₁, E₂) :: C, V, S) = δ(E₁ :: E₂ :: #OR :: C, V, S)
		case "Or":
					control.push(value: PiFuncNode(function: "#OR"))
					control.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break

- δ(#OR :: C, Boo(B₁) :: Boo(B₂) :: V, S) = δ(C, B₁ ∨ B₂ :: V, S)
		case "#OR":
					operationResultFunction = "Boo"
					let values: [Bool] = try popBooValues(value: value)
					operationResult = "\(values[0]||values[1])"
					break

----------------
###### NOT
- δ(Not(E) :: C, V, S) = δ(E :: #NOT :: C, V, S)
		case "Not":
					control.push(value: PiFuncNode(function: "#NOT"))
					control.push(value: operatorNode.expression)
					break

- δ(#NOT :: C, Boo(True) :: V, S) = δ(C, False :: V, S)
- δ(#NOT :: C, Boo(False) :: V, S) = δ(C, True :: V, S)
		case "#NOT":
					operationResultFunction = "Boo"
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					let booleanHelper: Bool = Bool(nodeHelper.value)!
					operationResult = "\(!booleanHelper)"
					break

----------------
###### ID
- δ(Id(W) :: C, V, E, S) = δ(C, B :: V, E, S), where E[W] = l ∧ S[l] = B
		case "Id":
					let localizable: Localizable = enviroment[operatorNode.value]!
					let nodeHelper: AtomNode = storage[localizable.address]!
					value.push(value: nodeHelper)
					value.push(value: operatorNode)
					return

----------------
###### ASSIGN
- δ(Assign(W, X) :: C, V, E, S) = δ(X :: #ASSIGN :: C, W :: V, E, S')
		case "Assign":
					control.push(value: PiFuncNode(function: "#ASSIGN"))
					value.push(value: operatorNode.lhs)
					control.push(value: operatorNode.rhs)
					break

- δ(#ASSIGN :: C, T :: W :: V, E, S) = δ(C, V, E, S'), where E[W] = l ∧ S' = S/[l ↦ T]
		case "#ASSIGN":
					let nodeAsgValue: AtomNode = value.pop() as! AtomNode
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					if (nodeHelper.operation != "Id")
					{
						throw AutomatonError.ExpectedIdentifier
					}
					let idName: String = nodeHelper.value
					let localizable: Localizable
					if enviroment[idName] != nil
					{
						localizable = enviroment[idName]!
					}
					else
					{
						localizable = Localizable(address: memorySpace)
						memorySpace += 1
						enviroment[idName] = localizable
					}
					storage[localizable.address] = nodeAsgValue
					return

----------------
###### LOOP
- δ(Loop(X, M) :: C, V, E, S) = δ(X :: #LOOP :: C, Loop(X, M) :: V, E, S)
		case "Loop":
					control.push(value: PiFuncNode(function: "#LOOP"))
					control.push(value: operatorNode.lhs)
					value.push(value: operatorNode)
					break

- δ(#LOOP :: C, Boo(true) :: Loop(X, M) :: V, E, S) = δ(M :: Loop(X, M) :: C, V, E, S)
- δ(#LOOP :: C, Boo(false) :: Loop(X, M) :: V, E, S) = δ(C, V, E, S)
		case "#LOOP":
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					let conditionValue: Bool = Bool(nodeHelper.value)!
					let loop_node: BinaryOperatorNode = value.pop() as! BinaryOperatorNode
					
					if (conditionValue)
					{
						control.push(value: loop_node)
						control.push(value: loop_node.rhs)
					}
					return

----------------
###### COND
- δ(Cond(X, M₁, M₂) :: C, V, E, S) = δ(X :: #COND :: C, Cond(X, M₁, M₂) :: V, E, S)
		case "Cond":
					control.push(value: PiFuncNode(function: "#COND"))
					control.push(value: operatorNode.lhs)
					value.push(value: operatorNode)
					break

- δ(#COND :: C, Boo(true) :: Cond(X, M₁, M₂) :: V, E, S) = δ(M₁ :: C, V, E, S)
- δ(#COND :: C, Boo(false) :: Cond(X, M₁, M₂) :: V, E, S) = δ(M₂ :: C, V, E, S)
		case "#COND":
					let nodeHelper: AtomNode = value.pop() as! AtomNode
					let conditionValue: Bool = Bool(nodeHelper.value)!
					let cond_node: TernaryOperatorNode = value.pop() as! TernaryOperatorNode

					if (conditionValue)
					{
						control.push(value: cond_node.chs)
					}
					else
					{
						control.push(value: cond_node.rhs)
					}
					return

----------------
###### CSeq
- δ(CSeq(M₁, M₂) :: C, V, E, S) = δ(M₁ :: M₂ :: C, V, E, S)
		case "CSeq":
					control.push(value: operatorNode.rhs)
					control.push(value: operatorNode.lhs)
					break
