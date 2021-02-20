# R Spotify Data Analysis
## Creating Value for Music Artists in R Markdown

Sun, 20th Nov 2020 

This project focused on finding a problem, creating a hypothesis, collecting. The data, performing an exploratory data analysis and applying linear modelling to the data. This had to be done using R, writing a report in R markdown.

Collaborator: [Ruisheng Wang](https://github.com/rishonwang) 

The data used was downloaded on [Kaggle](https://www.kaggle.com/yamaerenay/spotify-dataset-19212020-160k-tracks) and was updated on November 25, 2020. Additional data was gathered through Spotify's Open-Source Developers Program.

---
### Framing the Problem
With 341 million paid subscribers, streaming accounted for 56 percent of the total music industry revenues in 2019. The trend started approximately in 2009 and has been growing since. The industry segment is forecasted to reach 1.3 billion users by 2030, of which 21% will be streaming music using their mobile phones (IFPI, 2020; Goldman Sachs, 2020).

We wanted to know whether a **song's popularity can be predicted based on song characteristics.** The more popularity a songs, the more penitential there is to generate revenue per stream for an artist on Spotify. A "popularity recipe" would help Spotify establish a better relationship with record labels and artists and listeners who want to have likable music.

### Exploratory Data Analysis

**1. How have the characteristics of music changed over the last ten years?** (Line-Chart)
- There are two characteristics: Speechiness and Danceability, that are increasing over the last decade.
- The Instrumentalness has a clear trend of decreasing.
- Acousticness and Energy have a trend showing a significant decrease in the range of 0.1 change during 2018 to 2019.
- Liveness is the only characteristic to be stable over the past decade.

**2. Are they any correlations between the variables?** (Pearson Correlation Matrix)
- A strong positive correlation between *Energy* and *Loudness* (+0.78).
- A moderate positive correlation between Danceability and Valence (+0.56).
- A moderate positive correlation between Popularity and Loudness (+0.46).
- A strong negative correlation between Acousticness and Energy (-0.75).
- A moderate negative correlation between Acousticness and Loudness (-0.56).
- A moderate negative correlation between Popularity and Acousticness (-0.57).

**3. What does it take to be in the top 200?** (Simple Linear regression, Density plot by Music genres)
- There are quite some variations in the top200 popularity score. With a threshold of a popularity score of 85, there are 41 outliers, which is approximately 20.5% of all data points.
- About 18% of all streaming numbers account for the popularity score (adjusted r-squared).
- Common characteristics for the top 200 songs include: a low acousticness score, a medium to high loudness score, a low speechness score, a low liveness score, and a medium to high danceability score.

**4. What defines the popular genres suggested by BBC?**
- Genres K-pop, Electronic Dance Music (EDM), and Hip Hop are in general more popular than African and Latin Pop. 
- Shared characteristics for these genres include; Energy, Danceability, Valence, Loudness

### Hypothesis 

H0: The characteristics (instrumentalness, acousticness, liveness, dancability, energy, loudness, speechness, valence, tempo) of the genres “K-pop”, “Hip Hop”, and “Electronic Dance Music” are not statistically significantly related to song popularity score.*

HA: The characteristics (acousticness, liveness, dancability, energy, loudness, speechness, valence, tempo) of the genres “K-pop”, “Hip Hop”, and “Electronic Dance Music” are statistically significantly related to song popularity score.

### Linear Modelling 

The data used for modelling does not have any clear linear patterns with the popularity score, indicating that the relationship between our dependent and independent variables is mostly non-linear. This has to be taken into account when fitting the best model.

| R.squared  | adj.r.squared |   sigma  |f.statistic | f.stat.p_value | Coefficients | Formula       |
|------------| -------------:|---------:|-----------:|---------------:|-------------:| -------------:|
|  0.2061116 |  0.1982253    | 11.00121 | 26.13537	 | 4.66821e-15    |	 Accepted    | 	popularity ~ danceability + energy + loudness |

This model suggest the following equation: *Popularity Score =  74.98355 + ( 19.35758  * danceability ) + ( -20.35282 * energy ) + ( 2.066039 * loudness )*

Based on the different models chosen, it can be concluded that the null hypothesis cannot be rejected, even with the best fitted model.

### Insights
- Popular music genres do not necessarily have similar characteristics.
- Other factors might influence the popularity score.
- Spotify can use its data to identify trends rather than predicting the popularity score.

### Further Research 
As there are no strong linear patterns for this dataset, which can be seen in the scatterplots and correlation matrix, there are plenty of possibilities to move further with this research. Different genres could be analyzed to see whether more vital models can be created to predict the popularity score.

Another possibility is to apply a transformation to the popularity score or song characteristics to make the data more fitted to linear regression. There might also be better predictive (machine learning) models that fit the data better than a linear model. These might give us different insights.
