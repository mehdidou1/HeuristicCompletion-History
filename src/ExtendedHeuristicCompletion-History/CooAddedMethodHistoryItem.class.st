Class {
	#name : 'CooAddedMethodHistoryItem',
	#superclass : 'CooMethodHistoryItem',
	#category : 'ExtendedHeuristicCompletion-History-StructuralModel',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'StructuralModel'
}

{ #category : 'accessing' }
CooAddedMethodHistoryItem >> event [

	^ #added
]

{ #category : 'accessing' }
CooAddedMethodHistoryItem >> fullName [
	
	^ self nameOfClass, '>>#', self selector 
]
