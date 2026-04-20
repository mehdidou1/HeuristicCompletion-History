Class {
	#name : 'CooSessionHandlerSwitchingTest',
	#superclass : 'CooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooSessionHandlerSwitchingTest >> addMethodItems: aCollection [

	aCollection do: [ :each | session addMethodItem: each ]
]

{ #category : 'running' }
CooSessionHandlerSwitchingTest >> makeMethodItem: aSelector className: aClassName [

	^ CooModifiedMethodHistoryItem new
		  selector: aSelector;
		  live: true;
		  timestamp: DateAndTime now;
		  nameOfClass: aClassName;
		  yourself
]

{ #category : 'running' }
CooSessionHandlerSwitchingTest >> setUp [

	super setUp.
	session := CooSession new programEntityHandler: CooTemporalHandler new
]

{ #category : 'tests' }
CooSessionHandlerSwitchingTest >> testDoubleShiftRoundTripsCorrectly [
	"Temporal -> Frequency -> Temporal should restore all items"

	self addMethodItems: {
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #debt className: 'Point'
	}.

	session shiftHandlerTo: CooWeightedClassFrequencyHandler new.
	self assert: session selectorEntries size equals: 2.

	session shiftHandlerTo: CooTemporalHandler new.
	self assert: session selectorEntries size equals: 3
]

{ #category : 'tests' }
CooSessionHandlerSwitchingTest >> testFrequencyToTemporalExpandsBack [
	"Start with Frequency (deduplicates), then switch to Temporal (keeps all).
	 Since shiftHandlerTo re-feeds all methodDescriptions, Temporal should show all items."

	session programEntityHandler: CooWeightedClassFrequencyHandler new.

	self addMethodItems: {
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #debt className: 'Point'
	}.

	"Frequency shows 2 unique selectors"
	self assert: session selectorEntries size equals: 2.

	session shiftHandlerTo: CooTemporalHandler new.

	"Temporal re-ingests all 3 raw items from methodDescriptions"
	self assert: session selectorEntries size equals: 3
]

{ #category : 'tests' }
CooSessionHandlerSwitchingTest >> testShiftAlsoRePopulatesClassItems [

	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Point'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Rectangle'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Point'; yourself).

	session shiftHandlerTo: CooWeightedClassFrequencyHandler new.

	"Frequency should deduplicate classes: Point(2) > Rectangle(1)"
	self assert: session programEntityHandler classEntries size equals: 2.
	self assert: session programEntityHandler classEntries first contents equals: 'Point'
]

{ #category : 'tests' }
CooSessionHandlerSwitchingTest >> testShiftPreservesMethodDescriptions [
	"The raw methodDescriptions should be untouched regardless of handler switches."

	self addMethodItems: {
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #debt className: 'Point'
	}.

	self assert: session methodDescriptions size equals: 3.

	session shiftHandlerTo: CooWeightedClassFrequencyHandler new.
	self assert: session methodDescriptions size equals: 3.

]

{ #category : 'tests' }
CooSessionHandlerSwitchingTest >> testShiftWithEmptySessionDoesNotBreak [

	session shiftHandlerTo: CooWeightedClassFrequencyHandler new.
	self assert: session selectorEntries size equals: 0.
	self assert: session programEntityHandler classEntries size equals: 0
]

{ #category : 'tests' }
CooSessionHandlerSwitchingTest >> testTemporalToFrequencyDeduplicates [
	"Temporal keeps all 4 items. Frequency should collapse to 2 unique selectors,
	 ranked by frequency: degrees(3) > debt(1)."

	self addMethodItems: {
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #degrees className: 'Point'.
		self makeMethodItem: #debt className: 'Point'
	}.

	self assert: session selectorEntries size equals: 4.

	session shiftHandlerTo: CooWeightedClassFrequencyHandler new.

	self assert: session selectorEntries size equals: 2.
	self
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#degrees #debt) asOrderedCollection
]
