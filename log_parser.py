filename='log_spxc'
with open(filename) as f:
    lines=f.readlines() 

with open(filename+'.csv','w') as f:
    f.write('name,thash,impl,keygen,sign,verify,signature,pk,sk\n')
    for l in lines:
        tokens=l.split()
        if 'Benchmarking' in tokens:
            name=tokens[1]
            thash=tokens[2]
            impl=tokens[4]
        if 'Generating' in tokens:
            keygen=tokens[8].replace(',','')
        if 'Signing..' in tokens:
            sign=tokens[7].replace(',','')
        if 'Verifying..' in tokens:
            verify=tokens[7].replace(',','')
        if 'Signature' in tokens:
            signature=tokens[2].replace(',','')
        if 'Public' in tokens:
            pk=tokens[3].replace(',','')
        if 'Secret' in tokens:
            sk=tokens[3].replace(',','')
            f.write('{},{},{},{},{},{},{},{},{}\n'.format(name,thash,impl,keygen,sign,verify,signature,pk,sk))
