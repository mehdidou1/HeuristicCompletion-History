"
I count each time a method or a class is added, modified, removed. The key point is that I consider a class more important (frequent) when this class got more method added and modified. 

Here are in details my approach: 
- Creating a class or method initializes its frequency to 1.
- Updating a class or method increases its frequency by 1.
- Adding a method initializes its frequency and increases the frequency of its owning class.
- Updating a method increases both its frequency and the frequency of its owning class.
- Deleting a method decreases its frequency and removes its association with its class and increments the class' frequency.
- Deleting a class removes it and decreases the frequency of all its method selector by 1.

"
Class {
	#name : 'CooWeightedClassFrequencyHandler',
	#superclass : 'CooFrequencyHandler',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooWeightedClassFrequencyHandler >> handleNewMethodItem: anItem [
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
    					ifAbsentPut: [ Set new ])
        				add: key.
					].
	
 	(anItem event = #removed)
		ifTrue: [ 
			"We never remove methods from the dictionnary, we just decrement the frequency, so the problem with having methods with same name is resolved, in the oother hand, if the method's class does not exist in classEntries then we do nothing"
			selectorFrequenceDictionary at: key
    			ifPresent: [:value | selectorFrequenceDictionary at: key put: value - 1]. 
			"Increase that class frequency"
			classFrequencyDictionary at: anItem nameOfClass 
				ifPresent: [ :value | classFrequencyDictionary at: anItem nameOfClass put: value + 1 ].
			"Update the associations"
			(classToMethodsMap includesKey: anItem nameOfClass)
    ifTrue: [
        (classToMethodsMap at: anItem nameOfClass)
            remove: key ifAbsent: [ ].
    ].

		  ]
]
