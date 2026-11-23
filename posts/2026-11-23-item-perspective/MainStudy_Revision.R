rm(list = ls())

# Load packages
library(tidyverse)
library(ggExtra)
library(gridExtra)

#' **Note:** You'll need to change the working directory to where you've stored the csv files.
# setwd("path/to/your/directory")


#' # Code book
#' The datasets can be downloaded from https://osf.io/5ahzj/.
#' 
#' In `dat` (`DataGermanArticles_15Aug2016.csv`);
#' 
#' * `rt`: Response latency in milliseconds.
#' * `trial_type`: A remnant of using `jsPsych` to collect the data.
#' * `trial_index`: The position of the stimulus in the task. This includes consent forms, instructions and the like.
#' * `time_elapsed`: Milliseconds elapsed since the beginning of the task.
#' * `SubjectID`: A randomly generated participant ID.
#' * `Stimulus`: The item presented.
#' * `button_pressed`: The button the participant pressed (left-most = 0). What this button represents depends on the precise task, see below.
#' * `PartExperiment`: This file contains data for all tasks (perceived L1 use, own L1 use, L2 gender assignments); this column species which part the entry belongs to.
#' 
#' In `questionnaire` (`Questionnaires_GermanArticles.csv`):
#' 
#' * `SubjectID`: Same as above.
#' * `Sex`.
#' * `Age` in years.
#' * `NativeLanguage`: `mono-Dutch` = only Dutch as a native language; `bi-Dutch` = Dutch as one of at least two native languages; `other` = another native language.
#' * `NativeLanguage2`: Specifies any other native language the participant speaks if bilingual.
#' * `OtherNativeLanguage`: Specifies any other native language the participant speaks if not Dutch.
#' * `Country`: Country code of country where the participant grew up.
#' * `Town` where the participant grew up.
#' * `KnowledgeDialect`: Can the participant speak a dialect (`ja` = yes; `nee` = no).
#' * `UseDialect`: If the participant can speak a dialect, how often do they speak it? (0 = never; 1 = rarely; 2 = occasionally; 3= often; 4 = always; NA for participants who donât speak a dialect.)
#' * `Tussentaal`: For participants who grew up in Belgium: how often do they speak tussentaal? (0 = never; 1 = rarely; 2 = occasionally; 3= often; 4 = always; NA for participants who didn't grow up in Belgium.)
#' * `German`: Self-assessed conversational skills in German on CEFR grid. Include an `A0` level to describe no skills.
#' * `GermanClass`: Did the participant take German classes, e.g. in school or at university. (`ja` = yes; `nee` = no)
#' 
#' # Read in, combine and clean datasets
# Read in the task data
dat <- read.csv("DataGermanArticles_15Aug2016.csv")
# summary(dat) # uncomment to check the structure of this dataset

# Change the column names "stimulus" to "Stimulus" (capital letter).
# (This makes life easier later.)
colnames(dat)[6] <- "Stimulus"

# Read in questionnaire data
questionnaire <- read.csv("Questionnaires_GermanArticles.csv")
# Remove double entries due to server lag
questionnaire <- unique(questionnaire)
# summary(questionnaire) # uncomment to check the structure of this dataset
#' Questionnaire data are available for 223 participants.
nrow(questionnaire) # 223 rows

# Combine questionnaire data with dat
dat <- merge(dat, questionnaire, by = "SubjectID")
#' Questionnaire _and_ task data are available for 199 participants (some task data wasn't saved to the server; I fixed this problem once I noticed it.)
# dat$SubjectID %>% unique() %>% length() # data available for 199 participants, uncomment to verify

#' 5 participants didn't consider Dutch to be their native language.
dat <- dat %>%
  filter(NativeLanguage != "other") %>%
  droplevels()
# dat$SubjectID %>% unique() %>% length() # 194 participants; 5 removed, uncomment to verify

#' 3 participants didn't hail from Belgium or the Netherlands.
dat <- dat %>%
  filter(Country %in% c("BE", "NL")) %>%
  droplevels()
# dat$SubjectID %>% unique() %>% length() # 191 participants; 3 removed, uncomment to verify

#' One participant considered themselves to be bilingual in Dutch and German.
# table(dat$NativeLanguage2)/92 # one participant ("duits"), uncomment to verify
dat <- dat %>%
  filter(NativeLanguage2 != "duits" | is.na(NativeLanguage2)) %>%
  droplevels()
# dat$Subject %>% unique() %>% length() # 190 participants; 1 removed, uncomment to verify

#' All in all, questionnaire and task data are available for 190 eligible participants.
#' 
#' # Standard Dutch gender knowledge
#' Did the participants respond correctly to the 20 Standard Dutch noun phrases 
#' (i.e., reject the incorrect ones and accept the correct ones)?
#' As per the preregistration, participants that got fewer than 18/20 correct were removed from the dataset.

# Retain data for L1 Perceived Use task: Is this NP common? 
# Options: Yes everywhere; only in Flanders; nowhere.
percuse <- dat %>%
  filter(PartExperiment == "DutchArticlesUsual") %>%
  droplevels()
# nrow(percuse) # 6460 responses, i.e. 34 per Participant, uncomment to verify

# Read in info stimuli
percusestimuli <- read.csv("DutchStimuli.csv")

# Combine data with info stimuli
percuse <- merge(percuse, percusestimuli, by = "Stimulus")

# Set CorrectResponse as factor
percuse$CorrectResponse <- factor(percuse$CorrectResponse)

# Restrict data to stimuli testing Standard Dutch (categories 1 through 4) (20 stimuli in total)
percuse_standard <- percuse %>%
  filter(Category %in% c(1, 2, 3, 4)) %>%
  droplevels()

# See whether responses were correct
percuse_standard$Correct <- percuse_standard$button_pressed == percuse_standard$CorrectResponse

# Compute number of correct responses per participant
percuse_standard_perParticipant <- percuse_standard %>%
  group_by(SubjectID) %>%
  summarise(L1Correct = sum(Correct),
            n = n())

# Add this to dat
dat <- merge(dat, percuse_standard_perParticipant, by = "SubjectID")

# Kick out participants with fewer than 18 correct answers
dat2 <- dat %>%
  filter(L1Correct >= 18) %>%
  droplevels()

#' Out of the 190 participants retained above, 175 had >=18/20 responses on Standard Dutch stimuli,
#' i.e. 15 participants will be dropped from the dataset.
# dat2$SubjectID %>% unique() %>% length() # 175 participants remaining (15 dropped), uncomment to verify

# Retain only questionnaire data for those whose task data were saved
questionnaire <- questionnaire %>%
  filter(SubjectID %in% dat2$SubjectID) %>%
  droplevels()


#' # Knowledge of L2 German gender
#' How often did the participants assign the correct German gender to the 15 nouns whose Dutch cognates are neuter?
#' By guessing or by consistently choosing _das_, a score of 5/15 is expected.

# Retain data for L2 gender assignments
germanarticles <- dat2 %>%
  filter(PartExperiment == "GermanArticles") %>%
  droplevels()
nrow(germanarticles) # 7700, i.e. 44 responses per participants

# Add info stimuli
L2stimuli <- read.csv("GermanStimuli_Revision.csv")
L2stimuli$CorrectResponse <- factor(L2stimuli$CorrectResponse)
germanarticles <- merge(germanarticles, L2stimuli, by = "Stimulus")

# Restrict analysis to neuter
DutchNeuter <- germanarticles %>%
  filter(DutchSDGender == "neuter") %>%
  droplevels()
DutchNeuter$Correct <- DutchNeuter$button_pressed == DutchNeuter$CorrectResponse

# L2 gender knowledge indicator: number of correct responses per participant
DutchNeuter_perParticipant <- DutchNeuter %>%
  group_by(SubjectID, Country) %>%
  summarise(L2Index = sum(Correct),
            n = n())

# Average per country:
DutchNeuter_perParticipant <- DutchNeuter %>% 
  group_by(SubjectID, Country, German) %>% 
  summarise(L2Index = sum(Correct),
            n = n())

#' ## Figure 2a: Distribution of self-assessed German CEFR levels per country
# Get number of participants at each self-assessment level per country:
selfassessments <- DutchNeuter_perParticipant %>%
  group_by(Country, German) %>%
  summarise(n = n())

# Express as proportions (i.e., divide by 71 for BE and by 104 for NL)
selfassessments$p <- ifelse(selfassessments$Country == "BE", selfassessments$n / 71, selfassessments$n / 104)

# Rename BE and NL
levels(selfassessments$Country) <- c("BE", "NL")


# Redo without Country info:
DutchNeuter_perParticipant <- DutchNeuter %>%
  group_by(SubjectID) %>%
  summarise(L2Index = sum(Correct))

# Add to dat2
dat2 <- merge(dat2, DutchNeuter_perParticipant, by = "SubjectID")

#' Exclude responses with very fast response latencies (< 500 ms), as per the preregistration.
dat3 <- dat2 %>%
  filter(rt > 500) %>%
  droplevels()

#' Less than 1% of data lost due to this overall.
1-nrow(dat3)/nrow(dat2)

#' # Knowledge of substandard Dutch gender
#' Belgian participants should have greater knowledge of substandard Belgian Dutch gender marking than Dutch participants,
#' i.e. they should have more correct answers in the 'perceived use' task for stimulus categories 5 and 6.

# Restrict analysis to Perceived Use task
percuse <- dat3 %>%
  filter(PartExperiment == "DutchArticlesUsual") %>%
  droplevels()
nrow(percuse) # 5948 observations retained

# size original dataset (5950):
dat2 %>% filter(PartExperiment == "DutchArticlesUsual") %>% droplevels() %>% nrow()

# Add info stimuli
percusestimuli <- read.csv("DutchStimuli.csv")
percuse <- merge(percuse, percusestimuli, by = "Stimulus")

# Only categories 5 and 6 are relevant
percuse56 <- percuse %>%
  filter(Category %in% c(5, 6)) %>%
  droplevels()
nrow(percuse56) # 1050

# See if correct
percuse56$Correct <- as.character(percuse56$button_pressed) == as.character(percuse56$CorrectResponse)

# Tabulate by Country
percuse56 %>% xtabs(~ Country + Correct, .) %>% prop.table(., 1)
# 72 vs. 47% correct overall (BE vs. NL)

# Compute per participant
percuse56_perParticipant <- percuse56 %>%
  group_by(SubjectID, Country) %>%
  summarise(CorrectFlemish = mean(Correct),
            nCorrectFlemish = sum(Correct),
            n = n())

# Average number of correct responses per country
percuse56_perParticipant %>%
  group_by(Country) %>%
  summarise(MeanSubL1 = mean(nCorrectFlemish),
            SDSubL1 = sd(nCorrectFlemish))


# Summarise responses per item
percuse56_item <- percuse56 %>% 
  group_by(Stimulus, Description, factor(button_pressed), Country) %>% 
  summarise(n = n())

# Rename column and recode factor levels:
colnames(percuse56_item)[3] <- "button_pressed"
levels(percuse56_item$button_pressed) <- c("everywhere", "Flanders only", "nowhere")

# Graph
#+ fig.width = 8, fig.height = 6
ggplot(percuse56_item,
       aes(x = n,
           y = Stimulus,
           shape = button_pressed)) +
  geom_point(size = 3) +
  facet_wrap(Description ~ Country, scales = "free_y") +
  scale_shape_discrete(solid = FALSE)

#' Dutch participants mostly got it wrong by claiming that _all_ NPs could occur in Flanders.
#' Belgian participants, too, but to a lesser extent.
#' 
#' ## Figure 3: Map with gender knowledge
#' Plot individual scores on map of Flanders and the Netherlands.
 
# Compute per participant
percuse56_perParticipant <- percuse56 %>%
  group_by(SubjectID, Country, Town) %>%
  summarise(CorrectFlemish = sum(Correct),
            n = n())

# # Get list of towns in sample
# # Only run this code if you want to redo all these steps.
# # I've saved the coordinates to an external file to move things along.
# Towns <- as.character(unique(percuse56_perParticipant$Town))
# Towns <- Towns[!is.na(Towns)] # one participant didn't list town
# 
# # Look up coordinates for each town.
# # This'll take a while.
# geocodes <- geocode(Towns)
# 
# # Gooise Meren not found. The main town in this municipality is Bussum:
# geocodes[Towns == "Gooise Meren",] <- geocode("Bussum")
# 
# # Plot coordinates:
# plot(geocodes, type = "n"); text(geocodes, Towns)
# 
# # Some of these automatically assigned coordinates are obviously wrong
# # and need to be corrected manually.
# # Westland (Naaldwijk)
# geocodes[Towns == "Westland",] <- geocode("Westland Naaldwijk")
# 
# # Essen (in Antwerp, not in Germany):
# geocodes[Towns == "Essen",] <- geocode("Essen (Antwerpen)")
# 
# # Haren (in Groningen, not in Germany):
# geocodes[Towns == "Haren",] <- geocode("Haren (Groningen)")
# 
# # Combine town names and coordinates
# df.towns <- data.frame(cbind(Towns, geocodes))
# # Write to disk
# write.csv(df.towns, "TownCoordinates.csv", row.names = FALSE)

# Read in coordinates
df.towns <- read.csv("TownCoordinates.csv")

# Combine coordinates with participants
percuse56_perParticipantTowns <- merge(percuse56_perParticipant, df.towns, by.x = "Town", by.y = "Towns")
#' Is Standard Dutch transfer observed?
#' Participants should be more prone to respond _das_ to stimuli with neuter Standard Dutch cognates than to stimuli with common-gender Standard Dutch cognates. 

# Restrict analysis to L2 assignment task
germart <- dat3 %>%
  filter(PartExperiment == "GermanArticles") %>%
  droplevels()
nrow(germart) # 7696 responses

# Add stimulus info
# The revised GermanStimuli.csv file contains English translations of the stimuli.
L2stimuli <- read.csv("GermanStimuli_Revision.csv")
germart <- merge(germart, L2stimuli, by = "Stimulus")

# Summarise by item by country
germart_perItem <- germart %>%
  group_by(Stimulus, Country) %>%
  summarise(NeuterResponses = mean(button_pressed == "2"))
germart_perItem <- merge(germart_perItem, L2stimuli, by = "Stimulus")

labels <- c(
  `BE` = "Belgium",
  `NL` = "The Netherlands"
)

# The next couple of lines sort the data so that they can be coded in a dotchart.
# Get proportion of neuter responses in BE, NL and total per item:
germart_perItem2 <- germart %>%
  group_by(Stimulus) %>%
  summarise(NeuterResponsesBelgium = mean(button_pressed[Country=="BE"] == "2"),
            NeuterResponsesNetherlands = mean(button_pressed[Country=="NL"] == "2"),
            NeuterResponsesTotal = (NeuterResponsesBelgium+NeuterResponsesNetherlands)/2)
# Combine this with earlier by-item summary
germart_perItem <- merge(germart_perItem, germart_perItem2)
# Sort by total proportion of neuter responses
germart_perItem <- arrange(germart_perItem, NeuterResponsesTotal)

# Create variable with labels (stimulus + translation)
germart_perItem$Label <- paste(germart_perItem$Stimulus,  " (", germart_perItem$Translation, ")", sep = "")

# Reorder the factor levels by the total proportion of neuter responses (rather than alphabetically).
germart_perItem$Stimulus <- reorder(germart_perItem$Stimulus, germart_perItem$NeuterResponsesTotal)
germart_perItem$Label <- reorder(germart_perItem$Label, germart_perItem$NeuterResponsesTotal)


# Rename levels
germart_perItem$Country <- as.factor(germart_perItem$Country)
levels(germart_perItem$Country) <- c("Belgium", "The Netherlands")
# Relevel Dutch gender
germart_perItem$DutchSDGender <- relevel(as.factor(germart_perItem$DutchSDGender), "neuter")
levels(germart_perItem$DutchSDGender) <- c("St. Du.: neuter", "St. Du: common")

# Add description of German gender (neuter vs. non-neuter)
germart_perItem$GermanNeuter <- factor(germart_perItem$GermanGender == "neuter",
                                       levels = c("TRUE", "FALSE"),
                                       labels = c("Gm.: neuter", "Gm.: non-neuter"))

#' ## Figure 5: Dotplot Standard Dutch influence
# Plot
# svg("StandardInfluence_Dotplot.svg", width = 4, height = 6)


ggplot(germart_perItem,
       aes(x = NeuterResponses,
           y = Label,
       shape = Country)) +
  geom_point() +
  scale_shape_manual(values = c(1, 3)) +
  #scale_colour_brewer(palette = "Set1") +
  guides(colour = guide_legend("Country"), 
         shape = guide_legend("Country")) +
  facet_grid(DutchSDGender + GermanNeuter~ ., scales = "free_y", drop = TRUE, space = "free_y") +
  theme_bw(8) +
  xlab("Proportion of neuter gender assignments ('das')\nin L2 German") +
  ylab("L2 German noun (English translation)") +
  theme(legend.direction = "vertical", 
        legend.position = c(0.8, 0.1))

germart_perPart <- germart |> 
  group_by(SubjectID, Country, GermanGender, DutchSDGender) |> 
  summarise(prop_neuter = mean(button_pressed == "2"),
            .groups = "drop")
germart_perPart$DutchSDGender <- relevel(as.factor(germart_perPart$DutchSDGender), "neuter")
levels(germart_perPart$DutchSDGender) <- c("St. Du.: neuter", "St. Du: common")

# Add description of German gender (neuter vs. non-neuter)
germart_perPart$GermanNeuter <- factor(germart_perPart$GermanGender == "neuter",
                                       levels = c("TRUE", "FALSE"),
                                       labels = c("Gm.: neuter", "Gm.: non-neuter"))

ggplot(germart_perPart,
       aes(x = Country,
           y = prop_neuter)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2, height = 0), shape = 1) +
  facet_grid(DutchSDGender + GermanNeuter ~ ., scales = "free_y", drop = TRUE, space = "free_y") +
  ylim(0, 1) +
  xlab(NULL) +
  ylab("Proportion of neuter ('das') choices") +
  coord_flip() +
  theme_bw()
