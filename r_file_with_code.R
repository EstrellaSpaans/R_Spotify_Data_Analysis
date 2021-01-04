
#NOTE: REMOVE # TO INSTALL PACKAGES
#install.packages("tidyverse")
#install.packages("data.table")
#install.packages("httr")
#install.packages("stringr")
#install.packages("corrplot")
#install.packages("broom")
#install.packages("gridExtra")
library(tidyverse)
library(data.table)
library(httr)
library(stringr)
library(corrplot)
library(broom)
library(gridExtra)

#___________________________________________

#Setting up Spotify open source connection
#Connecting with open source through developer platform, connecting it to domain.

clientID = '2f601d78715f4c8ba983ee926e42ab10'
secret = '84f831e38ea34cb4bf3955e448667332'
response = POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(clientID, secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)
mytoken = content(response)$access_token
HeaderValue = paste0('Bearer ', mytoken)

#___________________________________________

#CREATE GRAPH FOR INDUSTRY REVENUE BY CATEGORY
# Read the csv file
music_revenue <-
  read.csv(
    "https://98f21455-87d0-45ec-8569-85946ffeb5fe.filesusr.com/ugd/3fe52d_3af6b11377b94739a6d2d3d8dd91a160.csv?dn=Revenue_Category.csv"
  )

#Select "music_revenue.csv" in case link does not work (remove #)
#read.csv(file.choose(), header=TRUE) 

# Pivot the variables and make the geo graph
music_revenue_categories <- music_revenue %>%
  pivot_longer(
    c(Physical, Performances, Downloads, Streaming, Synchronisation), # Transforming the plot in order to make stacked bar chart
    names_to = "Category", #Assign to new column
    values_to = "values" #Assign to new column
  ) %>%
  ggplot(., aes(x = X, y = values)) + #plot the data
  geom_col(aes(fill = Category)) + #filling the color by revenue category
  xlab("") + ylab("Revenue (US$ Billions)") #adjusting axis-labels 

music_revenue_categories #showing the plot

#___________________________________________

#1. IMPORTING DATASETS
# Importing genres data set
genres <-
  read.csv(
    'https://98f21455-87d0-45ec-8569-85946ffeb5fe.filesusr.com/ugd/3fe52d_f3e30b76c3a54bf0b136e1acf81921ad.csv?dn=data_w_genres.csv'
  )

#Select "data_by_genres.csv" in case link does not work (remove #)
#read.csv(file.choose(), header=TRUE) 

# Importing years data set
years <-
  read.csv(
    'https://98f21455-87d0-45ec-8569-85946ffeb5fe.filesusr.com/ugd/3fe52d_82a6c0af030f485aad660cd207586b34.csv?dn=data_by_year.csv'
  )

#Select "data_by_year.csv" in case link does not work (remove #)
#read.csv(file.choose(), header=TRUE) 

# Importing songs data set
songs <-
  read.csv(
    'https://98f21455-87d0-45ec-8569-85946ffeb5fe.filesusr.com/ugd/3fe52d_a16641d9064c48e7865982427de793f7.csv?dn=data.csv'
  )

#Select "data.csv" in case link does not work (remove #)
#read.csv(file.choose(), header=TRUE) 

# Importing top200 data set
top200 <-
  read.csv(
    'https://98f21455-87d0-45ec-8569-85946ffeb5fe.filesusr.com/ugd/3fe52d_b17d3660e6a34f33a7e2623d5e815080.csv?dn=top200-global-daily-2020-10-31.csv',
    header = TRUE, #header is there
    skip = 1 #header is not in first row, so skip the first row
  )

#Select "top200-global-daily-2020-10-31.csv" in case link does not work (remove #)
#read.csv(file.choose(), header=TRUE, skip = 1) 


#___________________________________________

#2. PREPARING "songs" DATASET
#Creating a copy of Genres in order to join with usuable columns
adjusted_genres <- genres %>%
  select(artists, genres) 

#Creating a copy of songs & split the song that have artist collaborations
song <- songs %>%
  separate(artists,
           into = c("artist1", "other.artists"),
           sep = ",")

#Removing weird characeristics and vectors within strings.
song$artist1 <- str_match_all(song[, "artist1"], "[a-z, A-Z]+")
song$artist1 <- gsub("^c\\(|\\)$", "", song$artist1)

#Seperating it one more time as is did not do a good job in the first place. Still multiple artists in column
song <- song %>%
  separate(artist1,
           into = c("artist2", "other.artists2"),
           sep = ",")

#Removing Unnecessary columns created because of split
song$other.artists2 <- NULL
song$other.artists <- NULL

#Rename Artist column
song <- song %>%
  rename(artists = artist2)

#Joining the genres with the songs based on artists.
songs <- left_join(song , adjusted_genres, by = "artists")

#Remove other unnecessary colums 
songs$key <- NULL
songs$mode <- NULL
songs$explicit <- NULL

#___________________________________________

## 3. PREPARING "top200" DATASET
#Splitting the Track ID from the URL
track_id <-
  str_split_fixed(top200$URL, 'https://open.spotify.com/track/', 2)

#Subsetting right column from matrix created. This only contains the track id. 
track_id <- track_id[, 2]

#Converting matrix to a vector with values of track id. 
vector_track_id <- c(track_id)

#Creating a new column just with the id's and add it to top200
top200 <- top200 %>%
  mutate(., Track.Id = vector_track_id)

#Removing unnessesary columns of urls, as they ar not needed anymore.
top200[, c('URL')] <- list(NULL)

#Renaming columns to match with the other data frame (preparation for join)
top200 <- top200 %>%
  rename(
    .,
    c(
      "position" = "Position",
      "track.name" = "Track.Name",
      "streams" = "Streams",
      "track.id" = "Track.Id",
      "artists" = "Artist"
    )
  )

#Changing id to be matching (some ids were outdated)
top200$track.id[top200$track.id == "7ytR5pFWmSjzHJIeQkgog4"] <-
  "4Aykm3xrOFSHrAnv80KUhh"
top200$track.id[top200$track.id == "6thXB4RmajS4oZPNiBAKy0"] <-
  "3m0y8qLoznUYi73SUBP8GI"
top200$track.id[top200$track.id == "6OqrJqDMu15AGJHJazg9Nr"] <-
  "463CkQjx2Zk1yXoBuierM9"
top200$track.id[top200$track.id == "1rgnBhdG2JDFTbYkYRZAku"] <-
  "5ZULALImTm80tzUbYQYM9d"
top200$track.id[top200$track.id == "3apeXzypBMnUfYcZYNX6DH"] <-
  "37ZtpRBkHcaq6hHy0X98zn"
top200$track.id[top200$track.id == "6gBFPUFcJLzWGx4lenP6h2"] <-
  "2SzjMcZIsE2zUWQnccsTAo"
top200$track.id[top200$track.id == "513JwqDfENCJ0Woi0T42qy"] <-
  "6hci8n9UowepjRmCc6CKTv"
top200$track.id[top200$track.id == "13vDU8nPsvTGEVTMB8Vw7g"] <-
  "6AzKhCHOms83jvNVLsz0Bt"
top200$track.id[top200$track.id == "30VrBsh1STRBoIrhQOAwzK"] <-
  "2VOomzT6VavJOGBeySqaMc"
top200$track.id[top200$track.id == "79s5XnCN4TJKTVMSmOx8Ep"] <-
  "6PnTgx9lyvLGIcPnroCvc2"
top200$track.id[top200$track.id == "6i7zAdNhzUN2k1HcrBxPHG"] <-
  "14ngWWxvUSnIMXgF6rzSk1"
top200$track.id[top200$track.id == "1RSzyxqtIO4yX3EyiV4zT5"] <-
  "5vGLcdRuSbUhD8ScwsGSdA"
top200$track.id[top200$track.id == "4u7EnebtmKWzUH433cf5Qv"] <-
  "7tFiyTwD0nx5a1eklYtX2J"
top200$track.id[top200$track.id == "0jT8Nl0shPS8115is0wD2Q"] <-
  "0Snbzbd74RLfL0i4nn1vU5"
top200$track.id[top200$track.id == "3xgT3xIlFGqZjYW9QlhJWp"] <-
  "6Qs4SXO9dwPj5GKvVOv8Ki"
top200$track.id[top200$track.id == "24IgCW19L8lXKyFZwzFtD3"] <-
  "14wf185UxfNbSy8dwt4r4q"
top200$track.id[top200$track.id == "2xLMifQCjDGFmkHkpNLD9h"] <-
  "0u695M7KyzXaPIjpEbxOkB"

#Assigning songs to different variable to prevent adjust the original data. 
adjusted_songs200 <- songs

#Removing unnessesary columns that we do not want to join. 
adjusted_songs200[, c('name', 'artists')] <- list(NULL)

#Renaming columns
adjusted_songs200 <- adjusted_songs200 %>%
  rename(., "track.id" = "id")

#Joining song characteristics from Song data frame with top200 data frame.
top200 <- left_join(top200, adjusted_songs200, by = "track.id")

#Dealing with NA values. Filling in missing ones. 
top200[2, 19] <- "['hip hop']"
top200[26, 19] <- "['hip hop']"
top200[32, 19] <- "['dance pop', 'pop']"
top200[51, 19] <- "['pop']"
top200[75, 19] <- "['classic rock']"
top200[77, 19] <- "['k-pop', 'k-pop girl group']"
top200[92, 19] <- "['r&b']"
top200[98, 19] <- "['pop']"
top200[98, 19] <- "['pop']"
top200[106, 19] <- "['r&b']"
top200[112, 19] <- "['pop']"
top200[145, 19] <- "['classic rock']"
top200[147, 19] <- "['indie poptimism']"
top200[149, 19] <- "['hip hop']"
top200[155, 19] <- "['hip hop']"
top200[178, 19] <- "['hip hop']"
top200[185, 19] <- "['edm']"
top200[195, 19] <- "['r&b']"
top200[198, 19] <- "['pop']"

#___________________________________________

# 4. PREPARING "popular_genres"" DATASET
# Matching genres through string look up and subset it for each specific genre according to the BBC.
k_pop <- songs[songs$genres %like% "k-pop",]
latin_pop <- songs[songs$genres %like% "latin pop",]
edm <- songs[songs$genres %like% "edm",]
african <- songs[songs$genres %like% "afr",]
hip_hop <- songs[songs$genres %like% "hip hop",]

# Adding genre column based on the overall genre
k_pop = k_pop %>%
  mutate(genre = rep("k-pop", 526))

latin_pop = latin_pop %>%
  mutate(genre = rep("latin pop", 2194))

edm = edm %>%
  mutate(genre = rep("edm", 997))

african = african %>%
  mutate(genre = rep("african", 921))

hip_hop = hip_hop %>%
  mutate(genre = rep("hip hop", 8173))

# Removing original column with all genres specified. This is irrelevant for our analysis. 
k_pop$genres <- NULL
latin_pop$genres <- NULL
edm$genres <- NULL
african$genres <- NULL
hip_hop$genres <- NULL

# Generating popular genres dataframe from subsetted genres.
popular_genres <- rbind(k_pop, latin_pop, edm, african, hip_hop)

#4. REMOVING UNNECESSARY VARIABLES
song <- NULL
adjusted_songs200 <- NULL
adjusted_genres <- NULL

#___________________________________________

# CHECNKING DESCRIPTIVE ANALYTICS
str(top200)
summary(top200)

#Checking other datasets
  #(Remove or add # to switch variables )
x <- songs
#x <- years
#x <- genres
#x <- popular_genres

  #calling function
str(x)
summary(x)

#Changing data types based on structure analysis
top200$track.name <- as.character(top200$track.name)
top200$artists <- as.character(top200$artists)
genres$genres <- as.character(genres$genres)
genres$artists <- as.character(genres$artists)
songs$genres <- as.character(songs$genres)
songs$name <- as.character(songs$name)
songs$release_date <- as.character.Date(songs$release_date)
popular_genres$release_date <-
  as.character.Date(popular_genres$release_date)
years$year <- as.character.Date(years$year)

#___________________________________________

#Receiving album data showing that Spotify Data has Null-values for some tracks
#Specifying albnum id and variables to retrieve data. 

albumID = "xK-6JI_1TNGHgsdLgOFUkw"
track_URI = paste0('https://api.spotify.com/v1/albums/', albumID, '/tracks')
track_response = GET(url = track_URI, add_headers(Authorization = HeaderValue))
tracks = content(track_response)

#Creating dataframe contain album information
ntracks = length(tracks$items)
tracks_list <- data.frame(
  name = character(ntracks),
  id = character(ntracks),
  artist = character(ntracks),
  disc_number = numeric(ntracks),
  track_number = numeric(ntracks),
  duration_ms = numeric(ntracks),
  stringsAsFactors = FALSE
)
#Loop through each item in the list and input the details into the dataframe:
for (i in 1:ntracks) {
  tracks_list[i,]$id <- tracks$items[[i]]$id
  tracks_list[i,]$name <- tracks$items[[i]]$name
  tracks_list[i,]$artist <- tracks$items[[i]]$artists[[1]]$name
  tracks_list[i,]$disc_number <- tracks$items[[i]]$disc_number
  tracks_list[i,]$track_number <- tracks$items[[i]]$track_number
  tracks_list[i,]$duration_ms <- tracks$items[[i]]$duration_ms
}

# Get Additional Track characteristics through seperate link
for (i in 1:nrow(tracks_list)) {
  Sys.sleep(0.10)
  track_URI2 = paste0('https://api.spotify.com/v1/audio-features/',
                      tracks_list$id[i])
  track_response2 = GET(url = track_URI2,
                        add_headers(Authorization = HeaderValue))
  tracks2 = content(track_response2)
  
  tracks_list$key[i] <- tracks2$key
  tracks_list$mode[i] <- tracks2$mode
  tracks_list$time_signature[i] <- tracks2$time_signature
  tracks_list$acousticness[i] <- tracks2$acousticness
  tracks_list$danceability[i] <- tracks2$danceability
  tracks_list$energy[i] <- tracks2$energy
  tracks_list$instrumentalness[i] <- tracks2$instrumentalness
  tracks_list$liveliness[i] <- tracks2$liveness
  tracks_list$loudness[i] <- tracks2$loudness
  tracks_list$speechiness[i] <- tracks2$speechiness
  tracks_list$valence[i] <- tracks2$valence
  tracks_list$tempo[i] <- tracks2$tempo
  
  # Assign the track to example_variable + print title.
  Dua_lipa <- tracks_list
  print(" Dua Lipa album result from Spotify's Open Source")
}

#Filtering example showing one track (that is has Null-values)
Dua_lipa[1,] 

#___________________________________________

#CREATING LINE-CHART TO SHOW HOW CHARACTERISRICS HAVE CHANGED OVER TIME

# Make a list of variables
years$year <- as.integer(years$year)
years_data <- years %>%
  filter(year <= 2020, year >= 2010) %>%
  pivot_longer(
    c(
      "acousticness",
      "danceability",
      "energy",
      "instrumentalness",
      "liveness",
      "speechiness",
      "valence"
    ),
    names_to = "characteristics",
    values_to = "value"
  )

# Make line chart by characteristics
ggplot(years_data, aes(x = year, y = value)) +
  xlab("") + ylab("Characteristic Value") +
  scale_x_continuous(breaks = seq(2010, 2020, 1)) +
  geom_line(aes(color = characteristics))  #defining the colors by characteristics

#___________________________________________

# CORRELATION MATRIX BETWEEN THE DIFFERENT VARIABLES 

# Set the color for correlations chart
col <-
  colorRampPalette(c(
    "#08AFF6",
    "#35A5DC",
    "#619BC1",
    "#8E91A7",
    "#BA878C",
    "#E77D72"
  ))

# Select variables for correlations chart
data_corr <- songs %>%
  select(
    "popularity",
    "acousticness",
    "danceability",
    "duration_ms",
    "energy",
    "instrumentalness",
    "liveness",
    "loudness",
    "speechiness",
    "tempo",
    "valence"
  )

# Define M to make correlations with method of pearson
M = cor(data_corr, method = "pearson")

# Set the confidence level 95%
res1 <- cor.mtest(data_corr, conf.level = 0.95)

# Make the correlation matrix chart
corrplot(
  M,
  col = col(200), #methods with colors + setting aesthetics 
  tl.col = "black", 
  tl.srt = 45,
  p.mat = res1$p,
  sig.level = 0.01, 
  type = "upper"
)

#___________________________________________

# SCATTERPLOT FOR VARIABLES POPULARITY AND STREAMS 

#Scatter plot for variables popularity and streams
ggplot(top200, aes(x = streams, y = popularity)) +
  geom_point() + #defines scatterplot
  geom_smooth(method = "lm", color = "#E77D72") +  #adds linear regression line
  xlab("Number of streams") + ylab("Popularity Score") +
  geom_hline(
    aes(size = 7),
    yintercept = 83,
    linetype = "dotted",
    color = "#E77D72"
  ) #defines scatterplot treshhold

#___________________________________________

# CALCULATING THE OUTLIERS FOR TOP 200 AS A PERCENTAGE

#Discover how many values are below score 85
number <- top200 %>%
  filter(popularity < 83) %>%
  nrow()

#Calculate percentage of outliers
(number / 200) * 100

#___________________________________________

# SUMMARY SIMPLE LINEAR REGRESSION STREAMS VS POPULARITY

#Print title for the summary
print("Simple Linear Regression Summary:")

#Summary for linear regression variables popularity and number of streams
lm(formula = popularity ~ streams, data = top200) %>%
  summary() #showing summary statistics

#___________________________________________

# SHOWING DENSITY PLOTS OF CHARACTERISTICS FOR SONGS IN THE TOP200
# Pivoting the table
top200_p <- top200 %>%
  pivot_longer(
    c(
      "valence",
      "acousticness",
      "danceability",
      "energy",
      "liveness",
      "speechiness",
      "instrumentalness",
      "loudness"
    ),
    names_to = "characteristic",
    values_to = "value"
  )

# Create density plot and facet wrap by characteristic
ggplot(data = top200_p, aes(x = value)) +
  geom_density() +
  xlab(" ") + ylab("") +
  facet_wrap( ~ characteristic,
              ncol = 4,
              nrow = 2,
              scales = 'free') + # doing a facet_wrap
  theme(axis.text.x = element_text(angle = 50, hjust = 1),
        axis.text.y = element_blank()) + #format style
  geom_boxplot(
    color = "white",
    alpha = 1,
    width = 0.001,
    #adding outliers in plot + aes of outliers
    outlier.colour = "#E77D72",
    outlier.fill = "red",
    outlier.size = 1,
    na.rm = TRUE
  ) 

#___________________________________________

# THE OUTLIERS FOR EACH GENRE BY POPULARITY

# Create Boxplot by different genre
ggplot(data = popular_genres, aes(x = genre, y = popularity, color = genre)) +
  xlab("Popular genres") + ylab("Popularity Score") +
  geom_boxplot(outlier.size = 0.3,
               #showing the ourliers
               na.rm = TRUE,
               #specify the NA
               outlier.colour = "Black") #define outlier color

#___________________________________________

# DENSITY PLOT BY GENRE ALL SONGS

# Pivot the variables of popular_genres 
pivot_popular_genres <- popular_genres %>%
  pivot_longer(
    c(
      "valence",
      "duration_ms",
      "acousticness",
      "danceability",
      "energy",
      "liveness",
      "speechiness",
      "instrumentalness",
      "loudness",
      "tempo"
    ),
    names_to = "characteristics",
    values_to = "value"
  )

# Create density plot facet wrap by characteristics
ggplot(data = pivot_popular_genres, aes(x = value)) +
  geom_density(aes(color = genre), position = "identity") +
  facet_wrap(~ characteristics,
             ncol = 5,
             nrow = 2,
             scales = 'free') +
  xlab(" ") + ylab("") +
  theme(axis.text.x = element_text(angle = 50, hjust = 1),
        axis.text.y = element_blank())

#___________________________________________

# ADJUSTING DATASET FOR MODELLING 

#Creating an overall modelling dataset
modelling_data <- popular_genres %>%
  filter(genre %in% c("k-pop", "hip hop", "edm") &
           popularity >= 25) %>%
  select(-c("release_date", "year", "duration_ms", "id", "artists"))

#Setting seed to get the same numbers
set.seed(123)

# Seperating modelling data for training data
training_data <- modelling_data %>%
  slice_sample(prop = 0.6) # 60% of the dataset

eft <-
  modelling_data[!(modelling_data$name %in% training_data$name),]

#Seperating data for our quary dataset
query_data <- left %>%
  slice_sample(prop = 0.5) # 20% of the dataset

#Genre specific Data for training
query_data_edm <- query_data %>%
  filter(genre == "edm")

query_data_k_pop <- query_data %>%
  filter(genre == "k-pop")

query_data_hip_hop <- query_data %>%
  filter(genre == "hip hop")

#Seperating last data for our testing data set
test_data <- left[!(left$name %in% query_data$name),]

#Genre specific Data for training
training_data_edm <- training_data %>%
  filter(genre == "edm")

training_data_k_pop <- training_data %>%
  filter(genre == "k-pop")

training_data_hip_hop <- training_data %>%
  filter(genre == "hip hop")

#Subset Test data
test_data <-
  modelling_data[!(modelling_data$name %in% training_data$name),]

#Genre specific Data for test
test_data_edm <- test_data %>%
  filter(genre == "edm")

test_data_k_pop <- test_data %>%
  filter(genre == "k-pop")

test_data_hip_hop <- test_data %>%
  filter(genre == "hip hop")

#Remove unnecessary table
left <- NULL

#___________________________________________

#SCATTERPLOT MATRIX TO CHECK TYPE OF RELATIONSHIP AND HISTOGRAMS FOR DISTRIBUTION

#Creating a scatterplot to show the relationship with the popularity score for each characteristic
scatterplot_charac <- training_data %>%
  pivot_longer(
    c(
      "valence",
      "acousticness",
      "danceability",
      "energy",
      "liveness",
      "speechiness",
      "loudness",
      "tempo",
      "instrumentalness"
    ),
    names_to = "characteristics",
    values_to = "value"
  ) %>%
  ggplot(., aes(x = popularity, y = value)) +
  geom_point(alpha = 0.4) +
  ggtitle("Scatterplot of Song Characteristics by Popularity") +
  theme(plot.title = element_text(hjust = 0.5)) +
  facet_wrap( ~ characteristics, scales = "free") + ylab(" ") + xlab("by Popularity Score")

#Creating a histrogram to show distribution for each characteristic
histogram_charac <- training_data %>%
  keep(is.numeric) %>%
  select(-popularity) %>%
  gather() %>%
  ggplot(aes(value, fill = value)) +
  facet_wrap( ~ key, scales = "free") +
  geom_histogram() +
  ggtitle("Song Characteristics Distributions") +
  theme(plot.title = element_text(hjust = 0.5)) + ylab(" ") + xlab("Song Characteristic Value")

#Displaying the plots next to each other
grid.arrange(scatterplot_charac, histogram_charac, ncol = 2)

#___________________________________________

#SET UP TO GENERATE ALL POSSIBLE MODEL COMBINATIONS FOR EACH DATASET

  # Creating A vector with the different characteristics
characteristics <-
  c(
    "popularity",
    "danceability",
    "energy",
    "loudness",
    "speechiness",
    "acousticness",
    "liveness",
    "valence",
    "tempo",
    "instrumentalness"
  )

# List for function and combinations
N <- list(1, 2, 3, 4, 5, 6, 7, 8, 9)

#Calculate all the combinations possible for the models and save it in a variable
COMB <- sapply(N, function(m)
  combn(x = characteristics[2:10], m))

#Create empty list for all formula combinations and starting variable for list.
formulas <- list()
k = 0

# Loop to create the formula list
for (i in seq(COMB)) {
  tmp <- COMB[[i]]
  for (j in seq(ncol(tmp))) {
    k <- k + 1
    formulas[[k]] <-
      paste("popularity", "~", paste(tmp[, j], collapse = " + "))
  }
}

#--------------------------------------------------------
##Design length variable for all all possible combinations.
desired_length <- c(1:511)

#Create empty vector for the names of each model.
model_names <- vector(mode = "character", length(desired_length))

# For loop to add the names of each model
for (i in seq_along(desired_length)) {
  model_names[i] <- str_c("model", desired_length[i])
}

#--------------------------------------------------------
#Function for the r_sqared
func_r_squared <- function(x) {
  substract1 <- glance(x)[c("r.squared")]
  substract1$r.squared
}

#Function for the adjusred r_sqared
func_adj_r_squared <- function(x) {
  substract2 <- glance(x)[c("adj.r.squared")]
  substract2$adj.r.squared
}

#Function for the sigma
func_sigma <- function(x) {
  substract3 <- glance(x)[c("sigma")]
  substract3$sigma
}

#Function for the f-statistic
func_statistic <- function(x) {
  substract4 <- glance(x)[c("statistic")]
  substract4$statistic
}

#Function for the f-statistic p-value
func_p_value <- function(x) {
  substract5 <- glance(x)[c("p.value")]
  substract5$p.value
}


#Function to check coefficients' p-values
P_value_Check <- function(x) {
  output <- vector(mode = "character", length(x))
  
  for (i in seq_along(x)) {
    statis <- broom::tidy(x[[i]])
    p_val <- statis[[5]]
    
    if (any(p_val > 0.05)) {
      output[i] <- ("Rejected")
    }
    else {
      output[i] <- ("Accepted")
    }
  }
  return(output)
}

#--------------------------------------------------------
# Specify empty variables
v_r_squared  <- vector(mode = "numeric", length(desired_length))
v_adj_r_squared  <- vector(mode = "numeric", length(desired_length))
v_sigma  <- vector(mode = "numeric", length(desired_length))
v_statistic  <- vector(mode = "numeric", length(desired_length))
v_p_value  <- vector(mode = "numeric", length(desired_length))
v_formula  <- vector(mode = "character", length(desired_length))
linear_models = list()

#___________________________________________

# GET MODELS FROM TRAINING DATASET 

# For loop for each vetor
for (i in seq_along(formulas)) {
  v_formula[i] <- formulas[[i]]
  linear_models[[i]] = lm(formulas[[i]], data = training_data)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}

# To Create the model:
coefficient <- P_value_Check(x = linear_models)
models_training <-
  data.frame(
    model_names,
    v_r_squared,
    v_adj_r_squared,
    v_sigma,
    v_statistic,
    v_p_value,
    coefficient,
    v_formula
  )
colnames(models_training) <-
  c(
    "model",
    "r.squared",
    "adj.r.squared",
    "sigma",
    "f.statistic",
    "f.stat.p_value",
    "Coefficients",
    "Formula"
  )

#___________________________________________

# GET MODELS FROM EDM TRAINING DATASET 

# For loop for each vetor
for (i in seq_along(formulas)) {
  v_formula[i] <- formulas[[i]]
  linear_models[[i]] = lm(formulas[[i]], data = training_data_edm)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}

# To Create the model: 
coefficient <- P_value_Check(x=linear_models)
models_edm<- data.frame(model_names,v_r_squared,v_adj_r_squared, v_sigma, v_statistic, v_p_value, coefficient, v_formula)
colnames(models_edm) <- c("model","r.squared", "adj.r.squared", "sigma", "f.statistic", "f.stat.p_value", "Coefficients", "Formula")

#___________________________________________

# GET MODELS FROM KPOP TRAINING DATASET 

# For loop for each vetor
for (i in seq_along(formulas)) {
  v_formula[i] <- formulas[[i]]
  linear_models[[i]] = lm(formulas[[i]], data = training_data_k_pop)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}

# To Create the model: 
coefficient <- P_value_Check(x=linear_models)
models_K_pop <- data.frame(model_names,v_r_squared,v_adj_r_squared, v_sigma, v_statistic, v_p_value, coefficient, v_formula)
colnames(models_K_pop) <- c("model","r.squared", "adj.r.squared", "sigma", "f.statistic", "f.stat.p_value", "Coefficients", "Formula")

#___________________________________________

# GET MODELS FROM HIP HOP TRAINING DATASET 

# For loop for each vetor
for (i in seq_along(formulas)) {
  v_formula[i] <- formulas[[i]]
  linear_models[[i]] = lm(formulas[[i]], data = training_data_hip_hop)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}
#--------------------------------------------------------------------------------
# For Create the model:
coefficient <- P_value_Check(x = linear_models)
models_hip_hop <-
  data.frame(
    model_names,
    v_r_squared,
    v_adj_r_squared,
    v_sigma,
    v_statistic,
    v_p_value,
    coefficient,
    v_formula
  )
colnames(models_hip_hop) <-
  c(
    "model",
    "r.squared",
    "adj.r.squared",
    "sigma",
    "f.statistic",
    "f.stat.p_value",
    "Coefficients",
    "Formula"
    
  )

#___________________________________________

# CREATE TABLE WITH BEST 12 MODELS (3 OF EACH TRAINING DATASET)

# generate top 3 models in training dataset
training_models <- models_training %>%
  filter(Coefficients == "Accepted") %>%
  slice_max(adj.r.squared, n = 3)

# generate top 3 models in edm dataset
edm_models <- models_edm %>%
  filter(Coefficients == "Accepted") %>%
  slice_max(adj.r.squared, n = 3)

# generate top 3 models in k-pop dataset
k_pop_models <- models_K_pop %>%
  filter(Coefficients == "Accepted") %>%
  slice_max(adj.r.squared, n = 3)

# generate top 3 models in hip hop dataset
hip_hop_models <- models_hip_hop %>%
  filter(Coefficients == "Accepted") %>%
  slice_max(adj.r.squared, n = 3)

# combine all models together as dataframe
all_training_data_models <-
  rbind(training_models, edm_models, k_pop_models, hip_hop_models)

# rename the model columns
all_training_data_models$model <-
  c(
    "model_1",
    "model_2",
    "model_3",
    'model_4',
    "model_5",
    "model_6",
    "model_7",
    "model_8",
    "model_9",
    "model_10",
    "model_11",
    "model_12"
  )
all_training_data_models

#___________________________________________

#CREATING VARIABLES FOR EACH MODEL

#variables models training_data
model_1 <- lm(formulas[[505]], data = training_data)
model_2 <- lm(formulas[[510]], data = training_data)
model_3 <- lm(formulas[[497]], data = training_data)
model_4 <- lm(formulas[[399]], data = training_data_edm)
model_5 <- lm(formulas[[46]], data = training_data_edm)
model_6 <- lm(formulas[[344]], data = training_data_edm)
model_7 <- lm(formulas[[258]], data = training_data_k_pop)
model_8 <- lm(formulas[[130]], data = training_data_k_pop)
model_9 <- lm(formulas[[133]], data = training_data_k_pop)
model_10 <- lm(formulas[[505]], data = training_data_hip_hop)
model_11 <- lm(formulas[[479]], data = training_data_hip_hop)
model_12 <- lm(formulas[[497]], data = training_data_hip_hop)

#variables models quary_data
model_1_1 <- lm(formulas[[505]], data = query_data)
model_2_1 <- lm(formulas[[510]], data = query_data)
model_3_1 <- lm(formulas[[497]], data = query_data)
model_4_1 <- lm(formulas[[399]], data = query_data_edm)
model_5_1 <- lm(formulas[[46]], data = query_data_edm)
model_6_1 <- lm(formulas[[344]], data = query_data_edm)
model_7_1 <- lm(formulas[[258]], data = query_data_k_pop)
model_8_1 <- lm(formulas[[130]], data = query_data_k_pop)
model_9_1 <- lm(formulas[[133]], data = query_data_k_pop)
model_10_1 <- lm(formulas[[505]], data = query_data_hip_hop)
model_11_1 <- lm(formulas[[479]], data = query_data_hip_hop)
model_12_1 <- lm(formulas[[497]], data = query_data_hip_hop)

#variables model test_data
model_5_2 <- lm(formulas[[46]], data = test_data_edm)

#___________________________________________

# PLOT TO CHECK THE RESIDUALS
#Plot Residuals Function
plot_residuals <- function(x, y = "Model") {
  ggplot(data = x, aes(x = .fitted, y = .resid)) +
    geom_point(alpha = 0.3) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    xlab("Fitted Values") +
    ylab("Residuals") +
    ggtitle(y) +
    theme(plot.title = element_text(
      hjust = 0.5,
      size = 12,
      face = "bold"
    ))
}

#Assignning the models residuals to a plot
residuals1 <- plot_residuals(x = model_1, y = "Model 1")
residuals2 <- plot_residuals(x = model_2, y = "Model 2")
residuals3 <- plot_residuals(x = model_3, y = "Model 3")
residuals4 <- plot_residuals(x = model_4, y = "Model 4")
residuals5 <- plot_residuals(x = model_5, y = "Model 5")
residuals6 <- plot_residuals(x = model_6, y = "Model 6")
residuals7 <- plot_residuals(x = model_7, y = "Model 7")
residuals8 <- plot_residuals(x = model_8, y = "Model 8")
residuals9 <- plot_residuals(x = model_9, y = "Model 9")
residuals10 <- plot_residuals(x = model_10, y = "Model 10")
residuals11 <- plot_residuals(x = model_11, y = "Model 11")
residuals12 <- plot_residuals(x = model_12, y = "Model 12")

#display the residuals together.
grid.arrange(
  residuals1,
  residuals2,
  residuals3,
  residuals4,
  residuals5,
  residuals6,
  residuals7,
  residuals8,
  residuals9,
  residuals10,
  residuals11,
  residuals12,
  ncol = 3
)

#___________________________________________

#SUBSET FORMULAS BASED ON THE CHOSEN MODELS

formulas1 <- formulas[c(505, 510, 497)]
formulas2 <- formulas[c(399, 46, 344)]
formulas3 <- formulas[c(258, 130, 133)]
formulas4 <- formulas[c(505, 479, 497)]

#creating a new length for vectors
desired_length2 <- c(1:3)

#___________________________________________

#CREATING THE DIFFERENT MODELS BUT FOR ALL QUERY DATA

#Create empty vector for the names of each model.
model_names <- vector(mode = "character", length(desired_length2))

# For loop to add the names of each model
for (i in seq_along(desired_length2)) {
  model_names[i] <- str_c("model", desired_length2[i])
}

# Specify empty variables for query data
v_r_squared  <- vector(mode = "numeric", length(formulas1))
v_adj_r_squared  <- vector(mode = "numeric", length(formulas1))
v_sigma  <- vector(mode = "numeric", length(formulas1))
v_statistic  <- vector(mode = "numeric", length(formulas1))
v_p_value  <- vector(mode = "numeric", length(formulas1))
v_formula  <- vector(mode = "character", length(formulas1))
linear_models = list()

# Run loop to apply new values to the empty vectors
for (i in seq_along(formulas1)) {
  v_formula[i] <- formulas1[[i]]
  linear_models[[i]] = lm(formulas1[[i]], data = query_data)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}

# Create the model:
coefficient <- P_value_Check(x = linear_models)
models_query <-
  data.frame(
    model_names,
    v_r_squared,
    v_adj_r_squared,
    v_sigma,
    v_statistic,
    v_p_value,
    coefficient,
    v_formula
  )
colnames(models_query) <-
  c(
    "model",
    "r.squared",
    "adj.r.squared",
    "sigma",
    "f.statistic",
    "f.stat.p_value",
    "Coefficients",
    "Formula"
  )

#Checking the results with the highest adjusted-Rsquared
models_query


#___________________________________________

#CREATING THE DIFFERENT MODELS BUT FOR EDM QUERY DATA

#Create empty vector for the names of each model.
model_names <- vector(mode = "character", length(desired_length2))

# For loop to add the names of each model
model_names <- c("Model_4", "Model_5", "Model_6")

# Specify empty variables for test data
v_r_squared  <- vector(mode = "numeric", length(desired_length2))
v_adj_r_squared  <- vector(mode = "numeric", length(desired_length2))
v_sigma  <- vector(mode = "numeric", length(desired_length2))
v_statistic  <- vector(mode = "numeric", length(desired_length2))
v_p_value  <- vector(mode = "numeric", length(desired_length2))
v_formula  <- vector(mode = "character", length(desired_length2))
linear_models = list()

# Run loop to apply new values to the empty vectors
for (i in seq_along(formulas2)) {
  v_formula[i] <- formulas2[[i]]
  linear_models[[i]] = lm(formulas2[[i]], data = query_data_edm)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}

# Create the model:
coefficient <- P_value_Check(x = linear_models)
models_query_EDM <-
  data.frame(
    model_names,
    v_r_squared,
    v_adj_r_squared,
    v_sigma,
    v_statistic,
    v_p_value,
    coefficient,
    v_formula
  )
colnames(models_query_EDM) <-
  c(
    "model",
    "r.squared",
    "adj.r.squared",
    "sigma",
    "f.statistic",
    "f.stat.p_value",
    "Coefficients",
    "Formula"
  )

#Checking the results with the highest adjusted-Rsquared
models_query_EDM

#___________________________________________

#CREATING THE DIFFERENT MODELS BUT FOR KPOP QUERY DATA

#Create empty vector for the names of each model.
model_names <- vector(mode = "character", length(desired_length2))

# For loop to add the names of each model
model_names <- c("Model_7", "Model_8", "Model_9")

# Specify empty variables for query data
v_r_squared  <- vector(mode = "numeric", length(desired_length2))
v_adj_r_squared  <- vector(mode = "numeric", length(desired_length2))
v_sigma  <- vector(mode = "numeric", length(desired_length2))
v_statistic  <- vector(mode = "numeric", length(desired_length2))
v_p_value  <- vector(mode = "numeric", length(desired_length2))
v_formula  <- vector(mode = "character", length(desired_length2))
linear_models = list()

# Run loop to apply new values to the empty vectors
for (i in seq_along(formulas3)) {
  v_formula[i] <- formulas3[[i]]
  linear_models[[i]] = lm(formulas3[[i]], data = query_data_k_pop)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}

# Create the model:
coefficient <- P_value_Check(x = linear_models)
models_query_K_pop <-
  data.frame(
    model_names,
    v_r_squared,
    v_adj_r_squared,
    v_sigma,
    v_statistic,
    v_p_value,
    coefficient,
    v_formula
  )
colnames(models_query_K_pop) <-
  c(
    "model",
    "r.squared",
    "adj.r.squared",
    "sigma",
    "f.statistic",
    "f.stat.p_value",
    "Coefficients",
    "Formula"
  )

#Checking the results with the highest adjusted-Rsquared
models_query_K_pop

#___________________________________________

#CREATING A TABLE WITH ALL NEW MODELS STATISTICS WITH QUERY DATA

#Create empty vector for the names of each model.
model_names <- vector(mode = "character", length(desired_length2))

# For loop to add the names of each model
model_names <- c("Model_10", "Model_11", "Model_12")

# Specify empty variables for query data
v_r_squared  <- vector(mode = "numeric", length(desired_length2))
v_adj_r_squared  <- vector(mode = "numeric", length(desired_length2))
v_sigma  <- vector(mode = "numeric", length(desired_length2))
v_statistic  <- vector(mode = "numeric", length(desired_length2))
v_p_value  <- vector(mode = "numeric", length(desired_length2))
v_formula  <- vector(mode = "character", length(desired_length2))
linear_models = list()

# Run loop to apply new values to the empty vectors
for (i in seq_along(formulas4)) {
  v_formula[i] <- formulas4[[i]]
  linear_models[[i]] = lm(formulas4[[i]], data = query_data_hip_hop)
  v_r_squared[i] <- (func_r_squared(linear_models[[i]]))
  v_adj_r_squared[i] <- (func_adj_r_squared(linear_models[[i]]))
  v_sigma[i] <- (func_sigma(linear_models[[i]]))
  v_statistic[i] <- (func_statistic(linear_models[[i]]))
  v_p_value[i] <- (func_p_value(linear_models[[i]]))
}

# Create the model:
coefficient <- P_value_Check(x = linear_models)
models_query_hip_hop <-
  data.frame(
    model_names,
    v_r_squared,
    v_adj_r_squared,
    v_sigma,
    v_statistic,
    v_p_value,
    coefficient,
    v_formula
  )
colnames(models_query_hip_hop) <-
  c(
    "model",
    "r.squared",
    "adj.r.squared",
    "sigma",
    "f.statistic",
    "f.stat.p_value",
    "Coefficients",
    "Formula"
  )

#Checking the results with the highest adjusted-Rsquared
models_query_hip_hop

#___________________________________________

#CREATING THE DIFFERENT MODELS BUT FOR HIPHOP QUERY DATA

# combine all models together as dataframe
all_quary_data_models <-
  rbind(models_query,
        models_query_EDM,
        models_query_K_pop,
        models_query_hip_hop)

# rename the model columns
all_quary_data_models$model <-
  c(
    "model_1_1",
    "model_2_1",
    "model_3_1",
    'model_4_1',
    "model_5_1",
    "model_6_1",
    "model_7_1",
    "model_8_1",
    "model_9_1",
    "model_10_1",
    "model_11_1",
    "model_12_1"
  )
all_quary_data_models

#___________________________________________

#TESTING THE CHOSEN MODELS WITH TEST DATA

#Get specific data on the regression
test_model <- glance(model_5_2)[1:5]
names(test_model)[4] <- "f.statistic"
names(test_model)[5] <- "f.stat.p_value"

#Running the coefficient p-value test
p_values_test <- broom::tidy(model_5_2)[5]
output2 <- vector(mode = "character", length = 1)

#if statement for test
if (any(p_values_test > 0.05)) {
  output2 <- ("Rejected")
} else {
  output2 <- ("Accepted")
}

#Assign formula to vector for dataframe.
Formula <- c("popularity ~ danceability + energy + loudness")

#Create dataframe
test_model <- cbind(test_model, output2, Formula)

#Adjust columns names for consistancy
names(test_model)[names(test_model) == "output2"] <- "Coefficients"

#Display the Model
test_model

#___________________________________________

#CREATING THE EQUATION OF THE CHOSEN TEST MODEL 

#Equation
cat(
  "Popularity Score = ",
  coef(model_5_2)[1],
  "+ (",
  coef(model_5_2)[2],
  " * danceability ) + (",
  coef(model_5_2)[3],
  "* energy ) + (",
  coef(model_5_2)[4],
  "* loudness )"
)
