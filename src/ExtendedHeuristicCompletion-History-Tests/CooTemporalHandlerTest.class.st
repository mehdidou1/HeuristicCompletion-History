Class {
	#name : 'CooTemporalHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooTemporalHandlerTest >> setUp [

	super setUp.
	handler := CooTemporalHandler new
]

{ #category : 'running' }
CooTemporalHandlerTest >> testHandleNewClassItemRemovalClearsMatchingEntries [

	| added newer removed |
	added := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	newer := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewClassItem: added.
	handler handleNewClassItem: newer.

	self assert: handler classEntries size equals: 2.

	removed := CooRemovedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewClassItem: removed.

	self assert: handler classEntries isEmpty
]

{ #category : 'running' }
CooTemporalHandlerTest >> testHandleNewClassItemRemovalKeepsOtherClasses [

	| classOne classTwo removed |
	classOne := CooAddedClassHistoryItem new
		nameOfClass: 'ClassOne';
		yourself.
	classTwo := CooAddedClassHistoryItem new
		nameOfClass: 'ClassTwo';
		yourself.

	handler handleNewClassItem: classOne.
	handler handleNewClassItem: classTwo.

	self assert: handler classEntries size equals: 2.

	removed := CooRemovedClassHistoryItem new
		nameOfClass: 'ClassOne';
		yourself.
	handler handleNewClassItem: removed.

	self assert: handler classEntries size equals: 1
]

{ #category : 'running' }
CooTemporalHandlerTest >> testHandleNewMethodItemRemovalClearsMatchingEntries [

	| added modified removed |
	added := CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	modified := CooModifiedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewMethodItem: added.
	handler handleNewMethodItem: modified.

	self assert: handler selectorEntries size equals: 2.

	removed := CooRemovedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewMethodItem: removed .

	self assert: handler selectorEntries isEmpty
]

{ #category : 'running' }
CooTemporalHandlerTest >> testRemovingAClassAlsoRemovesMethods [

	| items |
	
	items := 
	{ 
	CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself
	}.
	items do: [ :each |  
		handler handleNewMethodItem: each ].
	self assert: handler selectorEntries size equals: 1. 
	
	handler handleNewClassItem: (CooRemovedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself).
	
	self assert: handler classEntries isEmpty.
	self assert: handler selectorEntries isEmpty
]

{ #category : 'running' }
CooTemporalHandlerTest >> testRemovingAClassAlsoRemovesMethods2 [

	| items |
	
	items := 
	{ 
	CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
		
	CooAddedMethodHistoryItem new
		selector: #sampleSelector2;
		nameOfClass: 'TestClass';
		yourself
	}.
	items do: [ :each |  
		handler handleNewMethodItem: each ].
	
	self assert: handler selectorEntries size equals: 2. 
	
	handler handleNewClassItem: (CooRemovedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself).
	
	self assert: handler classEntries isEmpty.
	self assert: handler selectorEntries isEmpty
]

{ #category : 'running' }
CooTemporalHandlerTest >> testSelectorEntriesExcludeRemovedMethods [

	| added removed selectorEntries |
	added := CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewMethodItem: added.

	removed := CooRemovedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewMethodItem: removed.

	selectorEntries := handler selectorEntries.

	self assert: selectorEntries isEmpty
]
