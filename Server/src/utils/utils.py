""" General utils """

def castStrListToHex(list):
    return [int(val,16) for val in list]

def castNestedStrListToHex(list):
    return [[int(x,16) for x in lst] for lst in list]