# TODO list
- update comments on server.R line 35: '        RF <- toString(reverseComplement(subseq(eval(parse(text=a)), start=b+3-maxsize, width=maxsize)))         #'RF' understood as the right flanking region starting from the ATG'  
  The comment should mention the STOP, not the ATG

- edit server.R to delete (or offer the option to delete?) the STOP codon when making a C-terminal insertion
