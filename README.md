# CleanUpGerbers
Renames Gerber files for one of three PCB fab houses. Zips the appropriate files together. Deletes GPI files.

<h2>Introduction</h2>

Originally just a shell script to take the usefully-named, but not-uploadable, files from an <a href="http://docs.oshpark.com/design-tools/eagle/generating-custom-gerbers/">OSHPark Eagle CAD CAM script</a>, rename them to the proper format for uploading, and then zip-archive the set of files so that it's ready for uploading. 

Later, I added some command-line switches to match the (very similar) output for a few other PCB fab houses, DirtyPCBs and Seeedstudio. 

The script, at root, is just a time saver, and a tidying-up script. Making PCBs isn't that hard, but "<a href="http://www.dragonflydiy.com/2013/01/basic-equipment-for-casual-electronics.html">noodling</a>" on the PCBs (staring at the designs for hours, searching for problems or perhaps better ways to do things) means you end up with a bunch of revised Gerber files every time you run the CAM script, and that can be annoying. 

Per <a href="https://plus.google.com/102451193315916178828/posts/MGxauXypb1Y">Bruno Oliveira's correct and humorous graph</a> (but compare <a href="http://xkcd.com/1319/">Randall Munroe's XKCD retort</a> and the much less humorous but quite more optimistic <a href="https://blog.jonudell.net/2012/01/09/another-way-to-think-about-geeks-and-repetitive-tasks/">post by Jon Udell</a>), I got annoyed by the repetitive nature of the task and ended up with a mix of Oliveira and Munroe. I spent more time than I should have on the script, but oh man does it save me time. And then I had to clean it up for github, make it more user friendly, and improve the flexibility.

But, in sum, it works. 

<h2>Here's what it does</h2>

When <a href="http://www.cadsoft.de">Eagle CAD</a>, an excellent, though not open source, CAD package, wants to convert your design from a schematic and board layout to something a PCB fab can use to grind, drill, coat, and paint your copper-clad boards, it pipes your design through a CAM (<a href="https://en.wikipedia.org/wiki/Computer-aided_manufacturing">Computer Aided Manufacturing</a>) translations script to produce Gerber files for each layer. Later, at the PCB fab, these files are converted to <a href="https://en.wikipedia.org/wiki/G-code">G-code</a>, a CNC (computer <a href="https://en.wikipedia.org/wiki/Numerical_control">numerical control</a>) language that tells the cutting, drilling, and milling instruments what, exactly, to do. For more on G-code, you can see <a href="http://cncutil.org/gcode-introduction.html">this interesting article</a>.

So, each time you want to revise your Gerber files, perhaps to preview the whole board in a renderer like <a href="http://gerbv.geda-project.org"><tt>gerbv</tt></a> (available through lots of package managers or the <a href="http://gerbv.geda-project.org/">homepage</a>), you run the CAM script. It produces a bunch of files that can be read by PCB manufacturers. You can certainly view those files without renaming them. On the other hand, when you want to fab a board, you have to ensure that each layer of the board (copper, solder mask, silkscreen, drills, whatever) is named <i>according to the rules set out by the fab house</i>. And that means looking it up, each time you want to fab a board. Then you zip the files together, upload them, and in two weeks you get a couple of boards in the mail. So, in the grand scheme of things, the amount of time you spend making sure things are right isn't that bad. 

My take on it is this: when you're tired, or distracted, or whatever, you're prone to make mistakes. And being able to freely pore over your rendered files reduces the chance of errors. Making that process easy&mdash;and saving your time and energy for the troubleshooting or noodling&mdash;is a good thing. Furthermore, it saves time and annoyance for having to do the same (repetitive) task <i>again</i>, which keeps your brain engaged with the important stuff.

Similarly, previewing the Gerber files in `gerbv` can be hard on the eyes, since the first time you load up the layers, not only are they not ordered in a visibly useful manner (holes need to be on the 'top' of the stack to be seen, etc.), the colors are randomly chosen. I also wrote a small python script to bang out a basic `gerbv` project file, using the newly-renamed layers, with some sane color choices for each layer. The `bash` script calls the python script in the middle of things, but it seems to work pretty nicely, and again, it's less repetetive busywork while you could otherwise be finished. The script is called `makegvp.gvp`.

<h2>How to use the script</h2>

CAM files typically will use some filename stub, plus maybe a descriptor (like <b><tt>bottomsilkscreen</tt></b>) and a file suffix, for each layer of the PCB set. This script asks you to tell it the stub, and either assumes that you're using OSHPark's script and naming conventions, or else you're using OSHPark's script and someone <i>else's</i> naming conventions (currently only DirtyPCBs and SeeedStudio are included). 

Example:

```./renamegerbers.sh -n FortyTwo```

And without additional CLI switches, you'll get an OSHPark-friendly zip file, plus a cleaner directory (OSHPark doesn't need or want you to upload the GPI files, which are a file format for <a href="https://en.wikipedia.org/wiki/Photoplotter">photoplotters</a>). 

If you're going to use SeeedStudio, you would say, instead, 

```./renamegerbers.sh -n FortyTwo -s ```


And you'll get a custom zip file for SeeedStudio. In practice, the only difference for a two-layer board is that the Excellon drills file suffix is <b><tt>.TXT</tt></b> instead of <b><tt>.XLN</tt></b> -- but the possibility exists that other standards might exist, so I made the script capable of handling those in the future, if desired.

<H2>Disclaimer</H2>

This code isn't elegant (though elegant programming in <b><tt>bash</tt></b>, I submit, ain't easy). It's pretty easy to read, and might be a useful introduction to a few elements of programming bash, but that's not why I wrote it. 

Further, you use this code at your own risk. I wrote it because it's useful to me. I provide it here because it might be useful to you. I have used the script enough to say that it works, but errors creep in. So please be careful. 

Jesse Hamner, 2016
