/**
 *
 *  Copyright: Copyright QtD Team, 2008-2009
 *  Authors: Max Samukha
 *  License: <a href="http://www.boost.org/LICENSE_1_0.txt>Boost License 1.0</a>
 *
 *  Copyright QtD Team, 2008-2009
 *  Distributed under the Boost Software License, Version 1.0.
 *  (See accompanying file boost-license-1.0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 *
 */
module qtd.Array;

import
	core.stdc.string,
	qtd.Memory;

void append(alias alloc = GCAlloc, T)(ref T[] array, T elem)
{
	auto newLen = array.length + 1;
	alloc.realloc(array.ptr, newLen * T.sizeof);
	array = array.ptr[0..newLen];
	array[$ - 1] = elem;
}

void remove(alias alloc = GCAlloc, T)(ref T[] haystack, T needle)
{
    foreach (i, e; haystack)
    {
        if (e == needle)
        {
            if (haystack.length > 1)
            {
            	memmove(haystack.ptr + i, haystack.ptr + i + 1, (haystack.length - i - 1) * T.sizeof);
            	auto newLen = haystack.length - 1;
                alloc.realloc(haystack.ptr, newLen * T.sizeof);
                haystack = haystack[0..newLen];
            }
            else
            {
                alloc.realloc(haystack.ptr, 0);
            	haystack = haystack[0..0];
            }
            	
            break;
        }
    }
}

void free(alias alloc = GCAlloc)(ref T[] array)
{
	free(array.ptr, array.length * T.sizeof);
}