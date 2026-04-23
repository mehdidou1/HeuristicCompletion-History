"
I count each time a class or a method is created, modified or removed.
Contrary to my sibling class WeightedClassFrequencyHandler when a method is added or modified I do not count such event as an activity of the class. Method and class events do not impact each others. 
"
Class {
	#name : 'CooSingleFrequencyHandler',
	#superclass : 'CooFrequencyHandler',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooSingleFrequencyHandler >> handleNewMethodItem: anItem [
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
			"Adding a method to a class should not affect its frequency"
			classFrequencyDictionary at: anItem nameOfClass                     
						ifAbsent: [ classFrequencyDictionary at: anItem nameOfClass put: 0 ]. 
			(classToMethodsMap
    					at: anItem nameOfClass
    					ifAbsentPut: [ Set new ])
        				add: key.
					].
	
 	(anItem event = #removed)
		ifTrue: [ 
			"We never remove methods from the dictionnary, we just decrement the frequency, so the problem with having methods with same name is resolved, in the oother hand, if the method's class does not exist in classEntries then we do nothing"
			selectorFrequenceDictionary at: key
    			ifPresent: [:value | selectorFrequenceDictionary at: key put: value - 1]. 
			"Update the associations"
			(classToMethodsMap includesKey: anItem nameOfClass)
    ifTrue: [
        (classToMethodsMap at: anItem nameOfClass)
            remove: key ifAbsent: [ ].
    ].

		  ]
]
