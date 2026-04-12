"
I'm a subclass of Selector because I need to pass extra information. 
In the future CoEntry should be more extensible.
"
Class {
	#name : 'CoSessionGlobalEntry',
	#superclass : 'CoGlobalEntry',
	#instVars : [
		'sessionItem'
	],
	#category : 'ExtendedHeuristicCompletion-History-Completion-Entries',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Completion-Entries'
}

{ #category : 'accessing' }
CoSessionGlobalEntry >> sessionItem [

	^ sessionItem
]

{ #category : 'accessing' }
CoSessionGlobalEntry >> sessionItem: anObject [

	sessionItem := anObject
]
