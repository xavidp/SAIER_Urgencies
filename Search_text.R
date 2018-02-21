if (!require("pacman")) install.packages("pacman")
pacman::p_load_gh("trinker/textreadr")
pacman::p_load(textreadr, magrittr, readtext)
library(textreadr)
#library(pdftools)
#library(readtext)

# ------------------------------------------
## OPTION A:
## Smart way to proceed with textreadr goodies and jargon:
## (taken from https://github.com/trinker/textreadr#read-directory-contents )
#library(magrittr)
#read_dir("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències CUESB\\2017") %>%
#peek(Inf, 40)

# File List All 
#> colnames(fla)
#[1] "document" "content" 
fla <- read_dir("K:\\QUOTA\\DIMM_COMU\\SAIER\\Urgències CUESB\\2017") 

# Cerca "Aeroport" (case insensitive)
# -----------------
fla.aero.idx <- grep("aeroport", fla$content, fixed=T, ignore.case = TRUE)
#head(fla$document[fla.aero.idx])
fla.aa.idx <- grep("asil", fla$content[fla.aero.idx], fixed=T)
fla.api.idx <- grep("internacional", fla$content[fla.aero.idx], fixed=T)
grep("internacional", fla$content[fla.aero.idx], fixed=T, value=T, ignore.case = TRUE)

# Cerca "Asil" (case insensitive)
# -----------------
fla.asil.idx <- grep("asil", fla$content, ignore.case = TRUE)
head(fla$document[fla.asil.idx])
length(fla$document[fla.asil.idx])
length(unique(fla$document[fla.asil.idx]))
#197
unique(fla$document[fla.asil.idx])
# Altres paraules clau o cadenes de text a buscar:
#* "Rebem alerta de SAIER"
#* refugia*
#* estatut de refugiat
#* protecció internacional
#* denegat/da

# Cerca "Rebem alerta de SAIER" (case insensitive)
# -----------------
fla.saier.idx <- grep("Rebem alerta de SAIER", fla$content, ignore.case = TRUE)
head(fla$document[fla.saier.idx])
length(fla$document[fla.saier.idx])
# 52
length(unique(fla$document[fla.saier.idx]))
# 51
unique(fla$document[fla.saier.idx])

# PENDENTS de DEPURAR:
# =======================
# # Depurar cas "ComunicacioDerivació > "O (sense informe)"
# # Trobar casos de: Denegació a Espanya o a altre pais UE. Cercar per "denega"


# Trobar casos de: Denegació a Espanya o a altre pais UE. Cercar per "denega"
# --------------------------------
fla.deneg.idx <- grep("denega", fla$content, ignore.case = TRUE)

head(fla$document[fla.deneg.idx])
length(fla$document[fla.deneg.idx])
length(unique(fla$document[fla.deneg.idx]))
#197
unique(fla$document[fla.deneg.idx])

# ------------------------------------------
## OPTION B:
## Hand made way to get text from all docx and pdf files 
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
