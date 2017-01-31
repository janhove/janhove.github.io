---
title: "Automatise repetitive tasks"
layout: post
tags: organisation
category: Teaching
---

Research often involves many repetitive tasks. For a ongoing project, for instance, we needed to replace all stylised apostrophes (’) with straight apostrophes (') in some 3,000 text files when preparing the texts for the next step. As another example, you may need to split up a bunch of files into different directories depending on, say, the character in the file name just before the extension. When done by hand, such tasks are as mind-numbing and time-consuming as they sound -- perhaps you would do them on a Friday afternoon while listening to music or outsource them to a student assistant. My advice, though, is this: Try to automatise repetitive tasks.

Doing repetitive tasks is what computers are for, so rather than spending several hours learning nothing, I suggest you spend that time writing a script or putting together a command line call that does the task for you. If you have little experience doing this, this will take time at first. In fact, I reckon I often spend roughly same amount of time trying to automatise menial tasks as it would have cost me to do them by hand. But in the not-so-long run, automatisation is a time-saver: Once you have a working script, you can tweak and reuse it. Additionally, while you’re figuring out how to automatise a menial chore, you’re actually learning something useful. The chores become more of a challenge and less mind-numbing.
I’m going to present an example or two of what I mean and I will conclude by giving some general pointers.

<!--more-->

### Example 1: Replacing stylised apostrophes by straight apostrophes

This is the example cited above: for an ongoing project, we needed to replace all stylised apostrophes (i.e., ’) with straight apostrophes (i.e., ') in some 3,000 text files. This task is so menial you shouldn’t even think about doing it by hand, i.e., by opening all 3,000 text files and using ‘Find and replace’. I work on Linux so I Googled something like “find and replace in all files Linux” and found a post on StackOverflow very much like [this one](http://stackoverflow.com/a/11392505) that provided the basic solution: To replace occurrences of "foo" with "bar"" in all files in a directory, open a Linux terminal (command-line) and use 

<pre>
cd /path/to/your/folder
sed -i 's/foo/bar/g' *
</pre>

The first line navigates you to the directory containing the files you want to edit, so I needed to replace that by, say, 

<pre>
cd Documents/ProjectX/files
</pre>

The second line is a [sed](http://www.grymoire.com/Unix/Sed.html) command where I needed to replace 'foo' with a stylised apostrophe and 'bar' with a straight apostrophe. 
To get it to work, I needed to replace the outer single quotation marks by double quotation marks:

<pre>
sed -i "s/’/'/g" *
</pre>

I later learnt that the '-i' means that the files are edited in place; removing the '-i' shows the content of the files with all ’s changes to 's in the terminal, but doesn’t affect the files themselves. The 'g' causes the command to replace all occurrences, not just the first one, and by using '*' at the end, the sed command is applied to all files in the directory.

I don’t think this command will work out of the box on Windows, but that’s not the point (I’m sure you can easily find a similar solution for Windows). Rather, the point is that, given a choice between doing a repetitive task and trying to find an automatic solution, invest your time in the second.

Incidentally, an alternative to using the command line for such tasks would be to use a program with a graphical user interface that allows you to find and replace strings in all files in a directory. The advantage to using the command line is that you can simply save the commands so that you have an unambiguous record of what steps you took when preparing materials or data.

### Example 2: Concatenating pairs of text files based on their name

The files mentioned above contain short texts by children at different points in time. At each point in time, each child wrote two texts: a narrative and an argumentative one. For the purposes of an analysis, we needed to combine the narrative and argumentative text into one file for each child at each point in time.

This task would again be mind-numbing, but helpfully, the files were named in such a way that this step could be automatised. Each file name started with a string that uniquely identified the child, followed by either '_narr_' or '_arg_' 
(narrative vs. argumentative text), followed by the point in time when the text was written and the file extension. By Googling something like "merge text files based on name", I found another helpful StackOverflow [post](http://unix.stackexchange.com/questions/123932/merging-text-files-based-on-their-filename). I needed to tweak this a bit, and while I bet the solution below looks pig-ugly to people more knowledgeable about scripting, it does the job:

<pre>
# Merge text files based on name

# Find all files in directory containing 'narr'
FILESNARR=$(find . -type f -name '*narr*')
# Find all files in directory containing 'arg'
FILESARG=$(find . -type f -name '*arg*')

# The following loops through all files with narr and arg found above.
# It extracts the first part of the filename (child’s unique ID)
# (filename1: up till 'narr' or 'arg')
# as well as the second part (time of data collection + extension)
# (filename2: after 'narr' or 'arg').
# First, the contents of the narr files are written to a new file
# called filename1_filename2 (i.e., unique ID_Time.txt).
# Then, the contents of the arg files are appended to this file.

# First write the narrative texts to file.
for file in $FILESNARR; do
 # take 'file', remove everything after and including _narr
 filename1=${file%_narr_*}
 # take 'file', remove everything before and including _narr
 filename2=${file#*_narr_}
 cat "$file" >> "${filename1}_${filename2}"
done

# Then add the argumentative texts to the same file.
for file in $FILESARG; do
 filename1=${file%_arg_*}
 filename2=${file#*_arg_}
 cat "$file" >> "${filename1}_${filename2}"
done
</pre>


Note that if we decided we would rather have the argumentative first and the narrative texts second, we just change the order of the last two blocks. It would also be easy to tweak this script so that we would have some filler text before or after each text, for instance. Copious comments increases the script’s reuse potential.

### General pointers
1. I have found [StackOverflow](http://stackoverflow.com) to be the most useful resource for finding commands such as those above.

2. If you’re working with sound files and need to perform menial tasks on them, make use of [Praat's](http://www.fon.hum.uva.nl/praat/) scripting possibilities. You can find some very useful scripts at http://www.linguistics.ucla.edu/faciliti/facilities/acoustic/praat.html, and even if they don’t do what you need, you can use them to teach yourself how to script in Praat. (It’s pretty intuitive.)

3. When the menial steps involve data that you need to preprocess or squeeze into the right format, don’t manually edit the original data files. Instead, do your data wrangling in your statistics program and use a script, not a graphical user interface. This way, any changes are documented and easily reversible.

4. Most imporantly, *make a back-up of the files you want to edit*. Don’t run a command on batch of text files only to find out that all exclamation marks have been replaced by spaces rather than dots. You can’t click “undo previous” when working at the prompt.
