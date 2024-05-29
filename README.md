# Quak-ImproveYourSelfesteem

## Purpose
An R shiny app for users with low self-esteem based on the treatment for negative self-image by Manja de Neef (2022; https://www.negatiefzelfbeeldbehandelen.nl/). Users are asked about their current negative self-image and will be asked to formulate a desired positive self-image. They will be asked weekly to rate how likely they perceive their desired positive self-image to be true and the results graphed. To improve self-esteem, users are asked to log their positive experiences/things they did well that day in a whitebook, how these experiences made them feel, and are asked what these positive experiences tell them about themselves/what positive character traits they can attach to them. In the app they can see which positive traits keep repeating in their whitebook, which might tell the users something about the positive traits they themselves possess. 

## Task description

### Purpose
Scenario describes the first use of the self-esteem app by someone who suffers from low self-esteem

### Individual
English-speaking adult A who suffers from low self-esteem [app possibly used in combination with therapy]

### Equipment
Computer with R installed and the following R packages: devtools, shiny, wordcloud, dplyr, markdown, readr, DT, bslib, ggplot2.

### Scenario: 
1. Individual A starts up R/R studio and 
2. Individual A runs the R shiny self-esteem app for the first time
3. Self-esteem app window pops up
4. Individual A is shown a modal window with an explanation about the app and is asked a few questions
5. Individual A answers questions and navigates to the next part using the “ok” button
6. Modal window closes and Individual A is shown the main page, loading the "introduction" subtab, which shows the introduction text again.
7. Individual A navigates the pages using the tab buttons. At the moment, individual A is shown the introduction page
8. Individual A navigates to the "whitebook" tab, subtab "new entry" .
9. Individual A reads the explanation and inputs a few entries into the whitebook
10. Individual A observes their entries in the "view entries" subtab
11. Individual A looks at a wordcloud of their entered positive traits in the wordcloud subtab.
12. Individual A goes to tab "Positive self-image", subtab "new entry" and rates their belief in their desired positive self-image.
13. Individual A goes to subtab “Progress graph” to watch how their belief in their positive self-image has shifted over time.

## Flowchart
![Flowchart starting up the app](ImproveYourSelfesteem/inst/images/Flowchart_run_app.png)