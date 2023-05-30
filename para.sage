maxsigs=2**64
F = RealField(256+100)

def pow(p,e):
    return F(p)**e
def qhitprob(qs,r):
    p = F(1/leaves)
    return binomial(qs,r)*(pow(p,r))*(pow(1-p,qs-r))

def run(l,w):
    s=l*(w-1)//2
    dp=[]
    for i in range(0,l+1):
        dp.append([])
        for j in range(0,s+1):
            dp[i].append(0)

    dp[0][0]=1
    for i in range(1,l+1):
        for j in range(0,s+1):
            for k in range(0,w):
                if k>j:
                    continue
                dp[i][j]+=dp[i-1][j-k] 
    return dp[l][s]

lenmap={}

for osec in [128,192,256]:
    lenmap[osec]={}
    lastl=100
    for w in range(8,129):
        lenmap[osec][w]=99999 
        ans = lastl
        for l in range(lastl-1,1,-1):
            if F(log(F(run(l,w)))/log2)>osec:
                ans=l
            else:
                break
        lenmap[osec][w]=ans
        lastl=ans
        print(osec,w,ans,w*ans/2.0)
print('preprocess end')


def size(sec,h,d,b,k,w1,hashbytes):
    l=lenmap[sec][w1]
    return ((b+1)*k+h+l*d+1)*hashbytes


def split(h,d):
    ans=[0 for i in range(d)]
    for i in range(h):
        ans[i%d]+=1
    return ans

def speed(sec,h,d,b,k,w1):
    l=lenmap[sec][w1]
    ans=k*(2**b)*(2)
    ans+=d*(2**(h/d)*(l*w1+1))
    return ans


def sec(h,d,b,k,w1):
    s=F(0)
    for r in range(100): # in fact, qhitprob(maxsigs,r)<2^{-256}*2^{-64} when r>100. Thus we can omit all r>100
        p=F(1-(1-1/F(2**b))^r)**k
        s+=qhitprob(maxsigs,r)*p
    return -F(log(F(s))/log2)

def factor(h):
    ans=[]
    for d in range(6,h):
        if h%d==0:
            ans.append(d)
    return ans


paras={}
paras[128]={}
paras[192]={}
paras[256]={}

paras[128]['small']=(63,7,12,14,16)
paras[128]['fast']=(66,22,6,33,16)

paras[192]['small']=(63,7,14,17,16)
paras[192]['fast']=(66,22,8,33,16)

paras[256]['small']=(64,8,14,22,16)
paras[256]['fast']=(68,17,9,35,16)


for osec in [128,192,256]:
    D={}
    for w in range(8,129):
        l=lenmap[osec][w]
        if not l in D:
            D[l]=w
    good_w=list(D.values())
    print(good_w)
    for ty in ['small','fast']:
        h,d,b,k,w1=paras[osec][ty]
        max_size=size(osec,h,d,b,k,w1,osec//8)
        max_hashcalls=speed(osec,h,d,b,k,w1)
        print(osec,ty,max_size,max_hashcalls)
        best_szsp=(max_size,max_hashcalls)
        best_spsz=(max_hashcalls,max_size)
        para_szsp=(h,d,b,k,w1)
        para_spsz=(h,d,b,k,w1)
        for h in [63,64,65,66,68]:
            leaves=2**h
            for b in range(3,15):
                for k in range(6,40):
                    if sec(h,0,b,k,0)>=osec-1:
                        for d in factor(h):
                            for w1 in good_w: 
                                sz=size(osec,h,d,b,k,w1,osec//8)
                                sp=speed(osec,h,d,b,k,w1)
                                if sec(h,d,b,k,w1)>=osec-1 and sz<=max_size and sp<max_hashcalls:
                                    if (sz,sp)<best_szsp:
                                        best_szsp=(sz,sp)
                                        para_szsp=(h,d,b,k,w1,lenmap[osec][w1])
                                    if (sp,sz)<best_spsz:
                                        best_spsz=(sp,sz)
                                        para_spsz=(h,d,b,k,w1,lenmap[osec][w1])
            print(h)
        print(para_szsp,best_szsp)
        print(para_spsz,best_spsz)
