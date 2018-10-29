/*
 * Copyright (c) 2017-2018 Dmitry Marakasov <amdmi3@amdmi3.ru>
 *
 * Contains code from PostgreSQL 9.6 citext extension:
 *
 * Portions Copyright (c) 1996-2017, PostgreSQL Global Development Group
 *
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "postgres.h"
#include "fmgr.h"
#include "access/hash.h"
#include "utils/builtins.h"
#include "utils/formatting.h"

#include <libversion/version.h>

PG_MODULE_MAGIC;

/*
 * Helper functions
 */

static int32
versiontextcmp2(text *left, text *right)
{
	char* cleft = pnstrdup(VARDATA_ANY(left), VARSIZE_ANY_EXHDR(left));
	char* cright = pnstrdup(VARDATA_ANY(right), VARSIZE_ANY_EXHDR(right));

	int32 result = (int32)
#if defined(LIBVERSION_VERSION_ATLEAST)
# if	LIBVERSION_VERSION_ATLEAST(2, 7, 0)
		version_compare2(cleft, cright)
# else
		version_compare_simple(cleft, cright)
# endif
#else
		version_compare_simple(cleft, cright)
#endif
	;

	pfree(cleft);
	pfree(cright);

	return result;
}

static int32
versiontextcmp4(text *left, text *right, int32 left_flags, int32 right_flags)
{
	char* cleft = pnstrdup(VARDATA_ANY(left), VARSIZE_ANY_EXHDR(left));
	char* cright = pnstrdup(VARDATA_ANY(right), VARSIZE_ANY_EXHDR(right));

	int32 result = (int32)
#if defined(LIBVERSION_VERSION_ATLEAST)
# if	LIBVERSION_VERSION_ATLEAST(2, 7, 0)
		version_compare4(cleft, cright, left_flags, right_flags)
# else
		version_compare_flags2(cleft, cright, left_flags, right_flags)
# endif
#else
		version_compare_flags2(cleft, cright, left_flags, right_flags)
#endif
	;

	pfree(cleft);
	pfree(cright);

	return result;
}

/*
 * Standalone functions
 */

PG_FUNCTION_INFO_V1(wrap_version_compare_simple);

Datum
wrap_version_compare_simple(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	int32 result = versiontextcmp2(left, right);

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

	PG_RETURN_INT32(result);
}

PG_FUNCTION_INFO_V1(wrap_version_compare2);

Datum
wrap_version_compare2(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	int32 result = versiontextcmp2(left, right);

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

	PG_RETURN_INT32(result);
}

PG_FUNCTION_INFO_V1(wrap_version_compare4);

Datum
wrap_version_compare4(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);
	int left_flags = PG_GETARG_INT32(2);
	int right_flags = PG_GETARG_INT32(3);

	int32 result = versiontextcmp4(left, right, left_flags, right_flags);

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

	PG_RETURN_INT32(result);
}

PG_FUNCTION_INFO_V1(wrap_VERSIONFLAG_P_IS_PATCH);

Datum
wrap_VERSIONFLAG_P_IS_PATCH(PG_FUNCTION_ARGS)
{
	PG_RETURN_INT32(VERSIONFLAG_P_IS_PATCH);
}

PG_FUNCTION_INFO_V1(wrap_VERSIONFLAG_ANY_IS_PATCH);

Datum
wrap_VERSIONFLAG_ANY_IS_PATCH(PG_FUNCTION_ARGS)
{
	PG_RETURN_INT32(VERSIONFLAG_ANY_IS_PATCH);
}

/*
 * Custom type support
 *
 * Most I/O functions, and a few others, piggyback on the "text" type
 * functions via the implicit cast to text.
 */

/*
 *		==================
 *		INDEXING FUNCTIONS
 *		==================
 */

PG_FUNCTION_INFO_V1(versiontext_cmp);

Datum
versiontext_cmp(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	int32 result = versiontextcmp2(left, right);

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

    PG_RETURN_INT32(result);
}

PG_FUNCTION_INFO_V1(versiontext_hash);

Datum
versiontext_hash(PG_FUNCTION_ARGS)
{
	text *txt = PG_GETARG_TEXT_PP(0);
    Datum result;

    result = hash_any((unsigned char*)VARDATA_ANY(txt), VARSIZE_ANY_EXHDR(txt));

    PG_FREE_IF_COPY(txt, 0);

	PG_RETURN_DATUM(result);
}

/*
 *		==================
 *		OPERATOR FUNCTIONS
 *		==================
 */

PG_FUNCTION_INFO_V1(versiontext_eq);

Datum
versiontext_eq(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	bool result = versiontextcmp2(left, right) == 0;

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(versiontext_ne);

Datum
versiontext_ne(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	bool result = versiontextcmp2(left, right) != 0;

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(versiontext_lt);

Datum
versiontext_lt(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	bool result = versiontextcmp2(left, right) < 0;

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(versiontext_le);

Datum
versiontext_le(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	bool result = versiontextcmp2(left, right) <= 0;

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(versiontext_gt);

Datum
versiontext_gt(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	bool result = versiontextcmp2(left, right) > 0;

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

PG_FUNCTION_INFO_V1(versiontext_ge);

Datum
versiontext_ge(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);

	bool result = versiontextcmp2(left, right) >= 0;

	PG_FREE_IF_COPY(left, 0);
	PG_FREE_IF_COPY(right, 1);

    PG_RETURN_BOOL(result);
}

/*
 *		===================
 *		AGGREGATE FUNCTIONS
 *		===================
 */

PG_FUNCTION_INFO_V1(versiontext_smaller);

Datum
versiontext_smaller(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);
	text *result = versiontextcmp2(left, right) < 0 ? left : right;

	PG_RETURN_TEXT_P(result);
}

PG_FUNCTION_INFO_V1(versiontext_larger);

Datum
versiontext_larger(PG_FUNCTION_ARGS)
{
	text *left = PG_GETARG_TEXT_PP(0);
	text *right = PG_GETARG_TEXT_PP(1);
	text *result = versiontextcmp2(left, right) > 0 ? left : right;
	PG_RETURN_TEXT_P(result);
}
