"
I extract navigation history from open Calypso browsers and turn it into `CooNavigationHistoryItem` observations that the completion engine can consume.

I mirror the live snippet:

```smalltalk
browsers := ClyBrowserMorph withAllSubclasses
	flatCollect: [ :eachClass | eachClass allInstances ].
```

then for each browser I read its current selections and walk through `browser navigationHistory undoList` and `redoList` to recover every state the developer has visited and add a `CooNavigationHistoryItem` for each selected name.

Two-way usage:

- `self snapshotItems` gives a one-shot collection of items extracted from every open browser.
- `self feedSession: aCooSession` registers each observation in the given session through `addNavigationItem:`.

Because the Calypso classes are not always loaded (or available in tests), I look them up dynamically through `Smalltalk globals at: #ClyBrowserMorph ifAbsent: [ nil ]`. When they are absent I simply return an empty collection.
"
Class {
	#name : 'CooNavigationScrapper',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Navigation',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Navigation'
}

{ #category : 'examples' }
CooNavigationScrapper class >> feedCurrentSession [
	"Convenience: scrape the open browsers and feed the singleton session."

	<script>
	^ self new feedSession: CooSession current
]

{ #category : 'examples' }
CooNavigationScrapper class >> snapshotItems [

	^ self new snapshotItems
]

{ #category : 'navigation' }
CooNavigationScrapper >> browserStateOf: aHistoryEntry [

	(aHistoryEntry respondsTo: #viewStates) ifTrue: [ ^ aHistoryEntry ].
	(aHistoryEntry respondsTo: #browserState) ifTrue: [ ^ aHistoryEntry browserState ].
	^ nil
]

{ #category : 'navigation' }
CooNavigationScrapper >> calypsoBrowserClass [

	^ Smalltalk globals at: #ClyBrowserMorph ifAbsent: [ nil ]
]

{ #category : 'actions' }
CooNavigationScrapper >> feedSession: aCooSession [

	| items |
	items := self snapshotItems.
	items do: [ :each | aCooSession addNavigationItem: each ].
	^ items
]

{ #category : 'private' }
CooNavigationScrapper >> itemsFromBrowser: aBrowser [

	| browserTitle history items entries |
	items := OrderedCollection new.
	browserTitle := [ aBrowser window labelString ]
		                on: Error
		                do: [ :ex | aBrowser printString ].

	"Current selections on the live browser."
	(self readSelectionsOf: aBrowser) do: [ :pane |
		items addAll: (self
			itemsFromPane: pane
			browserTitle: browserTitle
			timestamp: DateAndTime now) ].

	(aBrowser respondsTo: #navigationHistory) ifFalse: [ ^ items ].
	history := aBrowser navigationHistory.
	history ifNil: [ ^ items ].

	entries := OrderedCollection new.
	(history respondsTo: #undoList) ifTrue: [ entries addAll: history undoList ].
	(history respondsTo: #redoList) ifTrue: [ entries addAll: history redoList ].

	entries do: [ :entry |
		| state |
		state := self browserStateOf: entry.
		state ifNotNil: [
			(self readViewStatesOf: state) do: [ :pane |
				items addAll: (self
					itemsFromPane: pane
					browserTitle: browserTitle
					timestamp: DateAndTime now) ] ] ].

	^ items
]

{ #category : 'private' }
CooNavigationScrapper >> itemsFromPane: aPane browserTitle: aTitle timestamp: aTimestamp [

	| names kind paneIndex |
	names := aPane at: #selectedNames ifAbsent: [ #() ].
	kind := aPane at: #kind ifAbsent: [ #selector ].
	paneIndex := aPane at: #paneIndex ifAbsent: [ nil ].

	^ names collect: [ :each |
		  CooNavigationHistoryItem new
			  kind: kind;
			  name: each asString;
			  browserTitle: aTitle;
			  paneIndex: paneIndex;
			  timestamp: aTimestamp;
			  yourself ]
]

{ #category : 'private' }
CooNavigationScrapper >> kindOfSelection: aSelection [

	| items |
	items := (aSelection respondsTo: #items)
		         ifTrue: [ aSelection items ]
		         ifFalse: [ #() ].
	items isEmpty ifTrue: [ ^ #selector ].
	(items anySatisfy: [ :item |
		 (item class name asString includesSubstring: 'Class') or: [
			 item class name asString includesSubstring: 'Package' ] ])
		ifTrue: [ ^ #class ].
	^ #selector
]

{ #category : 'private' }
CooNavigationScrapper >> openBrowsers [

	| browserClass browsers |
	browserClass := self calypsoBrowserClass.
	browserClass ifNil: [ ^ #() ].

	browsers := browserClass withAllSubclasses flatCollect: [ :each | each allInstances ].
	^ browsers select: [ :each |
		  each window notNil and: [ each window isInWorld ] ]
]

{ #category : 'private' }
CooNavigationScrapper >> readSelectionsOf: aBrowser [

	| panes |
	panes := OrderedCollection new.
	(aBrowser respondsTo: #navigationViews) ifFalse: [ ^ panes ].

	aBrowser navigationViews withIndexDo: [ :view :paneIndex |
		| selection items names |
		selection := view selection.
		items := (selection respondsTo: #items)
			         ifTrue: [ selection items ]
			         ifFalse: [ #() ].
		names := items collect: [ :item |
			         [ item name ]
				         on: Error
				         do: [ :ex | item printString ] ].
		panes add: ({
			#paneIndex -> paneIndex.
			#selectedNames -> names asArray.
			#kind -> (self kindOfSelection: selection)
		} asDictionary) ].
	^ panes
]

{ #category : 'private' }
CooNavigationScrapper >> readViewStatesOf: aBrowserState [

	| panes |
	panes := OrderedCollection new.
	(aBrowserState respondsTo: #viewStates) ifFalse: [ ^ panes ].

	aBrowserState viewStates withIndexDo: [ :viewState :paneIndex |
		| selection items names |
		selection := viewState selection.
		items := (selection respondsTo: #items)
			         ifTrue: [ selection items ]
			         ifFalse: [ #() ].
		names := items collect: [ :item |
			         [ item name ]
				         on: Error
				         do: [ :ex | item printString ] ].
		panes add: ({
			#paneIndex -> paneIndex.
			#selectedNames -> names asArray.
			#kind -> (self kindOfSelection: selection)
		} asDictionary) ].
	^ panes
]

{ #category : 'private' }
CooNavigationScrapper >> snapshotItems [

	| items |
	items := OrderedCollection new.
	self openBrowsers do: [ :browser |
		items addAll: (self itemsFromBrowser: browser) ].
	^ items
]
