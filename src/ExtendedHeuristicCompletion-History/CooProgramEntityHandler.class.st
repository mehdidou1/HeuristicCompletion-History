"
I'm the root of the program entity handlers: a handler is basically a strategy that treat specifically elements (added/removed/modified methods or classes).
"
Class {
	#name : 'CooProgramEntityHandler',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooProgramEntityHandler >> classEntries [

	self subclassResponsibility
]

{ #category : 'matching' }
CooProgramEntityHandler >> handleNewClassItem: anItem [

	self subclassResponsibility
]

{ #category : 'matching' }
CooProgramEntityHandler >> handleNewClassItem: anItem addedTo: aCollection [

	self subclassResponsibility
]

{ #category : 'matching' }
CooProgramEntityHandler >> handleNewMethodItem: anItem [

	self subclassResponsibility
]

{ #category : 'matching' }
CooProgramEntityHandler >> handleNewMethodItem: anItem addedTo: aCollection [

	self subclassResponsibility
]

{ #category : 'matching' }
CooProgramEntityHandler >> selectorEntries [

	self subclassResponsibility
]

{ #category : 'accessing' }
CooProgramEntityHandler >> size [ 

	^ 0
]
