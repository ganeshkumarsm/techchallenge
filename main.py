# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    from munch import DefaultMunch
# DefaultMunch is used for recursive lookup.

    my_object = {'a': {'b': {'c': 'd'}}}
    obj = DefaultMunch.fromDict(my_object)
    print(obj.a.b.c)

