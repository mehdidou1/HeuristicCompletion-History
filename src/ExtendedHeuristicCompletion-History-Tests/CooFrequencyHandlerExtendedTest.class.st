Class {
	#name : 'CooFrequencyHandlerExtendedTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooFrequencyHandlerExtendedTest >> setUp [

	super setUp.
	handler := CooFrequencyHandler new
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testClassAndSelectorFrequenciesAreIndependent [

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #Widget; nameOfClass: 'A'; yourself).
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself).

	self assert: handler selectorEntries size equals: 1.
	self assert: handler classEntries size equals: 1
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testEmptyHandlerReturnsEmptyEntries [

	self assert: handler selectorEntries isEmpty.
	self assert: handler classEntries isEmpty
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testFrequencyOrderingWithThreeSelectors [
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
CooFrequencyHandlerExtendedTest >> testModifiedClassIncrementsSameKey [

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself).
	handler handleNewClassItem: (CooModifiedClassHistoryItem new nameOfClass: 'Widget'; yourself).

	self assert: handler classEntries size equals: 1.
	self assert: handler classEntries first contents equals: 'Widget'
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testModifiedMethodIncrementsSameKeyAsAdded [

	| added modified |
	added := CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself.
	modified := CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself.

	handler handleNewMethodItem: added.
	handler handleNewMethodItem: modified.
	self assert: handler selectorEntries size equals: 1.
	self assert: handler selectorEntries first selector equals: #foo
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testModifiyingNonExistingClassDoesNotCrash [

	handler handleNewClassItem: (CooModifiedClassHistoryItem new nameOfClass: 'Widget'; yourself).
	self assert: handler classEntries size equals: 1
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testModifiyingNonExistingMethodDoesNotCrash [

	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'Widget'; yourself).
	self assert: handler selectorEntries size equals: 1
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testRemoveClass [
	
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget').
	self assert: handler classEntries first contents equals: 'Widget'.
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'Widget'). 
	self assert: handler classEntries isEmpty
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testRemoveClassRemovesMethods [

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'Widget'; yourself).
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself).
	
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'Widget').
	self assert: handler classEntries isEmpty .
	self assert: handler selectorEntries isEmpty 
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testRemoveMethod [
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'Widget'; yourself).
	self assert: handler selectorEntries first contents equals: #foo.
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'Widget'; yourself).
	self assert: handler selectorEntries isEmpty
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testRemoveNonExistentClassDoesNotCrash [

	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'Ghost'; yourself).

	self assert: handler classEntries isEmpty
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testRemoveNonExistentSelectorDoesNotCrash [

	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #ghost; nameOfClass: 'A'; yourself).

	self assert: handler selectorEntries isEmpty
]

{ #category : 'tests' }
CooFrequencyHandlerExtendedTest >> testRemoveThenReAddStartsFresh [

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).

	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	self assert: handler selectorEntries isEmpty.

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	self assert: handler selectorEntries size equals: 1
]
