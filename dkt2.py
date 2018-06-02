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

import csv
import numpy as np
from keras.models import Model
from keras.layers import Input, GRU
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

    inputs = np.zeros((n_params-1, n_students, n_items))
    target = np.zeros((n_students, n_items))

    for j in range(n_students):
        index = (n_params + 1)*j+row_skip
        num_items = int(rows[index][col_skip])
        for t in range(num_items):
            target[j][t] = int(rows[index + 1][t + col_skip])
        for i in range(n_params-1):
            for t in range(num_items):
                print("foo:" +rows[index + 2 + i][t + col_skip])
                inputs[i][j][t] = float(rows[index + 2 + i][t + col_skip])

    print("finished reading data")
    return inputs, target

def compose2(f, g):
    return lambda x: f(g(x))

def compose(*args):
    return reduce(compose2, args)

def make_model(input_shape):
    input_layer = Input(input_shape)
    return compose(    input_layer,
                       GRU(GRU_HIDDEN_UNITS),
                       lambda x: Model(inputs=input_layer, outputs=x) )

def main():
    inputs, targets = read_data_from_csv_file("data/tiny-test.csv")
    model = make_model((32, None))

if __name__ == "__main__":
    main()
