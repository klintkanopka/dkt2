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
