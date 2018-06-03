# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import argparse
import csv
import numpy as np
from keras.models import Model
from keras.layers import Input, GRU, Dense
from functools import reduce

GRU_HIDDEN_UNITS = 64

def read_data_from_csv_file(fileName, n_params=8):

    rows = []

    with open(fileName, "r") as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            rows.append(row)

    row_skip = 1
    col_skip = 2
    index = row_skip

    print("the number of rows is " + str(len(rows)))
    n_students = int((len(rows)-row_skip)/(n_params+1))
    print("the number of students is " + str(n_students))
    n_items = int(rows[row_skip][col_skip])
    print("the number of items is " + str(n_items))

    inputs = np.zeros((n_students, n_items, n_params - 1))
    target = np.zeros((n_students, n_items, 1))

    for i in range(n_students):
        index = (n_params + 1)*i + row_skip
        num_items = int(rows[index][col_skip])
        for j in range(num_items):
            target[i][j][0] = int(rows[index + 1][j + col_skip])
        for k in range(n_params-1):
            for j in range(num_items):
                inputs[i][j][k] = float(rows[index + 2 + k][j + col_skip])

    print("finished reading data")
    return inputs, target

def compose2(f, g):
    return lambda x: f(g(x))

def compose(*args):
    return reduce(compose2, args)

def make_model(input_shape):
    inputs = Input(input_shape)
    x = GRU(GRU_HIDDEN_UNITS, return_sequences=True)(inputs)
    x = Dense(1)(x)
    return Model(inputs=inputs, outputs=x)

def shuffle_and_split(data, ratio):
    np.random.shuffle(data)
    return np.split(data, [int(ratio*len(data))])

def train(model, filename, epochs=150, train_ratio=0.8, test_interval=10):
    x, y = read_data_from_csv_file(filename)
    train_x, test_x = shuffle_and_split(x)
    train_y, test_y = shuffle_and_split(y)
    for i in range(epochs//test_interval):
        model.fit(x=train_x, y=train_y, epochs=test_interval)
        print("test loss: ", model.evaluate(x=test_x, y=test_y))

def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument("data")
    args = argparser.parse_args()

    model = make_model((103, 7))
    model.summary()
    model.compile("Adam", "binary_crossentropy");
    train(model, args.data)

if __name__ == "__main__":
    main()
