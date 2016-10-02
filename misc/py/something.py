def get_unique(filename):
    handle = gdal.Open(filename)
    data = handle.ReadAsArray()
    values = pd.Series(data.reshape(data.shape[0] * data.shape[1]))
    unique_values = values.value_count().keys().tolist()
    return unique_values


for year in files.keys():
    for dt in files[year]:
        f = files[year][dt]
        if dt == 'lc' or dt == 'lcc' or dt == 'lcft':
            print year, dt
            print get_unique(f)
