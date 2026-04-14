Class {
	#name : 'CooFrequencyRankingStabilityTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooFrequencyRankingStabilityTest >> setUp [ 

	super setUp.
	handler := CooFrequencyHandler new
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testClassRankingReflectsFrequency [

	4 timesRepeat: [
		handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself) ].
	2 timesRepeat: [
		handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Button'; yourself) ].
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Panel'; yourself).

	self assert: handler classEntries first contents equals: 'Widget'.
	self assert: handler classEntries second contents equals: 'Button'.
	self assert: handler classEntries third contents equals: 'Panel'
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testInterleaveAddRemoveAddForMultipleSelectors [
	"Interleaving add/remove/add across multiple selectors should leave a consistent state."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #baz; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #bar; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).

	"foo(1), baz(1) should remain; bar was removed"
	self assert: handler selectorEntries size equals: 2.
	self assert: ((handler selectorEntries collect: [ :e | e selector ]) includesAll: { #foo . #baz }).
	self deny: ((handler selectorEntries collect: [ :e | e selector ]) includes: #bar)
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testManySelectorsStaySorted [
	"Add 20 selectors with different frequencies and verify sorting."

	1 to: 20 do: [ :i |
		i timesRepeat: [
			handler handleNewMethodItem: (CooAddedMethodHistoryItem new
				selector: ('method', i asString) asSymbol;
				nameOfClass: 'A';
				yourself)] ].

	"method20 should be first (highest frequency), method1 last"
	self assert: handler selectorEntries first selector equals: #method20.
	self assert: handler selectorEntries last selector equals: #method1
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testModificationCountsAsFrequencyBump [
	"A method added once then modified 4 times should have freq 5."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #evolving; nameOfClass: 'A'; yourself).
	4 timesRepeat: [
		handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #evolving; nameOfClass: 'A'; yourself) ].

	"Add a competitor with 3 occurrences"
	3 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #stable; nameOfClass: 'A'; yourself) ].

	"evolving(5) > stable(3)"
	self assert: handler selectorEntries first selector equals: #evolving
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testRankingIsDeterministic [
	"Adding the same items in the same order should always produce the same ranking."

	| handler2 |
	handler2 := CooFrequencyHandler new.

	#(#alpha #beta #gamma #alpha #alpha #beta) do: [ :sel |
		| item |
		item := CooAddedMethodHistoryItem new selector: sel; nameOfClass: 'A'; yourself.
		handler handleNewMethodItem: item.
		handler2 handleNewMethodItem: item ].

	self
		assert: (handler selectorEntries collect: [ :e | e selector ])
		equals: (handler2 selectorEntries collect: [ :e | e selector ])
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testRankingReflectsFrequencyOrder [
	"alpha: 3 times, beta: 2, gamma: 1 -> alpha > beta > gamma"

	3 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #alpha; nameOfClass: 'A'; yourself) ].
	2 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #beta; nameOfClass: 'A'; yourself)].
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #gamma; nameOfClass: 'A'; yourself).

	self assert: handler selectorEntries first selector equals: #alpha.
	self assert: handler selectorEntries second selector equals: #beta.
	self assert: handler selectorEntries third selector equals: #gamma
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testRemoveAndReAddResetsFrequency [
	"After removal, re-adding starts the count fresh at 1."

	5 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself)].
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).

	"Also add bar with 2 occurrences"
	2 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'A'; yourself)].

	"bar(2) > foo(1)"
	self assert: handler selectorEntries first selector equals: #bar.
	self assert: handler selectorEntries second selector equals: #foo
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testRemovingNonExistentDoesNotAffectExisting [
	"Removing a method that was never added should leave existing entries intact."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #existing; nameOfClass: 'A'; yourself).
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #phantom; nameOfClass: 'A'; yourself).

	self assert: handler selectorEntries size equals: 1.
	self assert: handler selectorEntries first selector equals: #existing
]

{ #category : 'tests' }
CooFrequencyRankingStabilityTest >> testTiedFrequenciesDoNotCrash [
	"Multiple selectors with the same frequency should not cause errors."

	#(#a #b #c #d #e) do: [ :sel |
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: sel; nameOfClass: 'A'; yourself) ].

	"All have frequency 1, sorting should work without error"
	self assert: handler selectorEntries size equals: 5
]
