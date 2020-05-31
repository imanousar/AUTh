import pandas as pd
import numpy as np
import random
import matplotlib 
#reading data from the file 
data = pd.read_csv('parkinsons.data')

#First lets swap the label so that its in the last column, as this is normal in ML

# Lets also change the label to be the last column, as this is normal is ML
# get a list of the columns
col_list = list(data)
# use this handy way to swap the elements
data['PPE'], data['status'] = data['status'], data['PPE']
PPE_index,status_index= col_list.index('PPE'),col_list.index('status') 

col_list[PPE_index],col_list[status_index]=col_list[status_index],col_list[PPE_index]

data.columns=col_list

col_list.remove('name')
col_list.remove('status')
cols_to_norm = col_list 

data[cols_to_norm] = data[cols_to_norm].apply(lambda x: (x - x.min()) / (x.max() - x.min()))



X = data.iloc[:, 1:-1].values
y = data.iloc[:, len(list(data)) - 1].values

from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20)

from sklearn.neighbors import KNeighborsClassifier

classifier = KNeighborsClassifier(n_neighbors=5)
classifier.fit(X_train, y_train)

print(classifier.score(X_test, y_test))



data_to_aug = data.sample(round(len(data)/10))



def FDAA(data_to_aug,scale,aug_ratio):
    column_count=data_to_aug.shape[1]
    for i in range(scale):
        row_count=data_to_aug.shape[0]
        data_to_aug_merge = data_to_aug.copy()
        for j in range(row_count):
            for k in range(1,column_count-1):
                tempRandom=random.uniform(-aug_ratio,aug_ratio)
                temp = (data_to_aug.iloc[j:j+1,k:k+1]*(tempRandom)+data_to_aug.iloc[j:j+1,k:k+1])
                temp = temp.to_numpy()
                if 0 < temp < 1 :
                    data_to_aug_merge.iloc[j:j+1,k:k+1]=data_to_aug.iloc[j:j+1,k:k+1]*(tempRandom)+data_to_aug.iloc[j:j+1,k:k+1]
    
        data_to_aug_merge['name']='FDAA'
        data_to_aug = pd.concat([data_to_aug, data_to_aug_merge],ignore_index=True)
    return data_to_aug

data_to_aug2=FDAA(data_to_aug,3,0.01)


aX = data_to_aug2.iloc[:, 1:-1].values
ay = data_to_aug2.iloc[:, len(list(data)) - 1].values

aX_train, aX_test, ay_train, ay_test = train_test_split(aX, ay, test_size=0.20)

from sklearn.neighbors import KNeighborsClassifier

classifier = KNeighborsClassifier(n_neighbors=5)
classifier.fit(aX_train, ay_train)
print('aug data result  ')
print(data_to_aug2.shape)
print(classifier.score(aX_test, ay_test))
