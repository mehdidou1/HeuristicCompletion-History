"
I count each time a method or a class is added, modified, removed for now. 

When a method is added or modified I increase its counter. 
When it is removed I remove its entry (because I do not want to see it again at all - because we could if everything is zero). 


"
Class {
	#name : 'CooFrequencyHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'classFrequencyDictionary',
		'selectorFrequenceDictionary',
		'classToMethodsMap'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooFrequencyHandler >> classEntries [

	^ (classFrequencyDictionary associations sort: [ :a1 :a2 | a1 value > a2 value ]) collect: [ :each |
			  (CoSessionGlobalEntry contents: each key node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Frequency' ]
]

{ #category : 'matching' }
CooFrequencyHandler >> classToMethodsMap [ 
	^ classToMethodsMap 
]

{ #category : 'matching' }
CooFrequencyHandler >> frequencyOfClass: aClass [
	^ classFrequencyDictionary at: aClass value
]

{ #category : 'matching' }
CooFrequencyHandler >> frequencyOfMethod: aSelector [
	^ selectorFrequenceDictionary at: aSelector value
]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewClassItem: anItem [

	| key classes|
	key := anItem nameOfClass.
	"to be changed"
	(#(#added #modified) includes: anItem event) 
		ifTrue: [ 
			classFrequencyDictionary 
				at: key
				ifPresent: [:v  | classFrequencyDictionary at: key put: v + 1 ]
				ifAbsentPut: [ 1 ] ].
			"We initialize the new correspending OrderedCollection if it is a new class"
			classToMethodsMap at: key 
			ifAbsentPut: OrderedCollection new.
	
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
CooFrequencyHandler >> handleNewMethodItem: anItem [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
	
	| key |
	key :=  anItem selector.
	"to be changed"
	(#(#added #modified) includes: anItem event) 
		ifTrue: [ 
			selectorFrequenceDictionary 
				at: key
				ifPresent: [:v  | selectorFrequenceDictionary at: key put: v + 1]
				ifAbsentPut: [ 1 ].
					"We made added or made changes to a method, we should increment the frequency of that class"
					classFrequencyDictionary at: anItem nameOfClass 
						ifPresent: [ :value | classFrequencyDictionary at: anItem nameOfClass put: value + 1 ]                       
						ifAbsent: [ classFrequencyDictionary at: anItem nameOfClass put: 1 ]. 
					(classToMethodsMap
    					at: anItem nameOfClass
    					ifAbsentPut: [ OrderedCollection new ])
        				add: key.
					].
	
 	(anItem event = #removed)
		ifTrue: [ 
			"We never remove methods from the dictionnary, we just decrement the frequency, so the problem with having methods with same name is resolved, in the oother hand, if the method's class does not exist in classEntries then we do nothing"
			selectorFrequenceDictionary at: key
    			ifPresent: [:value | selectorFrequenceDictionary at: key put: value - 1]. 
			"Decrease that class frequency"
			classFrequencyDictionary at: anItem nameOfClass 
				ifPresent: [ :value | classFrequencyDictionary at: anItem nameOfClass put: value -1 ].
			"Update the associations"
			(classToMethodsMap includesKey: anItem nameOfClass)
    ifTrue: [
        (classToMethodsMap at: anItem nameOfClass)
            remove: key ifAbsent: [ ].
    ].

		  ]
]

{ #category : 'matching' }
CooFrequencyHandler >> initialize [

	super initialize.
	classFrequencyDictionary := Dictionary new.
	selectorFrequenceDictionary := Dictionary new.
	classToMethodsMap := Dictionary new
	
]

{ #category : 'matching' }
CooFrequencyHandler >> selectorEntries [

	^ (selectorFrequenceDictionary associations sort: [ :a1 :a2 | a1 value > a2 value ]) collect: [ :each |
			  (CoSessionSelectorEntry contents: each key node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Frequency' ]
]

{ #category : 'matching' }
CooFrequencyHandler >> selectorFrequencies [ 
	^ selectorFrequenceDictionary values
]
