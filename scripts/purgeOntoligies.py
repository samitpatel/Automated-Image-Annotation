import sys

def getParentClass(ontologies,level,wordmap):
  x = [i[:2] for i in ontologies]
  y = [(index,i[2].split('->')) for index,i in enumerate(ontologies) if len(i) >= 2]
  indices = []
  for index,i in enumerate(y):
    if len(i[1]) <= level:
      indices.append(index)

  return dict([(wordmap[(i[1])[-1].replace('_','')],wordmap[(i[1])[level].replace('_','')]) for index,i in enumerate(y) if index not in indices])
  

def main(ontologies,level,wordmap,features):
  
  y = getParentClass(ontologies,level,wordmap)
  print y
  fw = open('newfeatures','w')
  for i in features:
    if i[-1] in y:
      i[-1]=y[i[-1]]
    fw.write(','.join(i) + '\n')

  fw.close()

  
  #z = [(tuple(x[y[i][0]]),(y[i][1],y[i][2])) for i in range(len(y))]
  
  #print zip(m.keys()[:20],m.values()[:20])
  

def stripString(x):
  return x.strip()

def readFile(filename,delimiter=','):
    f = open(filename,'r').readlines()
    f = [i.replace('\n','').replace('\r','').split(delimiter) for i in f]
    return [map(stripString,i) for i in f]


if __name__ == "__main__":
  if(len(sys.argv)==5):
    
    ontologies = readFile(sys.argv[1],"\t")
   
    wordlist = readFile(sys.argv[2],"\t")
    wordlist = [tuple(i) for i in wordlist]

    wlist = dict(wordlist)
    wordmap = dict(zip(wlist.values(),wlist.keys()))

    features = readFile(sys.argv[3])

    main(ontologies,int(sys.argv[4]),wordmap,features)
  else:
    print "Usage python " + sys.argv[0] + " ontologies wordlist features level"
