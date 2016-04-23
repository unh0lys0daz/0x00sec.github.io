---
layout: post
title:  "Sorting (Part 2.0) Time Complexity"
date:   2016-04-23 23:16:11 +0100
categories: who nullbyte
tags:
 - sorting
 - bubble sort
 - time complexity
 - algorithms
post_author: oaktree
---
Welcome back, 0x00sec community, to my series on sorting.

I introduced in my last article the concept of complexity. When I say complexity, I'm talking about **time complexity**.

## What Is Time Complexity?
You can view the Wikipedia article <a href="https://en.wikipedia.org/wiki/Time_complexity">here</a>, but I'll be speaking from my heart and soul.

**Time complexity** is a mathematical representation of how long an algorithm could take in the worse-case scenario, and it is a function of the size of the input. Input size is usually represented by `n`.

## Example: Bubble Sort in C++
Alright, class. Take out that C++ code I handed out yesterday...

{% highlight c++ linenos %}
void bubblesort(vector<char>& vec) {
    int n = vec.size();
 
    // nest loops because O(n^2)
    // changes_made is an optimization that can reduce runtime in certain conditions
    bool changes_made = false;
 
    for (int i = 0; i < n - 1; i++) {
 
        for (int j = 0; j < n - 1; j++) {
            if (vec[j] > vec[j+1]) {
 
                // swap them
                char temp = vec[j];
                vec[j] = vec[j+1];
                vec[j+1] = temp;
 
                // tell program to run thru vec at least once more
                changes_made = true;
            }
        }
 
        // optimization to exit loop if no changes made
        if (!changes_made) break;
 
        changes_made = false;
    }
}
{% endhighlight %}

Now, let's go line-by-line in `bubblesort(...)` and add up all the things we have to do.

- On line 9, we declare a variable to hold the size of our vector, so let's add `1` to our complexity.
- Another variable is declared on line 13, so now our complexity is `2`.
- We have a `for` loop starting on line 15, so that adds `n-1` to our complexity, because we loop through the vector from the first element to the second-to-last. We have a `for` loop within the outer one in which we do the same, so we have `(n-1)x(n-1)`. Our grand total is `(n-1)x(n-1)+2`. _We do some things in the `for` loops, but we can ignore those and you'll see why in a second_.
- Okay, now we'll simplify down our total: `n^2 - 2n + 1 + 2 = n^2 -2n +3`
- Let's take the limit as n approaches infinity. This is a calculus thing, but it basically means that we want to see what happens as the size of our vector gets really, really big.
- Per the limit operation, we can simplify it down to n^2, but note that any coefficient of n^2 can also be stripped, since no coefficient could really do all that much to the square of infinity.

## Complexity Notation

Okay, so now we've concluded that the time complexity of our algorithm, Bubble Sort, can be expressed as `n^2`. But what if the vector was already sorted? Due to our awesome optimization, per `changes_made`, we only need n time to sort (in this best-case situation).

That means that our algorithm has a lower bound time complexity of n and an upper bound time complexity of `n^2.`

How do we express upper and lower bounds?

**Upper bound notation** is expressed as `O(n^2)` for our algorithm. This is called "Big-O Notation." To reiterate, this notation represents the worst-case-input scenario for our algorithm as n gets really, really huge.

**Lower bound notation** is expressed using the Greek letter omega, O. We say the lower-bound, the best-case, for our algorithm (Bubble Sort) is O(n).

## Conclusion

Well, that's time complexity right there. Bubble sort has O(n^2) and O(n) time complexity. From now on, I'll be noting the time complexity for each algorithm I discuss in the Sorting series.

Best,

oaktree