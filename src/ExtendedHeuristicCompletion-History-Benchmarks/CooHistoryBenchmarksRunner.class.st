"
```
CooHistoryBenchmarksRunner
  runWithSession: CooSession current
  scope: (Package named: 'Spec2').
```


```
CooHistoryBenchmarksRunner run.
```
"
Class {
	#name : 'CooHistoryBenchmarksRunner',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> newRunWithSession: aSession [ 
	"Run benchmarks with a specific session and scope.
	Example: CooHistoryBenchmarksRunner runWithSession: CooSession current scope: (RPackage named: 'Kernel')"

	"CooHistoryBenchmarksRunner 
		newRunWithSession: CooSession current )"

	| populator messageBenchmark variableBenchmark commits |
	"fill up the history"
	populator := HistoryCachePopulator repo: 'git@github.com:Ducasse/Comix2.git'.
	commits := populator commitsForHead: 10.

	messageBenchmark := CooStaticBenchmarksMessageHistory new
		                    session: aSession; yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		                     session: aSession; yourself.
	
	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit.
		messageBenchmark run.
		variableBenchmark run.
	].

	^ {
		  messageBenchmark.
		  variableBenchmark } inspect
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> newRunWithSession: aSession repositoryString: aString numberOfAnalyzedCommits: anInteger [

	| populator messageBenchmark variableBenchmark commits |
	"fill up the history"
	populator := HistoryCachePopulator repo: aString .
	commits := populator commitsForHead: anInteger.

	messageBenchmark := CooStaticBenchmarksMessageHistory new
		                    session: aSession; yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		                     session: aSession; yourself.
	
	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit.
		messageBenchmark run.
		variableBenchmark run.
	].

	^ {
		  messageBenchmark.
		  variableBenchmark } inspect
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> run [
	
	^ self newRunWithSession: CooSession current
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runComix [
	<script>
	
	[ CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	(self newRunWithSession: CooSession current repositoryString:  'git@github.com:Ducasse/Comix2.git' numberOfAnalyzedCommits: 10) inspect ] fork
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runRoassal [
	<script>
	
	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	Metacello new
    baseline: 'Roassal';
    repository: 'github://pharo-graphics/Roassal';
    load.
	(self newRunWithSession: CooSession current repositoryString:  'git@github.com:pharo-graphics/Roassal.git' numberOfAnalyzedCommits: 1) inspect
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runSpc [
	<script>
	
	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	
	(self newRunWithSession: CooSession current repositoryString:  'git@github.com:pharo-spec/spec.git' numberOfAnalyzedCommits: 10) inspect
]
