# R Spotify Data Analysis
## Creating Value for Music Artists in R Markdown

Sun, 20th Nov 2020 

This project focussed on applying finding a problem, creating a hypothesis, collecting.  the data, performing an exploratory data analysis, and applying linear modelling to the data. This had to be done using R, writing a report in R markdown. 

Collaborator: [Ruisheng Wang](https://github.com/rishonwang) 

The data used was downloaded on [Kaggle](https://www.kaggle.com/yamaerenay/spotify-dataset-19212020-160k-tracks) and was updated on the November 25, 2020.
Additional Data was gathered through Spotify's Open Source Developers Program.

---
### Framing the Problem

The music industry is a booming business. In 2019, the total revenue of the music industry amounted to 21.5 billion U.S. dollars and is predicted to grow to 36.7 billion U.S. dollars by 2025 [(IFPI, 2020;](https://www.ifpi.org/wp-content/uploads/2020/07/Global_Music_Report-the_Industry_in_2019-en.pdf) [Koronios, 2020)](https://my-ibisworld-com.hult.idm.oclc.org/gl/en/industry/q8712-gl/industry-performance).

With 341 million paid subscribers, streaming accounted for 56 percent of the total music industry revenues in 2019. The trend started approximately in 2009 and has been growing since. The industry segment is forecasted to reach 1.3 billion users by 2030, of which 21% will be streaming music using their mobile phones (IFPI, 2020; Goldman Sachs, 2020).


### Exploratory Data Analysis

### Hypothesis 

H0: The characteristics (instrumentalness, acousticness, liveness, dancability, energy, loudness, speechness, valence, tempo) of the genres “K-pop”, “Hip Hop”, and “Electronic Dance Music” are not statistically significantly related to song popularity score.*

HA: The characteristics (acousticness, liveness, dancability, energy, loudness, speechness, valence, tempo) of the genres “K-pop”, “Hip Hop”, and “Electronic Dance Music” are statistically significantly related to song popularity score.

