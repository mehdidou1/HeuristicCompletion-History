Class {
	#name : 'CooSessionTemporalTest',
	#superclass : 'CooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'running' }
CooSessionTemporalTest >> modifiedMethodAnnouncement [

	^ MethodModified
		  methodChangedFrom: self class >> #ourOriginalPrintString
		  to: self class >> #ourModifiedPrintString
		  oldProtocol: 'toto'
]

{ #category : 'tests - compute' }
CooSessionTemporalTest >> ourModifiedPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString.
	
	The following body is garbage"

	self testComputeMessages.
	^ self printStringLimitedTo: 50000
]

{ #category : 'tests - compute' }
CooSessionTemporalTest >> ourOriginalPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString.
	
	The following body is garbage it is just to compute the diff between two method versions."

	^ self printStringLimitedTo: 50000
]

{ #category : 'running' }
CooSessionTemporalTest >> removedMethodAnnouncement [

	^ MethodRemoved new
		  methodOrigin: CooSessionTemporalTest;
		  method: CooSessionTemporalTest >> #ourModifiedPrintString
]

{ #category : 'running' }
CooSessionTemporalTest >> setUp [

	super setUp.
	session := CooSession new programEntityHandler: CooTemporalHandler new
]

{ #category : 'tests - compute' }
CooSessionTemporalTest >> testAddClassAddsEntry [

	| announcement |
	announcement := ClassAdded new
		classAdded: Point;
		yourself.

	session addNewClassInVocabulary: announcement.

	self assert: session classEntries size equals: 1
]

{ #category : 'tests - announcements' }
CooSessionTemporalTest >> testAnnouncementAddModifiedMethodComputesMessageDiff [

	| announcement |
	announcement := self modifiedMethodAnnouncement.

	session addModifiedMethodInVocabulary: announcement.
	self 
		assert: session programEntityHandler methodDescriptions first deltaMessages asArray 
		equals: #( #testComputeMessages )
]

{ #category : 'tests - announcements' }
CooSessionTemporalTest >> testAnnouncementAddModifiedMethodRegistersEntry [

	| announcement |
	announcement := MethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.

	session addModifiedMethodInVocabulary: announcement.
	self 
		assert: session programEntityHandler selectorEntries size 
		equals: 1
]

{ #category : 'tests - announcements' }
CooSessionTemporalTest >> testAnnouncementAddNewMethodRegistersEntry [

	| announcement |
	announcement := MethodAdded new
		method: Point >> #degrees;
		yourself.

	session addNewMethodInVocabulary: announcement.
	self 
		assert: session programEntityHandler selectorEntries size 
		equals: 1
]

{ #category : 'tests - announcements' }
CooSessionTemporalTest >> testAnnouncementAddNewVariableAnnouncementRegistersEntry [

	| announcement entry |
	announcement := ClassAdded new
		classAdded: CooSessionTemporalTest;
		yourself.
	session addNewClassInVocabulary: announcement.

	entry := session programEntityHandler classDescriptions first.

	self 
		assert: session programEntityHandler classEntries size 
		equals: 1
]

{ #category : 'tests - announcements' }
CooSessionTemporalTest >> testAnnouncementAddedAndRemovedTheSameMethod [
	| announcement |
	announcement := self removedMethodAnnouncement.
	session removeMethodFromVocabulary: announcement.
	
	announcement := self modifiedMethodAnnouncement.
	session addModifiedMethodInVocabulary: announcement.
	
	
	self 
		assert: session programEntityHandler methodDescriptions first deltaMessages asArray
		equals: #( #testComputeMessages )
]

{ #category : 'tests - changing handler' }
CooSessionTemporalTest >> testChangeHandlerToTheSameDoesNotLoseData [
	
	| anns |
	anns := { 
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #debt;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself}.
	
	anns do: [ :each | 
		session addMethodItem: each ].
	
	self assert: session selectorEntries size equals: 4.
	self assert: session methodDescriptions size equals: 4.
	
	session shiftHandlerTo: CooTemporalHandler new. 
	
	self assert: session selectorEntries size equals: 4.
	self assert: session methodDescriptions size equals: 4.
	
	self 
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#degrees #degrees #degrees #debt) asOrderedCollection 

	


]

{ #category : 'tests - compute' }
CooSessionTemporalTest >> testComputeMessages [

	| announcement |
	announcement := MethodModified
		methodChangedFrom: self class >> #ourOriginalPrintString
		to: self class >> #ourModifiedPrintString
		oldProtocol: 'toto'.

	self 
		assert: (session computeDeltaMessageOf: announcement) asArray 
		equals: #( #testComputeMessages )
]

{ #category : 'tests - compute' }
CooSessionTemporalTest >> testComputeMessagesOfSimilarMethods [

	| announcement |
	announcement := MethodModified methodChangedFrom: self class >> #ourOriginalPrintString to: (self class >> #ourOriginalPrintString) oldProtocol: 'toto'.

	self assert: (session computeDeltaMessageOf: announcement) isEmpty
]

{ #category : 'tests - compute' }
CooSessionTemporalTest >> testHandlerChanges [

	| anns |
	anns := { 
		MethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.
		MethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.
		}.
	
	anns do: [ :each | 
		session addModifiedMethodInVocabulary: each ].
	
	self 
		assert: session programEntityHandler selectorEntries size 
		equals: 2.
	
]

{ #category : 'tests - changing handler' }
CooSessionTemporalTest >> testLowLevelHandlerPopulation [
	"This test just ask the session to add an item. It does not switch to a different handler."
	| anns |
	anns := { 
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #debt;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself}.
	
	anns do: [ :each | 
		session addMethodItem: each ].
	
	self assert: session selectorEntries size equals: 4.
	self 
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#debt #degrees #degrees #degrees) asOrderedCollection 

	


]

{ #category : 'tests - changing handler' }
CooSessionTemporalTest >> testLowLevelSessionPopulation [
	"This test just ask the session to add an item. It does not switch to a different handler."
	| anns |
	anns := { 
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself}.
	
	anns do: [ :each | 
		session addMethodItem: each ].
	
	self assert: session classDescriptions size equals: 0.
	self assert: session methodDescriptions size equals: 2.
	


]

{ #category : 'running' }
CooSessionTemporalTest >> testSessionNewCreatesAndEmptySession [


	self assert: session classDescriptions size equals: 0
]

{ #category : 'tests' }
CooSessionTemporalTest >> testShiftHandlerTo [

	| anns |
	anns := { 
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #debt;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself}.
	
	anns do: [ :each | 
		session addMethodItem: each ].
	
	self assert: session selectorEntries size equals: 4.
	session shiftHandlerTo: CooFrequencyHandler new. 
	
	self 
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#degrees #debt) asOrderedCollection
]
