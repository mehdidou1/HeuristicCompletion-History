"
I keep the information in Least Recent Usage cache. It means that when my caches saturates I removed the least used information. 
I have a separated cache for methods and classes.


"
Class {
	#name : 'CooLRUHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'selectorLRU',
		'classLRU'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooLRUHandler >> classEntries [
	"Clearly we should manage what happen when we remove a class"

	| col |
	col := OrderedCollection new.
	classLRU keysAndValuesDo: [ :k :v |
			col add: ((CoSessionGlobalEntry contents: v nameOfClass node: nil)
					 sessionItem: v;
					 fetcherName: 'Session LRU';
					 yourself) ].
	^ col
]

{ #category : 'matching' }
CooLRUHandler >> handleNewClassItem: anItem [

	classLRU at: anItem nameOfClass put: anItem
]

{ #category : 'matching' }
CooLRUHandler >> handleNewClassItem: anItem addedTo: aCollection [

	classLRU at: anItem nameOfClass put: anItem
]

{ #category : 'matching' }
CooLRUHandler >> handleNewMethodItem: anItem [

	selectorLRU at: anItem selector put: anItem
]

{ #category : 'matching' }
CooLRUHandler >> handleNewMethodItem: anItem addedTo: aCollection [

	selectorLRU at: anItem selector put: anItem
]

{ #category : 'initialization' }
CooLRUHandler >> initialize [ 

	super initialize.
	selectorLRU := LRUCache new maximumWeight: 1000.
	classLRU := LRUCache new maximumWeight: 1000
]

{ #category : 'matching' }
CooLRUHandler >> selectorEntries [
	"Clearly we should manage what happen when we remove a class"

	| col |
	col := OrderedCollection new.
	selectorLRU keysAndValuesDo: [ :k :v |
			col add: ((CoSessionSelectorEntry contents: v selector node: nil)
					 sessionItem: v;
					 fetcherName: 'Session LRU';
					 yourself) ].
	^ col
]
