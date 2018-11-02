/*
 * MIT License
 *
 * Copyright (c) 2018 Andreas Baulig
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "XdkAppInfo.h"

#undef BCDS_MODULE_ID
#define BCDS_MODULE_ID XDK_APP_MODULE_ID_APP

#include "App.h"

#include "BCDS_Basics.h"

#include <stdio.h>
#include <stdbool.h>
#include <inttypes.h>

static bool AppStarted = false;

Retcode_T App_Start(void) {
	Retcode_T retcode = RETCODE_OK;

	AppStarted = true;

	return retcode;
}

Retcode_T App_Stop(void) {
	Retcode_T retcode = RETCODE_OK;

	AppStarted = false;

	return retcode;
}

Retcode_T App_NotifyAction(enum App_Action action) {
	Retcode_T retcode = RETCODE_OK;

	if (!AppStarted) {
		retcode = RETCODE(RETCODE_SEVERITY_ERROR, RETCODE_INCONSITENT_STATE);
	}

	if (RETCODE_OK == retcode) {
		switch (action) {
		case APP_ACTION_JUMP:
			puts("JUMP");
			break;
		case APP_ACTION_STOPJUMP:
			puts("STOPJUMP");
			break;
		case APP_ACTION_MAX:
		default:
			retcode = RETCODE(RETCODE_SEVERITY_FATAL,
					RETCODE_UNEXPECTED_BEHAVIOR);
			break;
		}
	}

	return retcode;
}
