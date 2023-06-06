
def vname_function(v):
    """
    Function to map internal name of variant to printed name of variant
    :param v: internal name for variant
    :return: printable name of variant
    """
    if v == 'WILDTYPE':
        vname = 'others'
    elif 'BA' in v:
        vname = v.replace('_',' ')
        vname = vname[0].upper() + vname[1:].lower()
        vname = vname.replace('ba','BA.')
        if 'BA.5' in vname:
            vname = vname.replace('BA.5', 'BA.4/5')
    elif v.startswith('VACC'):
        if int(v[-1])>1:
            vname = v[-1]+' doses'
        else:
            vname = v[-1] + ' dose'
    else:
        vname = v[0].upper() + v[1:].lower()
    return vname