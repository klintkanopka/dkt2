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

    print "the number of rows is " + str(len(rows))
    n_students = len(rows-rowskip)/(n_params+1)
    print "the number of students is " + str(n_students)
    n_items = rows[0][col_skip]
    print "the number of items is " + str(n_items)

    input = np.zeros((n_params, n_students, n_items))
    target = np.zeros((n_students, n_items))

    for j in range(n_students):
        index = (n_params + 1)*j
        num_items = rows[index][col_skip]
        for t in range(num_items):
            target[j][t] = rows[index + 1][t + col_skip]
        for i in range(n_cov):
            for t in range(num_items):
                input[i][j][t] = rows[index + 2 + i][t + col_skip]

    print "finished reading data"
    print input
    print target
    return input, target

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
    model = make_model((32, None))

if __name__ == "__main__":
    main()
