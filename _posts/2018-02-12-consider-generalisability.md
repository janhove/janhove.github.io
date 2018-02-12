---
layout: post
title: "Consider generalisability"
category: [Design]
tags: [design features, mixed-effects models]
---

A good question to ask yourself when designing a study is, "Who and what are any results likely to generalise to?" Generalisability needn't always be a priority when planning a study. But by giving the matter some thought before collecting your data, you may still be able to alter your design so that you don't have to smother your conclusions with ifs and buts if you do want to draw generalisations.

The generalisability question is mostly cast in terms of the study's participants: Would any results apply just to the participants themselves or to some wider population, and if so, to which one? Important as this question is, this blog post deals with a question that is asked less often but is equally crucial: Would any results apply just to the materials used in the study or might they stand some chance of generalising to different materials?
 
<!--more-->

# Generalising across listeners, texts, and speakers
To make this more concrete, consider the following example (inspired by Schüppert, Hilton, Gooskens & van Heuven, 2013, [_Stavelsebortfall i modern danska_](http://www.let.rug.nl/~gooskens/pdf/publ_Schueppert_et_al._2012.pdf)). Spoken Danish is notoriously difficult to understand, and Swedes have considerably more difficulties understanding Danish than Danes do understanding Swedish. One possible contributing factor is that Danish is spoken more quickly than its sibling languages. This may affect its intelligibility in two ways. First, a higher speech rate means that more propositions are communicated in the same time span, which may cause processing difficulties for unaccustomed listeners. Second, higher speech rates tend to lead to an increase of connected speech features. This includes assimilation (e.g., a careful pronunciation of English _broadcast_ is ‘bro:d ka:st’, but the ‘d’ tends to become a ‘g’ if it’s pronounced more quickly, i.e., ‘bro:g ka:st’) and the elision of sounds and syllables (e.g., German _haben_ tends to become _ham_).

To tease apart these ways in which a higher speech rate may compound Swedes’ comprehension difficulties with Danish, you could design an experiment along the following lines. Have a Dane read a text slowly and carefully. Then have her read the same text more naturally. By slowing down or speeding up these texts, four conditions can be created:

1. slow, few connected speech features (original recording)
2. quick, many connected speech features (original recording)
3. slow, many connected speech features (slowed down version of (2))
4. quick, few connected speech features (sped-up version of (1))

Then, you might assign some Swedes to each of these four recordings and ask them a couple of questions to test their comprehension.

First of all, note that you wouldn’t assign just one Swede to each recording: if you were to observe differences in the text’s intelligibility between the four conditions, this could plausibly be related to differences between the listeners more than differences between the intelligibility of fast and slow speech. That is, the results might strongly be affected by listener idiosyncrasies. So you assign a decent number of Swedes to each recording so that these idiosyncrasies would likely cancel out and your results stand a chance of perhaps applying to Swedes listening to Danish in general. (I won’t go into matters of statistical precision or power, though those would of course also be relevant.)

But by the same token, it is possible that any difference in the intelligibility of the four recordings may be idiosyncratic to the specific text that was recorded: perhaps speed or connected speech differences affect the intelligibility of some texts considerably more, or less, than that of this particular text. Or perhaps this text was so difficult or easy to understand that speech rate and connected speech can hardly affect its intelligibility to begin with. To guard against this possibility, you may want to consider including several texts in your study. If it’s feasible, you could have each participant listen to, say, eight texts. Ideally, each participant would be tested in all four conditions (two texts per condition), so that you can capitalise on the increased statistical precision that within-participants designs afford, and the same text would appear in different conditions across participants. This design would represent a substantial improvement over the one-text between-participants design.

But we’re still not there yet: What about the possibility that any result we find would only apply to our one Danish speaker? Perhaps this speaker happens to use few connected speech features when speaking quickly, or vice versa? When in doubt, it may be a good idea to consider having multiple speakers record a couple of texts. For instance, we could have eight Danes record eight texts in four conditions, for a total of 256 recordings.

The participants’ time is, of course, limited, and there would be little point in forcing them to listen to all 256 recordings - if only because the same texts reappear 32 times. But instead you could have each of them listen to the eight different texts (two per condition), with a different speaker each time, and vary the assignment of text to speaker and to condition between participants. If this experiment is analysed appropriately (e.g., using a mixed-effect model), you’d have more confidence that any result generalises than if you only had one text and one speaker.

# Even larger samples of texts and listeners
In the example above, each listener is exposed to each text and to each speaker. This may be feasible when you ‘only’ have eight texts and eight speakers, but what if you had fifty texts and 30 speakers? The key thing to appreciate is that you don’t have to have each listener listen to each text or to each speaker. Instead, you could work out a design in which each listener listens to only, say, eight different texts (two per condition). The speaker/text combinations could then simply be randomly sampled from the speaker/text combinations available, with the stipulation that no speaker or text is chosen twice (to avoid unwanted adaptation effects). You could then still analyse the data using the same mixed-effect model but the results would be even less likely to be affected by speaker- or text-related idiosyncrasies.

# The upshot
By using a larger number of texts or speakers, you could increase the generalisability of any findings, in much the same way that larger participant samples tend to yield more generalisable findings. If you can’t realistically expose all participants to all texts or speakers, you can expose each of them to only a subset of texts or speakers instead.

# Suggested reading
I learnt a lot by reading Westfall et al.’s (2014) [_Statistical power and optimal design in experiments in which samples of participants respond to samples of stimuli_](https://pdfs.semanticscholar.org/eedf/96e3e233636f9edadb60f9c9b22920141c26.pdf).
