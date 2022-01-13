===============================
Date: 16/06/2012
Author: Felipe
===============================

The Bernd Gartner miniball program is available at:

http://www.inf.ethz.ch/personal/gaertner/miniball.html

The program is available through 4 files:
+ Miniball.h
+ miniball_example.C
+ Miniball_dynamic_d.h
+ miniball_dynamic_d_example.C

The first two files are the miniball class and an example program. The two latter files are a more
flexible version, where the dimension of the ball is provided as a constructor argument and can
therefore be determined at runtime.

===============================
MyMiniBall.cpp
===============================

This is NOT the MyMiniBall program that I made during my PhD, but a brand new program
that I have made in June 2012. For some reason, I did not save the C++ code for the
MyMiniBall programs that I did during my PhD. I can't find them! So I have been
forced to create a new program.

Also, the MyMiniBall executables that I have from my PhD are valid for Unix, plus
they used the static version of miniball that required defining the dimensionality
of the ball at compile time. They do not run under Windows. The new program, works
under windows, and uses the dynamic version of Miniball, which allows defining the
ball dimensionality at run time.


==================================================================
Compiling the miniball program (Using Visual Studio Express 2010):
==================================================================

The example programs have extension .c but are actually C++ programs.
In order for the compiler to understand that it is a C++ program it is
necessary to rename the .C files as .cpp, so:

+ miniball_example.C must be renamed as miniball_example.cpp
+ miniball_dynamic_d_example.c must be renamed as miniball_dynamic_d_example.cpp

To start the command line compiler, open Visual Studio Express 2010, and
choose:

Tools -> Visual Studio Command Prompt

The C/C++ compiler is called cl.exe

Simply cd to the directory where the miniball files are located.
Then compile as follows:

1) C:\..\miniball>cl miniball_example.cpp

This will produce a .obj object file

2) C:\..\miniball>cl miniball_example.obj

This will produce a the .exe executable file

Proceed equally for the dynamic example, so:

1) C:\..\miniball>cl miniball_dynamic_d_example.cpp
2) C:\..\miniball>cl miniball_dynamic_d_example.obj
