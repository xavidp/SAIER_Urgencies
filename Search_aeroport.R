if (!require("pacman")) install.packages("pacman")
pacman::p_load_gh("trinker/textreadr")
pacman::p_load(textreadr, magrittr, readtext)
library(textreadr)
#library(pdftools)
#library(readtext)

# ------------------------------------------
## Smart way to proceed with textreadr goodies and jargon:
## (taken from https://github.com/trinker/textreadr#read-directory-contents )
#library(magrittr)
#read_dir("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències CUESB\\2017") %>%
#peek(Inf, 40)

# File List All 
#> colnames(fla2)
#[1] "document" "content" 
fla2 <- read_dir("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències CUESB\\2017") 
fla2.aero.idx <- grep("aeroport", fla2$content, fixed=T)
#head(fla2$document[fla2.aero.idx])
fla2.aa.idx <- grep("asil", fla2$content[fla2.aero.idx], fixed=T)
fla2.api.idx <- grep("internacional", fla2$content[fla2.aero.idx], fixed=T)
grep("internacional", fla2$content[fla2.aero.idx], fixed=T, value=T)

# ------------------------------------------
# Hand made way to get text from all docx and pdf files 
# ------------------------------------------
# File List ALL of them (pdf and docx)
fla <- list.files(path="K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències CUESB\\2017", 
                  pattern=".docx|.pdf", full.names=T, ignore.case=T)

length(fla)

# Index of docx files in File List
fld.idx <- grep(".docx", fla)
length(fld.idx)

# Index of pdf files in File List
flp.idx <- grep(".pdf", fla)
length(flp.idx)

# # File List docx
# fld <- list.files(path="K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències CUESB\\2017", 
#                   pattern=".docx", full.names=T, ignore.case=T)
# 
# length(fld)
# 
# # File List pdf
# flp <- list.files(path="K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències CUESB\\2017", 
#                   pattern=".pdf", full.names=T, ignore.case=T)
# length(flp)

#txtfl <- sapply(fl, pdf_text)

txtfl[fld.idx] <- sapply(fla[fld.idx], read_docx)
txtfl[flp.idx] <- sapply(fla[flp.idx], read_pdf)

#head(fla)
#tail(fla)
head(txtfl)
str(txtfl)
dft <- data.frame(cbind(fla, txtfl))
grep("aeroport", dft)
grep("aeroport", dft[2], value = TRUE)
class(dft)
