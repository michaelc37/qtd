module qtd.Core;

/**
	Casts from to type $(D_PARAM U), bypassing dynamic checks.
*/
U static_cast(U, T)(T from)
{
	return cast(U)cast(void*)from;
}

