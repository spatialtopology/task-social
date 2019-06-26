import random
import pandas as pd
import numpy as np
from itertools import groupby
from sklearn.utils import shuffle

#########
# TODO 0627
# 1) based on df columns/values, generate rotation image name and keep in df.
# 2) Do we also want to shuffle same different stimuli?
# 3) create 6 different versions of mental rotation random list




# randomly select 14 numbers out of 48
numSelect = []
numSelect = random.sample(range(1,49),  14)
numSort = sorted(numSelect)

# create pandas ________________________________________________________________
# create stimuli number column
df = pd.DataFrame(numSort)
df.columns = ['StimuliNo']
df = pd.concat([df]*4)

# add column 50/100
df['degree'] = np.repeat([50, 100],28)
# add column same/different
df['match'] = np.repeat(['same', 'different', 'same', 'different'], 14)
df['matchNo'] = np.repeat([1, 2, 1, 2], 14)
df['order'] = range(len(df))
df = df.reset_index()

# shuffle same different with __________________________________________________

wordList1 = range(1,15) + range(29,43)
wordList2 = range(15,29) + range(43,57)

dictLists = {'same':wordList1, 'diff':wordList2}
# keyList = list(['l1','l2']*len(wordList1))

random.shuffle(wordList1)
random.shuffle(wordList2)
x= ['same','diff', 'same', 'diff']
n = 14
keyList  = [item for item in x for i in range(n)]
# keyList = list(['same','diff', 'same', 'diff']*14)
random.shuffle(keyList)
orderTest=False

while orderTest == False:
    for i in range(len(keyList)):
        if ''.join(keyList).count('same'*3) > 0 or ''.join(keyList).count('diff'*3) >0:
            random.shuffle(keyList)
            break
        else:
            orderTest = True

trialList=[]

for thisKey in keyList:
    trialList.append(dictLists[thisKey].pop())

print trialList #this can be deleted, just for debugging purposes
#  Use trial index to shuffle dataframe________________________________________________________________
trialList[:] =  [x - 1 for x in trialList]
df1 = df.reindex(trialList)

# https://stackoverflow.com/questions/30009948/how-to-reorder-indexed-rows-based-on-a-list-in-pandas-data-frame/30010004
