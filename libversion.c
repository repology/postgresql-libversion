/*
 * Copyright (c) 2017 Dmitry Marakasov <amdmi3@amdmi3.ru>
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
#include "utils/builtins.h"

#include <libversion/compare.h>

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(wrap_version_compare_simple);

Datum
wrap_version_compare_simple(PG_FUNCTION_ARGS)
{
	text* t1 = PG_GETARG_TEXT_P(0);
	text* t2 = PG_GETARG_TEXT_P(1);

	size_t length1 = VARSIZE(t1) - VARHDRSZ;
	size_t length2 = VARSIZE(t2) - VARHDRSZ;

	char* v1 = (char*)palloc(length1 + 1);
	char* v2 = (char*)palloc(length2 + 1);

	int result;

	memcpy((void*)v1, (void*)VARDATA(t1), length1);
	v1[length1] = '\0';

	memcpy((void*)v2, (void*)VARDATA(t2), length2);
	v2[length2] = '\0';

	result = version_compare_simple(v1, v2);

	pfree(v1);
	pfree(v2);

	PG_RETURN_INT32((int32)result);
}
