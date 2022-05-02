# https://www.jstage.jst.go.jp/browse/cbij/list/-char/en

library(RCurl)
library(XML)
library(stringr)
library(writexl)
library(readxl)
library(pdftools)

srcPath = "/Users/jankipatel/Desktop/R-zhi/Project1/"

input = "https://www.jstage.jst.go.jp/browse/cbij/list/-char/en"

html =  getURL(input, followlocation=TRUE)

doc = htmlParse(html, asText=TRUE)

keywords = function(ndoiLink) {
  extraHtml = getURL(ndoiLink, followlocation=TRUE)
  extraDoc = htmlParse(extraHtml, asText=TRUE)
  
  docKeywords = xpathSApply(extraDoc, "//div[@class='global-para']", xmlValue)
  docKeywords = gsub("\tKeywords:\n\t","",docKeywords)
  docKeywords = gsub("\t*\n*\t*","",docKeywords)
  return(docKeywords)
}

affl = function(ndoiLink) {
  extraHtml = getURL(ndoiLink, followlocation=TRUE)
  extraDoc = htmlParse(extraHtml, asText=TRUE)
  
  docAuthorAffl = xpathSApply(extraDoc, "//div[@class='accordion_container']//p", xmlValue)
  docAuthorAffl = gsub("\n\t*","",docAuthorAffl)
  docAuthorAffl = paste(shQuote(docAuthorAffl), collapse=", ")
  return(docAuthorAffl)
}

corEmail = function(link, year, i) {
  download.file(link,paste(srcPath, year, i, ".pdf"),mode="wb")
  text = pdf_text(paste(srcPath, year, i, ".pdf"))
  
  docEmail =  str_extract(text[1],"[E][-][m][a][i][l].*")
  docEmail = gsub("E-mail(\\:*)\\s*","",docEmail)
  return(docEmail)
}

 corAuthor = function(link, year, i) {
  text = pdf_text(paste(srcPath, year, i,".pdf"))
  
  docCorAut = str_extract(text[1],".*?\\*")
  docCorAut = str_extract(docCorAut,"(\\w+)\\s(\\w+)(\\d*)(\\,*)(\\s*)(\\d*)\\*")
  docCorAut = gsub("(\\d*)(\\,*)(\\s*)(\\d*)(\\,*)(\\*)","",docCorAut)
  return(docCorAut)
}

yearfunc = function(year) {
  fyear = (year %% 100)
  YearLink = xpathSApply(doc, paste0("//a/@href[contains(.,'/", fyear,"/')]"))
  YearLink = gsub("href","",YearLink)
  dataInput = YearLink[1]
  # print(YearLink)
  htmldata = getURL(dataInput, followlocation = TRUE)
  docData = htmlParse(htmldata, asText = TRUE)
  
  docDOI = xpathSApply(docData, "//div[@class='searchlist-doi']", xmlValue)
  docDOI = gsub("DOI","",docDOI)
  
  docTitle = xpathSApply(docData, "//div[@class='searchlist-title']", xmlValue)
  
  docAuthors = xpathSApply(docData, "//div[@class='searchlist-authortags customTooltip']", xmlGetAttr, "title")
  
  docAbstract = xpathSApply(docData, "//div[@class='inner-content abstract']", xmlValue)
  docAbstract = gsub("\n\t*","",docAbstract)
  docAbstract = gsub("\\s*View\\s*full\\s*abstract\t*","",docAbstract)
  
  docPublicationDate = xpathSApply(docData, "//div[@class='searchlist-additional-info']", xmlValue)
  docPublicationDate = gsub("\n\t*", "", docPublicationDate)
  docPublicationDate = gsub(".*Published:\\s*", "", docPublicationDate)
  docPublicationDate = gsub("\\s*Released:.*", "", docPublicationDate)
  
  docKeywords = vector("integer", length(docDOI))
  docAuthorAffl = vector("integer", length(docDOI))
  i = 1
  
  for (ndoi in docDOI) {
    docKeywords[i] = keywords(ndoi)
    docAuthorAffl[i] = affl(ndoi)
    i = i + 1
  }
  
  pdfLinks = xpathSApply(docData, "//div[@class='lft']//a", xmlGetAttr, "href")
  
  docCorEmail = vector("integer", length(pdfLinks))
  docCorAuthor = vector("integer", length(pdfLinks))
  j = 1
  
  for (link in pdfLinks) {
    docCorEmail[j] = corEmail(link, year, j)
    docCorAuthor[j] = corAuthor(link, year, j)
    j = j + 1
  }
  
  k = 1
  for (auth in docCorAuthor) {
    if(is.na(auth)){
      docCorAuthor[k] = docAuthors[k]
    }
    k = k + 1
  }
  
  # print(docDOI)
  # print(docTitle)
  # print(docAuthors)
  # print(docAbstract)
  # print(docPublicationDate)
  # print(docAuthorAffl)
  # print(docKeywords)
  # print(docCorAuthor)
  # print(docCorEmail)
  
  finalOutput = data.frame("DOI" = docDOI, "Title" = docTitle, "Authors" = docAuthors, "Author Affiliations" = docAuthorAffl, "Corresponding Author" = docCorAuthor, "Corresponding Author's Email" = docCorEmail, "Publication Date" = docPublicationDate, "Abstract" = docAbstract, "Keywords" = docKeywords)
  # View(finalOutput)
  
  write_xlsx(finalOutput,paste(srcPath, year, "CrawledData.xlsx"))
  finalOut = read_excel(paste(srcPath, year, "CrawledData.xlsx"))
  View(finalOut)
}

yearfunc(2005)




