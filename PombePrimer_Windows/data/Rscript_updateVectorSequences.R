##This script reads the data from vectorsequences.txt,
#'and transforms it into chV.primer data that can then be
#'then used by server.R in the function fun.designPrimers
library(Biostrings)

pconfig <- c(
  "PRIMER_TASK=generic",
  "PRIMER_MIN_TM=55",
  "PRIMER_OPT_TM=60",
  "PRIMER_MAX_TM=62",
  "PRIMER_NUM_RETURN=2",
  "PRIMER_TM_FORMULA=1",
  "PRIMER_SALT_CORRECTIONS=1",
  "PRIMER_PICK_LEFT_PRIMER=1",
  "PRIMER_PICK_RIGHT_PRIMER=1",
  "PRIMER_OPT_SIZE=20",
  "PRIMER_MIN_SIZE=18",
  "PRIMER_MAX_SIZE=27",
  "PRIMER_EXPLAIN_FLAG=1",
  "PRIMER_PAIR_MAX_DIFF_TM=25",
  "PRIMER_WT_HAIRPIN_TH=6",
  "=")

#This function processes the results of the primer3 call
func.processprimers <- function(out, prefix, name) {    #prefix 'ch_' or 'HR_'
  returned.primers <- as.numeric(out[out[,1]=='PRIMER_PAIR_NUM_RETURNED',2])
  if (returned.primers==0) {warning('primers not detected for ', name, call. = FALSE); return(NA)}
  if (returned.primers>0){
    designed.primers <- do.call(cbind, lapply(0:1, function(i) {
      left.primer <- c(paste0(prefix, name, '-F'), 
                       out[out[,1]==paste0('PRIMER_LEFT_', i, '_SEQUENCE'),2],
                       out[out[,1]==paste0('PRIMER_LEFT_', i, '_TM'), 2],
                       ifelse(length(out[out[,1]==paste0('PRIMER_LEFT_', i, '_PROBLEMS'),2])==0, 'none', out[out[,1]==paste0('PRIMER_LEFT_', i, '_PROBLEMS'),2]),
                       strsplit(out[out[,1]==paste0('PRIMER_LEFT_', i), 2], ',')[[1]][1],            #this is the position of the primer, in <5'pos>,<3'pos> (start,end)
                       "")
      right.primer <- c(paste0(prefix, name, '-R'),
                        out[out[,1]==paste0('PRIMER_RIGHT_', i, '_SEQUENCE'),2],
                        out[out[,1]==paste0('PRIMER_RIGHT_', i, '_TM'), 2],
                        ifelse(length(out[out[,1]==paste0('PRIMER_RIGHT_', i, '_PROBLEMS'),2])==0, 'none', out[out[,1]==paste0('PRIMER_RIGHT_', i, '_PROBLEMS'),2]),
                        strsplit(out[out[,1]==paste0('PRIMER_RIGHT_', i), 2], ',')[[1]][1],
                        out[out[,1]==paste0('PRIMER_PAIR_', i, '_PRODUCT_SIZE'),2])
      
      if(returned.primers==99) { #func.primer_vector.chV will return a PRIMER_PAIR_NUM_RETURNED=99, since it gives no primer pairs
        right.primer[6] <- ''
        des.primers <- data.frame(Gene = name, rbind(left.primer, right.primer))} else {
          des.primers <- data.frame(Gene = name, rbind(left.primer, right.primer))
        }
      colnames(des.primers) = paste0(c('Gene', 'label', 'sequence', 'Tm', 'problems', 'startPosition', 'product size'), '_', i)
      return(des.primers)
    }))  
  }
}

func.primer_vector.chV <- function(seq1) {
  #pick right (reverse) primer in the first 300 nt of the sequence
  p3.input=tempfile()     #this is the primer 3 input file, that must be present in the directory. Creating is as a temp file saves cluttering
  seqtarget <- c('50,300')
  write(append(c(
    sprintf("SEQUENCE_TEMPLATE=%s",as.character(seq1)),
    sprintf("SEQUENCE_INCLUDED_REGION=%s", seqtarget),
    "PRIMER_PICK_LEFT_PRIMER=0"
  ),
  pconfig[c(-8, -14)]), #so it picks only the right primer
  p3.input)
  
  out.right <- as.data.frame(do.call(rbind, strsplit(try(system2("primer3_core.exe", p3.input, stdout=T)), split="=")), stringsAsFactors=F)
  unlink(p3.input) # delete temp files
  
  #pick left (forward) primer
  p3.input=tempfile()     #this is the primer 3 input file, that must be present in the directory. Creating is as a temp file saves cluttering
  seqtarget <- paste(nchar(seq1)-300, 299, sep=',')
  write(append(c(
    sprintf("SEQUENCE_TEMPLATE=%s",as.character(seq1)),
    sprintf("SEQUENCE_INCLUDED_REGION=%s", seqtarget),
    "PRIMER_PICK_RIGHT_PRIMER=0"
  ),
  pconfig[c(-9, -14)]), #so it picks only the left primer
  p3.input)
  
  out.left <- as.data.frame(do.call(rbind, strsplit(try(system2("primer3_core.exe", p3.input, stdout=T)), split="=")), stringsAsFactors=F)
  unlink(p3.input) # delete temp files
  
  #this function generates right and left primers independently, so I need a PRIMER_PAIR_NUM_RETURNED as a workaround for the func.processprimers
  out <- rbind(out.right, out.left)
  out <- out[!out[,1]=='PRIMER_PAIR_NUM_RETURNED',]   #get rid of 'PAIR_RETURNED' data, to replace it below
  
  if(as.numeric(out[out[,1]=='PRIMER_RIGHT_NUM_RETURNED',2])[1]>0 &
     as.numeric(out[out[,1]=='PRIMER_LEFT_NUM_RETURNED',2])[2]>0
  ) out <- rbind(out, c('PRIMER_PAIR_NUM_RETURNED', 99)) else {warning('primers not detected for ', name, call. = FALSE); return(NA)}
  
  designed.primers <- func.processprimers(out, 'chV', '')
  designed.primers[,1] <- 'avector'
  cat('chV primers designed \n')
  return(designed.primers)
}

func.updatevectorSequences <- function(vseq) {
    vectorSequences <- read.delim(vseq, stringsAsFactors = F)
    vectorSequences <- vectorSequences[order(vectorSequences[,1]), decreasing = T]
  
    
    #take vector names and insert sequences
    vs <- vectorSequences[,c(1, 19)]
    vs <- vs[vs[,2]!='',]
    vs <- split(vs, vs[,1], drop=T)
    
    #design and parse chV.primers
    chV.primers <- lapply(vs, function(a) func.primer_vector.chV(a[,2])[c(1:3,7,4:6)])
    nam <- do.call(rbind, lapply(names(chV.primers), function(a, b) rbind(a,a)))
    
    rownames(nam) <- NULL
    
    chV.primers2 <- cbind(nam, do.call(rbind, chV.primers))
    chV.primers2[,"startPosition_0"] <- as.numeric(as.character(chV.primers2[,"startPosition_0"]))
    chV.primers2[seq(1, nrow(chV.primers2), 2),8] <- -(vectorSequences[seq(2, nrow(vectorSequences), 2),"insert.bp"] - chV.primers2[seq(1, nrow(chV.primers2), 2),8])
    chV.primers2[seq(2, nrow(chV.primers2), 2),8] <- chV.primers2[seq(2, nrow(chV.primers2), 2),8] + 1 #to correct the 0-indexing
    
    #put the vector name in the Gene_0 column and delete the first column, so chV.primers2 can be input to fun.designPrimers 
    chV.primers2[,2] <- chV.primers2[,1]
    chV.primers2 <- chV.primers2[,-1]
    
    vmodules <- vectorSequences[, c(1, 10, 19)]
    vmodules <- vmodules[vmodules[,2] != '',]
    
    return(list('vectorSequences'=vectorSequences, 'chV.primers' = chV.primers2, 'vectorModules' = vmodules))
}

vectorData <- func.updatevectorSequences('data/vectorsequences.txt')
vData <- vectorData[[1]][,1]


save(vectorData, file='vectorData.RData')

#vectorData.Rdata is loaded from the 'data' folder, independently of pombegenomedata.RData