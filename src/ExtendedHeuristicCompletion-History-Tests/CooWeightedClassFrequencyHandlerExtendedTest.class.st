Class {
	#name : 'CooWeightedClassFrequencyHandlerExtendedTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooWeightedClassFrequencyHandlerExtendedTest >> setUp [

	super setUp.
	handler := CooWeightedClassFrequencyHandler new
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testAddMethodWhenClassExistsIncrementsClassFrequency [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA').
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassB').
	"Normally Class B has the highest frequency, adding a method on Class A should make it the highest frequency class"
	
	self assert: handler classEntries first contents equals: 'ClassB' . 
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself).
	self assert: handler classEntries first contents equals: 'ClassA'
	 
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testAddMethodWithoutExistingClassAddsIt [ 
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'Class'; yourself).
	
	self assert: handler classEntries size equals: 1.
	self assert: handler classEntries first contents equals: 'Class' 
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testAddingMethodIncrementsClassFrequency [ 
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	
	self assert: (handler frequencyOfClass: 'ClassA' ) equals: 1.
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	
	self assert: (handler frequencyOfClass: 'ClassA' ) equals: 2.
	

	
	
	
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassAndSelectorFrequenciesAreIndependent [

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #widget; nameOfClass: 'A'; yourself).
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'B'; yourself).

	self assert: handler selectorEntries size equals: 1.
	self assert: handler classEntries size equals: 2
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassTOMethodMapWhenAAddingAnClass [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself).
	
	self assert: handler classToMethodsMap size equals: 1.
	self assert: (handler classToMethodsMap includesKey: 'ClassA').
	self assert: (handler classToMethodsMap at: 'ClassA') value equals: (Set new).
	
	
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassTOMethodMapWhenAddingAMethodToAnExistingClass [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	
	self assert: handler classToMethodsMap size equals: 1.
	self assert: (handler classToMethodsMap includesKey: 'ClassA').
   self assert: (handler classToMethodsMap at: 'ClassA') size equals: 1.
	self assert: ((handler classToMethodsMap at: 'ClassA') includes: #foo).
	
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassTOMethodMapWhenAddingAMethodToAnInexistingClassAddsClassAndMethod [
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	
	self assert: handler classToMethodsMap size equals: 1.
	self assert: (handler classToMethodsMap includesKey: 'ClassA')
	
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassTOMethodMapWhenModifyingMethod [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'). 
	
	self assert: (handler classToMethodsMap at: 'ClassA') size equals: 1
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassTOMethodMapWhenRemoveInexistingMethodDoesNotCrash [
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	self assert: handler classToMethodsMap isEmpty
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassTOMethodMapWhenRemovingAMethodRemovesItFromTheMap [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	
	self assert: (handler classToMethodsMap at: 'ClassA') size equals: 1.
	self deny: ((handler classToMethodsMap at: 'ClassA') value includes: #foo) 
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassTOMethodMapWhenRemovingClassRemovesKeyFromMap [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	self assert: handler classToMethodsMap isEmpty 
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testClassToMethodMapIsEmptyWhenInitialized [
	self assert: handler classToMethodsMap isEmpty 
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testEmptyHandlerReturnsEmptyEntries [

	self assert: handler selectorEntries isEmpty.
	self assert: handler classEntries isEmpty
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testFrequencyOrderingWithThreeSelectors [
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #alpha; nameOfClass: 'A'; yourself).

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #beta; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #beta; nameOfClass: 'A'; yourself).

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #gamma; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #gamma; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #gamma; nameOfClass: 'A'; yourself).
	self assert: handler selectorEntries first selector equals: #gamma.
	self assert: handler selectorEntries second selector equals: #beta.
	self assert: handler selectorEntries third selector equals: #alpha
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testModifiedClassIncrementsSameKey [

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself).
	handler handleNewClassItem: (CooModifiedClassHistoryItem new nameOfClass: 'Widget'; yourself).

	self assert: handler classEntries size equals: 1.
	self assert: handler classEntries first contents equals: 'Widget'
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testModifiedMethodIncrementsSameKeyAsAdded [

	| added modified |
	added := CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself.
	modified := CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself.

	handler handleNewMethodItem: added.
	handler handleNewMethodItem: modified.
	self assert: handler selectorEntries size equals: 1.
	self assert: handler selectorEntries first selector equals: #foo
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testModifiyingNonExistingClassDoesNotCrash [

	handler handleNewClassItem: (CooModifiedClassHistoryItem new nameOfClass: 'Widget'; yourself).
	self assert: handler classEntries size equals: 1
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testModifiyingNonExistingMethodDoesNotCrash [

	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'Widget'; yourself).
	self assert: handler selectorEntries size equals: 1
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testModifyMethodIncrementsClassFrequency [ 
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA').
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassB').
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassB'; yourself).

	"Class B should be the class with the highest frequency" 
	self assert: handler classEntries first contents equals: 'ClassB'.
	
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself).
	self assert: handler classEntries first contents equals: 'ClassA'.	
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemoveClass [
	
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget').
	self assert: handler classEntries first contents equals: 'Widget'.
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'Widget'). 
	self assert: handler classEntries isEmpty
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemoveClassDecrementsAllMethodsFrequency [ 
	| before after|

"Class A defines three methods m1, m2 and m3"

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #m1; nameOfClass: 'ClassA'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #m2; nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #m3; nameOfClass: 'ClassA'; yourself).

	before := handler selectorFrequencies. 
		
"Deleting class A should make the difference"
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
		
	after := handler selectorFrequencies.
	
	self assert: after equals: (before collect: [:each | each - 1]).

	self assert: (handler frequencyOfMethod: #m1) equals: 0.
	self assert: (handler frequencyOfMethod: #m2) equals: 0.
	self assert: (handler frequencyOfMethod: #m3) equals: 0.
		
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemoveClassDecrementsOnlyThatClassMethodFrequencies [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassB'; yourself ).
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector:#foo; nameOfClass: 'ClassA'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector:#foo; nameOfClass: 'ClassB'; yourself).
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector:#bar; nameOfClass: 'ClassB'; yourself).
	
	self assert: (handler frequencyOfMethod: #foo) equals: 2.
	self assert: (handler frequencyOfMethod: #bar) equals: 1.
	
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	
	"#foo is now decremented and #bar stay untouched"
	self assert: (handler frequencyOfMethod: #foo) equals: 1.
	self assert: (handler frequencyOfMethod: #bar) equals: 1.
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemoveNonExistentClassDoesNotCrash [

	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'Ghost'; yourself).

	self assert: handler classEntries isEmpty
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemoveNonExistentSelectorDoesNotCrash [

	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #ghost; nameOfClass: 'A'; yourself).

	self assert: handler selectorEntries size equals: 0
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemoveThenReAddStartsFresh [

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).

	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	self assert: handler selectorEntries size equals: 1.

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	self assert: handler selectorEntries size equals: 1
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemovingClassRemovesClassFromClassDictionnary [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	
	self assert: handler classEntries isEmpty 
	

	
]

{ #category : 'tests' }
CooWeightedClassFrequencyHandlerExtendedTest >> testRemovingMethodIncreasesClassFrequency [ 
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	
	self assert: (handler frequencyOfClass: 'ClassA' ) equals: 2.
	
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ).
	
	self assert: (handler frequencyOfClass: 'ClassA' ) equals: 3.
	
]
