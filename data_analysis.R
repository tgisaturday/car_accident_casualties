setwd("./")
getwd()
install.packages("dplyr", repos = "http://cran.biodisk.org/")
install.packages("Hmisc")
install.packages("corrgram", repos = "http://cran.biodisk.org/")
install.packages("MASS")
install.packages("ggmap")
accidents <- read.csv("accidents.csv",header=TRUE,sep = ",")


# 1. Data Cleaning Process
head(accidents)
tail(accidents)
str(accidents)
dim(accidents)

library(dplyr)
glimpse(accidents)

colSums(is.na(accidents))
accidents <- accidents[complete.cases(accidents), ]
accidents <- na.omit(accidents)
accidents <- accidents[order(accidents$date),]

summary(accidents)

#2. Analyze Data
#2-1. Correlation

library(Hmisc)
rcorr(as.matrix(accidents))
library(corrgram)

corrgram(accidents, order = TRUE, lower.panel = panel.pie,
         upper.panel = panel.shade, text.panel = panel.txt,
         main = "Correlation of Variables in Accidents")

corrgram(accidents, order = TRUE, lower.panel = panel.ellipse,
         upper.panel = panel.pts, text.panel = panel.txt,
         diag.panel = panel.minmax, 
         main = "Correlation of Variables in Accidents")


corrgram(accidents, order = NULL, lower.panel = panel.shade,
         upper.panel = NULL, text.panel = panel.txt,
         cex.labels = 1.7, font.labels = 4,
         label.pos = c(0.7, 0.7), 
         col.regions = colorRampPalette(c("red", "white", "royalblue", "navy")), 
         main="Accident Analysis data")

#2-2. chisquare
library(MASS)

tbl = table(accidents$day_night, accidents$casualty,
            deparse.level = 2) 
print(chisq.test(tbl))

tbl = table(accidents$city, accidents$casualty,
            deparse.level = 2) 
print(chisq.test(tbl))

tbl = table(accidents$accident_class, accidents$casualty,
            deparse.level = 2) 
print(chisq.test(tbl))

tbl = table(accidents$road_type, accidents$casualty,
            deparse.level = 2) 
print(chisq.test(tbl))

tbl = table(accidents$day_night, accidents$city,
            deparse.level = 2) 
print(chisq.test(tbl))

tbl = table(accidents$accident_class, accidents$city,
            deparse.level = 2) 
print(chisq.test(tbl))

tbl = table(accidents$road_type, accidents$city,
            deparse.level = 2) 
print(chisq.test(tbl))

tbl = table(accidents$road_type, accidents$accident_class,
            deparse.level = 2) 
print(chisq.test(tbl))
tbl = table(accidents$road_type, accidents$accident_subclass,
            deparse.level = 2) 
print(chisq.test(tbl))

#2-3. Linear Regressions

library(ggplot2)

ggplot(data = accidents, mapping = aes(x = casualty, y = road_type)) +
  geom_line() + 
  geom_point() + geom_smooth(method="lm")

ggplot(data = accidents, mapping = aes(x = casualty, y = accident_class)) +
  geom_line() + 
  geom_point() + geom_smooth(method="lm")

ggplot(data = accidents, mapping = aes(x = casualty, y = accident_subclass)) +
  geom_line() + 
  geom_point() + geom_smooth(method="lm")

ggplot(data = accidents, mapping = aes(x = casualty, y = city)) +
  geom_line() + 
  geom_point() + geom_smooth(method="lm")



ggplot(data = accidents, mapping = aes(x = casualty, y = city)) +
  geom_point(size = 3, color = "red") + 
  ggtitle("City and Casualty") +
  theme(axis.text.x = element_text(face = "bold", hjust = 0, vjust = 1, angle = 90))

ggplot(data = accidents, mapping = aes(x =casualty, y = date, color = State)) +
  geom_point(size = 3, color = "blue") +
  ggtitle("Date and Casualty") +
  theme(plot.title = element_text(hjust = .5)) +
  theme(axis.title.x = element_text(vjust = .5, hjust = .5)) + 
  theme(axis.title.y = element_text(vjust = .5, hjust = .5))

# geom_path: Each group consists of only one observation. Do you need to adjust
# the group aesthetic?

library(ggmap)
geocode('Korea', source = 'google')
getmap <- get_map(location=c(lat=37.55, lon=126.97), zoom=11, maptype="roadmap")
MM <- ggmap(getmap)
MM+geom_point(aes(x=longitude, y=latitude, colour=as.factor(day_night)), data=accidents)
MM+geom_point(aes(x=longitude, y=latitude, size=casualty,colour=as.factor(casualty) ), data=accidents)

getmap2 <- get_map(location=geocode('Korea', source = 'google'), zoom=7, maptype="roadmap")
MM2 <- ggmap(getmap2)
MM2+geom_point(aes(x=longitude, y=latitude, colour=as.factor(day_night)), data=accidents)
MM2+geom_point(aes(x=longitude, y=latitude, size=casualty,colour=as.factor(casualty) ), data=accidents)


MM +geom_polygon(data = accidents, aes(x = longitude, y = latitude), stat = 'density2d', alpha = 0.3)+
  scale_fill_gradient(low = 'Yellow', high = 'Green')

getmap3 <- get_map(location=geocode('Korea', source = 'google'), zoom=7, maptype="roadmap")
MM3 <- ggmap(getmap3)
MM3 +geom_polygon(data = accidents, aes(x = longitude, y = latitude), stat = 'density2d', alpha = 0.3)+
  scale_fill_gradient(low = 'Yellow', high = 'Green')

# load example data (Fiji Earthquakes)
install.packages("leaflet")
install.packages("leafletR")
library(leaflet)
library(leafletR)
korea_lonlat = unlist(geocode('Korea', source = 'google'))
# store data in GeoJSON file (just a subset here)

accidents_geo <- accidents %>% select(latitude,longitude,casualty)
accidents_geo <- accidents_geo[rev(order(accidents_geo$casualty)),]
q.dat <- toGeoJSON(data=accidents_geo, dest=getwd(), name="accidents")
#The getRadValue function controls the radius of the data points */ 
getRadValue<-function(x) {
  return( ifelse (x >= 60, 36, ifelse (x >= 40, 24, ifelse (x >= 20,16,8)) ))
}

# make style based on quake magnitude
q.style <- styleGrad(prop="casualty", breaks=seq(0, 100, by=20),
                     style.val=rev(heat.colors(5)), leg="casualty",
                     fill.alpha=0.7, rad = 8)
q.style2 <- styleGrad(prop="casualty", breaks=seq(0, 100, by=20),
                      style.par="rad", style.val=c(5,10,20,25,30), leg="casualty", )
# create map

q.map <- leaflet(data=list(q.dat,q.dat), dest=getwd(), title="Casualty of Car Accidents in South Korea",
                 base.map="osm", style=list(q.style,q.style2), popup="casualty")
q.map

