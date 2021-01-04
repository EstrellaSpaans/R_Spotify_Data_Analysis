# R Spotify Data Analysis
## Creating Value for Music Artists in R Markdown

Sun, 20th Nov 2020 

This project focussed on applying finding a problem, creating a hypothesis, collecting.  the data, performing an exploratory data analysis, and applying linear modelling to the data. This had to be done using R, writing a report in R markdown. 

Collaborator: [Ruisheng Wang](https://github.com/rishonwang) 

The data used was downloaded on [Kaggle](https://www.kaggle.com/yamaerenay/spotify-dataset-19212020-160k-tracks) and was updated on the November 25, 2020.
Additional Data was gathered through Spotify's Open Source Developers Program.

---
### Framing the Problem
With 341 million paid subscribers, streaming accounted for 56 percent of the total music industry revenues in 2019. The trend started approximately in 2009 and has been growing since. The industry segment is forecasted to reach 1.3 billion users by 2030, of which 21% will be streaming music using their mobile phones (IFPI, 2020; Goldman Sachs, 2020).

However, Artist upset with the current climate of streaming platforms. They claim that; 
- streaming platforms are destroying album sales. 
- can generate more revenue from selling albums (digitally or physically)
- revenue per stream is incredibaly low (on average $1.70)

Spotify, one of the streaming platforms, has to deal with their stakeholders’ dissatisfaction (artists), as they are interested in building good relationships. Without artists and listeners, the business model would fail.That is why we wanted to know whether **the popularity of a song can be predicted based on song characteristics**. More popularity a songs, the more potentential there is to generate revenue per stream. A " popularity recipe " would help Spotify establish a better relationship with record labels and artists and listeners who want to have likable music.

### Exploratory Data Analysis

**1. How have the characteristics of music changed over the last ten years?** (Line-Chart)
- There are two characteristics: *Speechiness* and *Danceability*, that are increasing over the last decade.
- The *Instrumentalness* has a clear trend of decreasing.
- There are four characteristics that are fluctuating with changes of 0.1.
    - Both *Energy* and *Valence* show a positive change after 2016 to 2017.
    - *Acousticness* and *Energy* have a trend showing a significant decrease within the range of 0.1 change during the year of 2018 to 2019.
- *Liveness* is the only characteristic to be stable over the past decade.

**2. Are they any correlations between the variables?** (Pearson Correlation Matrix)
- A strong positive correlation between *Energy* and *Loudness* (+0.78).
- A moderate positive correlation between Danceability and Valence (+0.56).
- A moderate positive correlation between Popularity and Loudness (+0.46).
- A strong negative correlation between Acousticness and Energy (-0.75).
- A moderate negative correlation between Acousticness and Loudness (-0.56).
- A moderate negative correlation between Popularity and Acousticness (-0.57).

**3. What does it take to be in the top 200?** (Simple Linear regression, Density plot by Music genres)
- There are quite some variations in the top200 popularity score. With a threshold of a popularity score of 85, there are 41 outliers, which is approximately 20.5% of all data points.
- approximately 18% of all streaming numbers account for the popularity score (adjusted r-squared). 
- Common characteristics for the top 200 songs include low acousticness score, a medium to high loudness score, a low speechness score, a low liveness score, and a medium to high danceability score.

**4. What defines the popular genres suggested by BBC?**
- Genres K-pop, Electronic Dance Music (EDM), and Hip Hop are in general more popular than African and Latin Pop. 
- Shared characteristics for these genres include ; Energy, Danceability, Valence, Loudness

### Hypothesis 

H0: The characteristics (instrumentalness, acousticness, liveness, dancability, energy, loudness, speechness, valence, tempo) of the genres “K-pop”, “Hip Hop”, and “Electronic Dance Music” are not statistically significantly related to song popularity score.*

HA: The characteristics (acousticness, liveness, dancability, energy, loudness, speechness, valence, tempo) of the genres “K-pop”, “Hip Hop”, and “Electronic Dance Music” are statistically significantly related to song popularity score.

### Linear Modelling 

The data used for modelling does not have any clear linear patterns with the popularity score, indicating that the relationship between our dependent and independent variables is mostly non-linear. This has to be taken into account when fitting the best model.

The approach that was taken was to test all possible combinations of all the characteristics. This had let to the creation of 511 different combinations. For all of these combinations, it was needed to test four different datasets: the training data and the training data set split by each genre. The 12 best models were chosen from all combinations. 

- *Training Data Set:* Model 1, Model 2, Model 3
- *EDM Training Data:* Model 4, Model 5, Model 6
- *K-Pop Training Data:* Model 7, Model 8, Model 9
- *Hip Hop Training Data:* Model 10, Model 11, Model 12

The models were then tested again with the dataset query_data, to discover only that model 5 and 11 are acceptable models; 
- Model 5 indicates that danceability, energy, and loudness influence the popularity score of Electronic Dance Music.
- Model 11 has more characteristics that influence the popularity score for hip hop; the only characteristic that is not included is speechiness.

#### Best Model
</table><table cellspacing="0" class="table table-condensed"><thead><tr><th align="right" style="text-align: right; max-width: 90px; min-width: 90px;"><div class="pagedtable-header-name">r.squared</div><div class="pagedtable-header-type">&lt;dbl&gt;</div></th><th align="right" style="text-align: right; max-width: 130px; min-width: 130px;"><div class="pagedtable-header-name">adj.r.squared</div><div class="pagedtable-header-type">&lt;dbl&gt;</div></th><th align="right" style="text-align: right; max-width: 80px; min-width: 80px;"><div class="pagedtable-header-name">sigma</div><div class="pagedtable-header-type">&lt;dbl&gt;</div></th><th align="right" style="text-align: right; max-width: 110px; min-width: 110px;"><div class="pagedtable-header-name">f.statistic</div><div class="pagedtable-header-type">&lt;dbl&gt;</div></th><th align="right" style="text-align: right; max-width: 140px; min-width: 140px;"><div class="pagedtable-header-name">f.stat.p_value</div><div class="pagedtable-header-type">&lt;dbl&gt;</div></th><th align="left" style="text-align: left; max-width: 120px; min-width: 120px;"><div class="pagedtable-header-name">Coefficients</div><div class="pagedtable-header-type">&lt;fctr&gt;</div></th><th style="cursor: pointer;vertical-align: middle;min-width: 5px;width: 5px;"><div style="border-top: 5px solid transparent;border-bottom: 5px solid transparent;border-left: 5px solid;"></div></th></tr></thead><tbody><tr class="odd"><td align="right" style="text-align: right; max-width: 90px; min-width: 90px;">0.2061116</td><td align="right" style="text-align: right; max-width: 130px; min-width: 130px;">0.1982253</td><td align="right" style="text-align: right; max-width: 80px; min-width: 80px;">11.00121</td><td align="right" style="text-align: right; max-width: 110px; min-width: 110px;">26.13537</td><td align="right" style="text-align: right; max-width: 140px; min-width: 140px;">4.66821e-15</td><td align="left" style="text-align: left; max-width: 120px; min-width: 120px;">Accepted</td><td></td></tr></tbody></table>



