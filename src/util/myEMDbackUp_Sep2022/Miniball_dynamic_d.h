//    Copright (C) 1999-2006, Bernd Gaertner
//    $Revision: 1.4 $
//    $Date: 2008/02/11 11:50:05 $
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA,
//    or download the License terms from prep.ai.mit.edu/pub/gnu/COPYING-2.0.
//
//    Contact:
//    --------
//    Bernd Gaertner
//    Institute of Theoretical Computer Science 
//    ETH Zuerich
//    CAB G32.2
//    CH-8092 Zuerich, Switzerland
//    http://www.inf.ethz.ch/personal/gaertner

#include <cstdlib>
#include <cassert>
#include <cmath>
#include <iostream>
#include <list>

// Functions
// =========
inline double mb_sqr (double r) {return r*r;}
 
// Class Declarations
// ==================

// smallest enclosing ball of a set of n points in dimension d
class Miniball;

// smallest ball with a set of n <= d+1 points *on the boundary*
class Miniball_b; 

// point in dimension d
class Point;


// Class Definitions
// =================

// Miniball_b
// ----------
class Miniball_b {
private:
    
  // data members
  int                 d;      // dimension
  int                 m, s;   // size and number of support points
  double*             q0;
    
  double*             z;
  double*             f;
  double**            v;
  double**            a;
    
  double**            c;
  double*             sqr_r;
    
  double*             current_c;      // refers to some c[j]
  double              current_sqr_r;  

  // if you want the copy constructor and assignment operator, please
  // properly implement them yourself. The default copy/assignment
  // semantics fails since a Miniball_b object stores pointers to
  // dynamically allocated memory
  Miniball_b (const Miniball_b& mb);
  Miniball_b& operator=(const Miniball_b& mb);  

public:
  Miniball_b(int dim) 
    : d(dim) 
  {
    q0 = new double[d];
    z = new double[d+1];
    f = new double[d+1];
    v = new double*[d+1];
    for (int i=0; i<d+1; ++i) v[i] =  new double[d];
    a = new double*[d+1];
    for (int i=0; i<d+1; ++i) a[i] =  new double[d];   
    c = new double*[d+1];
    for (int i=0; i<d+1; ++i) c[i] =  new double[d];
    sqr_r = new double[d+1];
    reset();
  }

  ~Miniball_b() 
  {
    delete[] sqr_r;
    for (int i=0; i<d+1; ++i) delete[] c[i];
    delete[] c;
    for (int i=0; i<d+1; ++i) delete[] a[i];
    delete[] a;
    for (int i=0; i<d+1; ++i) delete[] v[i];
    delete[] v;
    delete[] f;
    delete[] z;
    delete[] q0;
  }
    
  // access
  const double*       center() const;
  double              squared_radius() const;
  int                 size() const;
  int                 support_size() const;
  double              excess (const Point& p) const;
    
  // modification
  void                reset(); // generates empty sphere with m=s=0
  bool                push (const Point& p);
  void                pop ();
    
  // checking
  double              slack() const;
};

// Miniball
// --------
class Miniball {
public:
  // types
  typedef std::list<Point>::iterator         It;
  typedef std::list<Point>::const_iterator   Cit;
    
private:
  // data members
  int              d;            // dimension
  std::list<Point> L;            // internal point set
  Miniball_b       B;            // the current ball
  It               support_end;  // past-the-end iterator of support set
    
  // private methods
  void        mtf_mb (It k);
  void        pivot_mb (It k);
  void        move_to_front (It j);
  double      max_excess (It t, It i, It& pivot) const;  

public:
  // creates an empty ball
  Miniball(int dim) : d(dim), B(dim) {}

  // copies p to the internal point set
  void        check_in (const Point& p);

  // builds the smallest enclosing ball of the internal point set
  void        build ();
    
  // returns center of the ball (undefined if ball is empty)
  Point       center() const;

  // returns squared_radius of the ball (-1 if ball is empty)
  double      squared_radius () const;

  // returns size of internal point set
  int         nr_points () const;

  // returns begin- and past-the-end iterators for internal point set
  Cit         points_begin () const;
  Cit         points_end () const;

  // returns size of support point set; this set has the following properties:
  // - there are at most d+1 support points, 
  // - all support points are on the boundary of the computed ball, and
  // - the smallest enclosing ball of the support point set equals the 
  //   smallest enclosing ball of the internal point set
  int         nr_support_points () const;

  // returns begin- and past-the-end iterators for internal point set
  Cit         support_points_begin () const;
  Cit         support_points_end () const;
    
  // assesses the quality of the computed ball. The return value is the
  // maximum squared distance of any support point or point outside the 
  // ball to the boundary of the ball, divided by the squared radius of
  // the ball. If everything went fine, this will be less than e-15 and
  // says that the computed ball approximately contains all the internal
  // points and has all the support points on the boundary.
  // 
  // The slack parameter that is set by the method says something about
  // whether the computed ball is really the *smallest* enclosing ball 
  // of the support points; if everything went fine, this value will be 0; 
  // a positive value may indicate that the ball is not smallest possible,
  // with the deviation from optimality growing with the slack
  double      accuracy (double& slack) const;

  // returns true if the accuracy is below the given tolerance and the
  // slack is 0
  bool        is_valid (double tolerance = 1e-15) const;
};
    
// Point (inline)
// --------------

class Point {
private:
  int d; 
  double* coord;
   
public:
  // default
  Point(int dim)
    : d (dim), coord(new double[dim])
  {}

  ~Point ()
  {
    delete[] coord;
  }
   
  // copy from Point
  Point (const Point& p)
    : d (p.dim()), coord(new double[p.dim()])
  {
    for (int i=0; i<d; ++i)
      coord[i] = p.coord[i];
  }
   
  // copy from double*
  Point (int dim, const double* p)
    : d (dim), coord(new double[dim])
  {
    for (int i=0; i<d; ++i)
      coord[i] = p[i];
  }
   
  // assignment
  Point& operator = (const Point& p)
  {
    assert (d == p.dim());
    if (this != &p)
      for (int i=0; i<d; ++i)
	coord[i] = p.coord[i];
    return *this;
  }
   
  // coordinate access
  double& operator [] (int i)
  {
    return coord[i];
  }
  const double& operator [] (int i) const
  {
    return coord[i];
  }
  const double* begin() const
  {
    return coord;
  }
  const double* end() const
  {
    return coord+d;
  }

  // dimension access
  int dim() const
  {
    return d;
  }
};
   

// Class Implementations
// =====================
    
// Miniball
// --------
   

void Miniball::check_in (const Point& p)
{
  assert (d == p.dim());
  L.push_back(p);
}   

void Miniball::build ()
{
  B.reset();
  support_end = L.begin();
  pivot_mb (L.end());
}
   
   

void Miniball::mtf_mb (It i)
{
  support_end = L.begin();
  if ((B.size())==d+1) return;
  for (It k=L.begin(); k!=i;) {
    It j=k++;
    if (B.excess(*j) > 0) {
      if (B.push(*j)) {
	mtf_mb (j);
	B.pop();
	move_to_front(j);
      }
    }
  }
}
   

void Miniball::move_to_front (It j)
{
  if (support_end == j)
    support_end++;
  L.splice (L.begin(), L, j);
}
   
   

void Miniball::pivot_mb (It i)
{
  It t = ++L.begin();
  mtf_mb (t);
  double max_e, old_sqr_r = -1;
  do {
    It pivot;
    max_e = max_excess (t, i, pivot);
    if (max_e > 0) {
      t = support_end;
      if (t==pivot) ++t;
      old_sqr_r = B.squared_radius();
      B.push (*pivot);
      mtf_mb (support_end);
      B.pop();
      move_to_front (pivot);
    }
  } while ((max_e > 0) && (B.squared_radius() > old_sqr_r));
}
   
   

double Miniball::max_excess (It t, It i, It& pivot) const
{
  const double *c = B.center(), sqr_r = B.squared_radius();
  double e, max_e = 0;
  for (It k=t; k!=i; ++k) {
    const double *p = (*k).begin();
    e = -sqr_r;
    for (int j=0; j<d; ++j)
      e += mb_sqr(p[j]-c[j]);
    if (e > max_e) {
      max_e = e;
      pivot = k;
    }
  }
  return max_e;
}
   
   
   

Point Miniball::center () const
{
  return Point(d, B.center());
}
   

double Miniball::squared_radius () const
{
  return B.squared_radius();
}
   
   

int Miniball::nr_points () const
{
  return L.size();
}
   

Miniball::Cit Miniball::points_begin () const
{
  return L.begin();
}
   

Miniball::Cit Miniball::points_end () const
{
  return L.end();
} 

int Miniball::nr_support_points () const
{
  return B.support_size();
}
   

Miniball::Cit Miniball::support_points_begin () const
{
  return L.begin();
}
   

Miniball::Cit Miniball::support_points_end () const
{
  return support_end;
}

double Miniball::accuracy (double& slack) const
{
  double e, max_e = 0;
  int n_supp=0;
  Cit i;
  for (i=L.begin(); i!=support_end; ++i,++n_supp)
    if ((e = std::abs (B.excess (*i))) > max_e)
      max_e = e;
   
  // you've found a non-numerical problem if the following ever fails
  assert (n_supp == nr_support_points());
   
  for (i=support_end; i!=L.end(); ++i)
    if ((e = B.excess (*i)) > max_e)
      max_e = e;
   
  slack = B.slack();
  return (max_e/squared_radius());
}
   

bool Miniball::is_valid (double tolerance) const
{
  double slack;
  return ( (accuracy (slack) < tolerance) && (slack == 0) );
}   

// Miniball_b
// ----------
   

const double* Miniball_b::center () const
{
  return current_c;
}
   

double Miniball_b::squared_radius() const
{
  return current_sqr_r;
}
   

int Miniball_b::size() const
{
  return m;
}
   

int Miniball_b::support_size() const
{
  return s;
}
   

double Miniball_b::excess (const Point& p) const
{
  double e = -current_sqr_r;
  for (int k=0; k<d; ++k)
    e += mb_sqr(p[k]-current_c[k]);
  return e;
}
   
   
   

void Miniball_b::reset ()
{
  m = s = 0;
  // we misuse c[0] for the center of the empty sphere
  for (int j=0; j<d; ++j)
    c[0][j]=0;
  current_c = c[0];
  current_sqr_r = -1;
}
   

void Miniball_b::pop ()
{
  --m;
}
   
   

bool Miniball_b::push (const Point& p)
{
  int i, j;
  double eps = 1e-32;
  if (m==0) {
    for (i=0; i<d; ++i)
      q0[i] = p[i];
    for (i=0; i<d; ++i)
      c[0][i] = q0[i];
    sqr_r[0] = 0;
  } else {
    // set v_m to Q_m
    for (i=0; i<d; ++i)
      v[m][i] = p[i]-q0[i];
   
    // compute the a_{m,i}, i< m
    for (i=1; i<m; ++i) {
      a[m][i] = 0;
      for (j=0; j<d; ++j)
	a[m][i] += v[i][j] * v[m][j];
      a[m][i]*=(2/z[i]);
    }
   
    // update v_m to Q_m-\bar{Q}_m
    for (i=1; i<m; ++i) {
      for (j=0; j<d; ++j)
	v[m][j] -= a[m][i]*v[i][j];
    }
   
    // compute z_m
    z[m]=0;
    for (j=0; j<d; ++j)
      z[m] += mb_sqr(v[m][j]);
    z[m]*=2;
   
    // reject push if z_m too small
    if (z[m]<eps*current_sqr_r) {
      return false;
    }
   
    // update c, sqr_r
    double e = -sqr_r[m-1];
    for (i=0; i<d; ++i)
      e += mb_sqr(p[i]-c[m-1][i]);
    f[m]=e/z[m];
   
    for (i=0; i<d; ++i)
      c[m][i] = c[m-1][i]+f[m]*v[m][i];
    sqr_r[m] = sqr_r[m-1] + e*f[m]/2;
  }
  current_c = c[m];
  current_sqr_r = sqr_r[m];
  s = ++m;
  return true;
}
      

double Miniball_b::slack () const
{
  double* l = new double[d+1];
  double min_l=0;
  l[0] = 1;
  for (int i=s-1; i>0; --i) {
    l[i] = f[i];
    for (int k=s-1; k>i; --k)
      l[i]-=a[k][i]*l[k];
    if (l[i] < min_l) min_l = l[i];
    l[0] -= l[i];
  }
  if (l[0] < min_l) min_l = l[0];
  delete[] l;
  return ( (min_l < 0) ? -min_l : 0);
}
   
// Point
// -----

// Output

std::ostream& operator << (std::ostream& os, const Point& p)
{
  os << "(";
  int d = p.dim();
  for (int i=0; i<d-1; ++i)
    os << p[i] << ", ";
  os << p[d-1] << ")";
  return os;
}
