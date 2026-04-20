Class {
	#name : 'CooFrequencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooFrequencyHandlerTest >> setUp [

	super setUp.
	handler := CooFrequencyHandler new
]

{ #category : 'tests - class' }
CooFrequencyHandlerTest >> testAddingClassesSortsTheMostFrequent [

	| added1 aDifferentOne |
	added1 := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	aDifferentOne := CooAddedClassHistoryItem new
		nameOfClass: 'AnotherTestClass';
		yourself.
		
	handler handleNewClassItem: aDifferentOne.

	handler handleNewClassItem: added1.
	handler handleNewClassItem: added1.
	
	self assert: handler classEntries first contents equals: 'TestClass'.


	added1 := CooRemovedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewClassItem: added1.
	
	self assert: handler classEntries size equals: 1.
	self assert: handler classEntries first contents equals: 'AnotherTestClass' 
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testAddingMethodDoesNotAffectClassFrequency [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself). 
	
	self assert: (handler frequencyOfClass: 'ClassA') equals: 1.
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself).
	
	self assert: (handler frequencyOfClass: 'ClassA') equals: 1.
	
	
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testAddingMethodToInexistingClassAddsTheClass [	
	
	self assert: handler classEntries isEmpty.
	
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself).
	
	self assert: handler classEntries size equals: 1.
	self assert: (handler frequencyOfClass: 'ClassA') equals: 0.
	self assert: (handler classToMethodsMap size) equals: 1.
	self assert: (handler classToMethodsMap at: 'ClassA') value equals: (Set new add: #foo; yourself )
]

{ #category : 'tests - class' }
CooFrequencyHandlerTest >> testAddingThreeTimesTheSame [

	| added1 addedTheSame1 aDifferentOne |
	added1 := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	addedTheSame1 := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewClassItem: added1.
	handler handleNewClassItem: addedTheSame1.

	self assert: handler classEntries size equals: 1.

	aDifferentOne := CooAddedClassHistoryItem new
		nameOfClass: 'AnotherTestClass';
		yourself.
	handler handleNewClassItem: aDifferentOne.
	
	self assert: handler classEntries size equals: 2
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testDeleteClassDecrementsMethodFrequency [

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself). 
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself). 
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'ClassA'; yourself). 
	self assert: (handler frequencyOfMethod: #foo) equals: 2.
	self assert: (handler frequencyOfMethod: #bar) equals: 1.
	
	handler handleNewClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'ClassA'; yourself).
	
	self assert: (handler frequencyOfMethod: #foo) equals: 1.
	self assert: (handler frequencyOfMethod: #bar) equals: 0.		
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testDeleteMethodDoesNotAffectClassFrequency [

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ). 
	
	self assert: (handler frequencyOfClass: 'ClassA') equals: 1.
		
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ). 
	
	self assert: (handler frequencyOfClass: 'ClassA') equals: 1.

]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testModifyMethodDoesNotAffectClassFrequency [

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'ClassA'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ). 
	
	self assert: (handler frequencyOfClass: 'ClassA') equals: 1.
		
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ). 
	
	self assert: (handler frequencyOfClass: 'ClassA') equals: 1.
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testModifyMethodToInexistingClassAddsTheClass [	
	
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ). 
	
	self assert: (handler classEntries size) equals: 1.
	self assert: (handler classToMethodsMap size) equals: 1. 
	self assert: (handler classToMethodsMap at: 'ClassA') value equals: (Set new add: #foo; yourself )
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testNewAddModifiedMethodUpdateTheSameEntry [

	| later added modified |
	later := CooAddedMethodHistoryItem new
		selector: #rankedLaterSelector;
		nameOfClass: 'TestClass';
		yourself.
	added := CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	modified := CooModifiedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewMethodItem: later.
	handler handleNewMethodItem: added.
	handler handleNewMethodItem: modified.

	self assert: handler selectorEntries size equals: 2.
	"SampleSelector got 2 and rankedLaterSelector 1 so sampleSelector is first."
	self assert: handler selectorEntries first selector equals: #sampleSelector.
	self assert: handler selectorEntries second selector equals: #rankedLaterSelector
	
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testRemoveAnExistingMethodDecrementsByOne [
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Class'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass:'Class'; yourself).
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass:'Class'; yourself ).
	
	self assert: handler selectorEntries size equals: 1.
	
	" Adding 10 items for example still makes the fooo selector the last one cause it is initialized to 0"
	
	1 to: 10 do: [ :each | (CooAddedMethodHistoryItem new selector: each asString; nameOfClass: 'Class'; yourself ) ].
	
	self assert: handler selectorEntries last contents equals: #foo
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testRemoveAnInexistingMethodDoesNotAffectClassEntries [
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'Class'; yourself ).
	self assert: handler classEntries size equals: 0
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testRemoveAnInexistingMethodDoesNotAffectSelectorEntries [
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'Class'; yourself ).
	self assert: handler selectorEntries size equals: 0
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testRemoveMethodDecrementsMethodFrequency [

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #m1; nameOfClass: 'Class'; yourself ).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #m2; nameOfClass: 'Class'; yourself ).
	
	"So far, we have m2 with the highest frequency equals 1, we will remove it and check if the frequency is decremented or not"
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #m2; nameOfClass: 'Class'; yourself ).
	
	self assert: handler selectorEntries second contents  equals: #m2
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testRemoveMethodFromInexistingClassDoesNotCrash [
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself ). 
	
	self assert: handler selectorEntries isEmpty.
	self assert: handler classEntries isEmpty.
	self assert: handler classToMethodsMap isEmpty.
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testRemovingMethodDoesNotRemoveItFromSelectorEntries [
	
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'Class'; yourself ).
	
	self assert: handler selectorEntries size equals: 1.

	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'Class'; yourself ).

	self assert: handler selectorEntries size equals: 1
]
