"
I'm a subclass of Selector because I need to pass extra information. 
In the future `CoEntry` should be more extensible.
"
Class {
	#name : 'CoSessionSelectorEntry',
	#superclass : 'NECSelectorEntry',
	#instVars : [
		'sessionItem'
	],
	#category : 'ExtendedHeuristicCompletion-History-Completion-Entries',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Completion-Entries'
}

{ #category : 'accessing' }
CoSessionSelectorEntry >> deltaMessages [ 
	
	^ sessionItem deltaMessages 
]

{ #category : 'accessing' }
CoSessionSelectorEntry >> sessionItem [

	^ sessionItem 
]

{ #category : 'accessing' }
CoSessionSelectorEntry >> sessionItem: aSessionItem [

	sessionItem := aSessionItem
]
