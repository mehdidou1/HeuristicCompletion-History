"
I am a superclass for classes that use frequency strategy.
"
Class {
	#name : 'CooFrequency',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'classFrequencyDictionary',
		'selectorFrequenceDictionary',
		'classToMethodsMap'
	],
	#category : 'ExtendedHeuristicCompletion-History',
	#package : 'ExtendedHeuristicCompletion-History'
}

{ #category : 'override' }
CooFrequency >> classEntries [

	^ (classFrequencyDictionary associations sort: [ :a1 :a2 | a1 value > a2 value ]) collect: [ :each |
			  (CoSessionGlobalEntry contents: each key node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Frequency' ]
]

{ #category : 'accessing' }
CooFrequency >> classToMethodsMap [ 
	^ classToMethodsMap 
]

{ #category : 'accessing' }
CooFrequency >> frequencyOfClass: aClass [
	^ classFrequencyDictionary at: aClass value
]

{ #category : 'accessing' }
CooFrequency >> frequencyOfMethod: aSelector [
	^ selectorFrequenceDictionary at: aSelector value
]

{ #category : 'matching' }
CooFrequency >> handleNewClassItem: anItem [

	| key classes|
	key := anItem nameOfClass.
	(#(#added #modified) includes: anItem event) 
		ifTrue: [ 
			classFrequencyDictionary 
				at: key
				ifPresent: [:v  | classFrequencyDictionary at: key put: v + 1 ]
				ifAbsentPut: [ 1 ] ].
			"We initialize the new correspending OrderedCollection if it is a new class"
			classToMethodsMap at: key 
			ifAbsentPut: Set new.
	
 	(anItem event = #removed)
		ifTrue: [ 
			classFrequencyDictionary removeKey: key ifAbsent: [  ].
			classFrequencyDictionary removeKey: (key, ' class') asSymbol ifAbsent: [  ].
			"extract the methods of the class in question, 
			for each method we decrement its frequency
			We don't need the correspendance item anymore, we should delete it 
			"
			classes := classToMethodsMap at:key value.
			classes do: [ :m | (selectorFrequenceDictionary includesKey: m) ifTrue: [ selectorFrequenceDictionary at: m put: (selectorFrequenceDictionary at: m) - 1 ] ].
			classToMethodsMap removeKey: key
			]
]

{ #category : 'matching' }
CooFrequency >> handleNewMethodItem: anItem [

	self subclassResponsibility
]

{ #category : 'initialization' }
CooFrequency >> initialize [ 
	
	super initialize .
	classFrequencyDictionary := Dictionary new.
	selectorFrequenceDictionary := Dictionary new.
	classToMethodsMap := Dictionary new.
	
	
]

{ #category : 'override' }
CooFrequency >> selectorEntries [

	^ (selectorFrequenceDictionary associations sort: [ :a1 :a2 | a1 value > a2 value ]) collect: [ :each |
			  (CoSessionSelectorEntry contents: each key node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Frequency' ]
]

{ #category : 'accessing' }
CooFrequency >> selectorFrequencies [ 
	^ selectorFrequenceDictionary values
]
