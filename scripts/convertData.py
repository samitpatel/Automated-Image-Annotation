import os,sys,numpy

def writeToFile(filename,x):
  fw = open(filename,'a')
  for line in x:
    fw.write(line + '\n')
  fw.close()

def main(): 
  if(len(sys.argv) == 3):
    directory = sys.argv[1]
    outputFilename = sys.argv[2]
    listing = os.listdir(directory)
    
    fw = open('features.dat','a')
    for infile in listing:
      f = open(directory+"/"+infile,'r')#numpy.loadtxt(directory+"/"+infile, dtype=float, delimiter=' ')
      f = [i.replace('\n','').split() for index,i in enumerate(f)]
      data = [(i[0:2],i[2:-1],i[-1]) for i in f]
      x = []
      for line in f:
        tempStr = line[-1]+' '
        for i in range(2,len(line)-1):
          if(i < len(line)-2):
            tempStr += str(i-2)+":"+line[i]+' '
          else:
            tempStr += str(i-2)+":"+line[i]
        x.append(tempStr)
      writeToFile(outputFilename,x)
  else:
    print "Usage: python "+sys.argv[0] + " <directory-name> <output-filename>"

if __name__ == "__main__":
  main()
