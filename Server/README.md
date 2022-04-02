# Server side

Smart contract architexture:
1) `submitBatches(batches)`
2) `for proof, input in batches verifyBatch(proof, input)`

    `batch = batches.sum()`
    
3) `findFork(prevHash, height)`:

    - `if(fork == mainFork && fork.forkHeight == batch.height):`

          batch.cumDiff = mainFork.batches[forkHeight] + batch.cumDiff`
          mainFork.append(batch);`
          mainFork.forkHeight = batch.height

    - `if(fork != mainFork && fork.forkHeight == batch.height):`

          batch.cumDiff = mainFork.batches[forkHeight] + batch.cumDiff
          fork.append(batch);
          fork.updateDiffHeight(batch);
          chainUpdateMain(fork)

    - `if(fork.forkHeight != batch.height):`

          batch.cumDiff = batch.cumDiff + fork.batches[batch.height - 1]
          newFork = Fork( prevFork: fork, preHeight: batch.height - 1, batches: [batch], forkHeight: batch.height)
          chain.forks.append(newFork)
