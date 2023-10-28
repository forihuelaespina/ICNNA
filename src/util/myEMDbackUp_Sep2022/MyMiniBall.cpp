// File: MyMiniBall.cpp
// Author: Felipe Orihuela-Espina
// Date: 16/06/2012
//
// This program calculates the smallest enclosing balls of points in
//arbitrary dimensions. It uses Bernd Gaertner's Miniball Program, and
//in particular the dynamic version that allows specifying the dimension
//of the ball in runtime.
//
//===========
//== Usage:
//===========
//
// >myMiniball DataSet.txt Output.txt
//
// The DataSet.csv contains the list of points in arbitrary dimension. It
//contains a point per row and one dimension per column.
// The Output.csv is where this program outputs the ball center and radius.
//

#include <cstdlib>
#include <cassert>
#include <iostream>

#include "Miniball_dynamic_d.h"

//Declare auxiliar functions here, so that the compilar finds them
int estimateDimension(FILE *pFile);

   
int main (int argc, char* argv[])
{
  using std::cout;
  using std::endl;

  char* dataFilename;
  char* outputFilename;
  bool verbose=false;

  if (argc != 3) {
    cout << "Usage: miniball_example <dataFile> <outputFile>" << endl;
    exit(1);
  } else
    {
	dataFilename = argv[1];
	outputFilename = argv[2];
	if (verbose)
	{
	  cout << "Data filename: " << dataFilename << endl;
	  cout << "Output filename: " << outputFilename << endl;
	}
  };   

  //Read the data file.
  // --------------
  //In reading the data file, the dimension of the ball is estimated.
  FILE *pFile;
  pFile = fopen(dataFilename,"r");
  if (pFile==NULL)
  {
	  perror("Error: Unable to open data file\n");
      return 1;
  }

  int dim = 0; //Dimension
  dim=estimateDimension(pFile);
  if (verbose)
	cout << "Data dimension: " << dim << endl;

  Miniball mb(dim);
  Point p(dim);

  //Now read the data
  float f;
  int j=0;
  while (fscanf(pFile,"%f,",&f)!=EOF)
  {
	  p[j]=f; //Catch this point j-th coordinate
	  if (j==dim-1)
	  {
		  j=0;
		  if (verbose)
		  {
		    for (int ii=0; ii<dim; ii++)
			  printf("%f; ",p[ii]);
		    printf("\n");
		  }
		  mb.check_in(p); //Add the point to the miniball
	  }
	  else j++;
  }
  if (verbose)
    cout << "Number of points in miniball: " << mb.nr_points() << endl;

  fclose(pFile);
   
  // construct ball
  // --------------
  if (verbose)
	cout << "Constructing miniball..."; cout.flush();
  mb.build();
  if (verbose)
    cout << "done." << endl << endl;
   
  if (verbose)
  {
    // output center and squared radius
    // --------------------------------
    cout << "Center:         " << mb.center() << endl;
    cout << "Squared radius: " << mb.squared_radius() << endl << endl;

    // output number of support points
    // -------------------------------
    cout << mb.nr_support_points() << " support points: " << endl << endl;
   
    // output support points
    // ---------------------
    Miniball::Cit it;
    for (it=mb.support_points_begin(); it!=mb.support_points_end(); ++it)
      cout << *it << endl;
    cout << endl;
   
    // output accuracy
    // ---------------
    double slack;
    cout << "Relative accuracy: " << mb.accuracy (slack) << endl;
    cout << "Optimality slack:  " << slack << endl;

    // check validity (even if this fails, the ball may be acceptable, 
    // see the interface of class Miniball)
    // ------------------------------------
    cout << "Validity: " << (mb.is_valid() ? "ok" : "possibly invalid") << endl;
  } //end if verbose


  //Outputs results
  // --------------
  //In reading the data file, the dimension of the ball is estimated.
  pFile = fopen(outputFilename,"w");
  if (pFile==NULL)
  {
	  perror("Error: Unable to open output file\n");
      return 1;
  }
  p=mb.center();
  //Long format
  /*fprintf(pFile,"Center, ");
  for (int ii=0;ii<dim;ii++)
	fprintf(pFile,"%f, ",p[ii]);
  fprintf(pFile,"\n");
  fprintf(pFile,"Squared radius, %f\n",mb.squared_radius());*/
  //Short format
  fprintf(pFile,"%f, ",mb.squared_radius());
  for (int ii=0;ii<dim-1;ii++)
	fprintf(pFile,"%f, ",p[ii]);
  fprintf(pFile,"%f",p[dim-1]); //The last coordinate without an ending comma
  fclose(pFile);


  return 0;
}




// AUXILIAR FUNCTIONS
int estimateDimension(FILE *pFile)
//Estimates the dimensions of the point.
//
//It reads a line of the file (that is a single point), and parses it to find
//out the number of coordinates per point.
//
{
	int dim = 0;
	//char *line =NULL;
	char line[10000];
	fpos_t pos = 0; //Position by which I'm reading the file. I need to return
				//the read pointer to this position
	fgetpos(pFile,&pos);

	fgets (line, 10000 , pFile); //Read a line
	//cout << line; //Does not work within this function. cout is not recognized
	int lastCommaIdx=-1;
	for (int ii=0; ii<=strlen(line); ii++)
	{
	    if (line[ii]==',')
		{
			dim++;
			lastCommaIdx=ii;
		}
	}
	//Does the last coordinate comes without a comma?
	//If the last coordinate comes without a comma, then add 1 to the dimension
	for (int ii=lastCommaIdx+1; ii<strlen(line); ii++)
	{
		if (line[ii]=='0' || line[ii]=='1' || line[ii]=='2' || line[ii]=='3'
		 || line[ii]=='4' || line[ii]=='5' || line[ii]=='6' || line[ii]=='7'
		 || line[ii]=='8' || line[ii]=='9')
		{
			dim++;
			break;
		}
	}
	fsetpos(pFile,&pos); //Return the pointer to where it was

	return dim;
}



/*Miniball readData(FILE *pFile, int dim)
// Reads the points from the data file
{
	Miniball mb(dim);
	Point p(dim);

/*  for (int i=0; i<n; ++i) {
    for (int j=0; j<d; ++j)
      p[j] = rand();
    mb.check_in(p);
  }/

  float f;
  int j=0;
  while (fscanf(pFile,"%f,",&f)!=EOF)
  {
	  printf("%f\n",f);
	  p[j]=f; //Catch this point j-th coordinate
	  if (j==dim-1)
	  {
		  j=0;
		  for (int ii=0; ii<=dim; ii++)
			  printf("%f; ",f);
		  printf("\n");
		  mb.check_in(p); //Add the point to the miniball
	  }
	  printf("Number of points in miniball: %d\n",mb.nr_points());
  }
  
  return mb;
}*/