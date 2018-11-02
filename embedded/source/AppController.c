/*
 * Licensee agrees that the example code provided to Licensee has been developed and released by Bosch solely as an example to be used as a potential reference for Licensee�s application development.
 * Fitness and suitability of the example code for any use within Licensee�s applications need to be verified by Licensee on its own authority by taking appropriate state of the art actions and measures (e.g. by means of quality assurance measures).
 * Licensee shall be responsible for conducting the development of its applications as well as integration of parts of the example code into such applications, taking into account the state of the art of technology and any statutory regulations and provisions applicable for such applications. Compliance with the functional system requirements and testing there of (including validation of information/data security aspects and functional safety) and release shall be solely incumbent upon Licensee.
 * For the avoidance of doubt, Licensee shall be responsible and fully liable for the applications and any distribution of such applications into the market.
 *
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3)The name of the author may not be used to
 *     endorse or promote products derived from this software without
 *     specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 *  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 *  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 */

#include "XdkAppInfo.h"
#undef BCDS_MODULE_ID
#define BCDS_MODULE_ID XDK_APP_MODULE_ID_APP_CONTROLLER

#include "AppController.h"

#include "App.h"

#include "XDK_Button.h"
#include "XDK_LED.h"
#include "XdkUsbResetUtility.h"

#include "BCDS_CmdProcessor.h"

#include "FreeRTOS.h"
#include "semphr.h"
#include "task.h"

#include "em_dbg.h"

static void HandleButton1Event(ButtonEvent_T buttonEvent);
static void HandleUsbDataReceived(uint8_t* data, uint32_t length);

static CmdProcessor_T* AppCmdProcessor;
static Button_Setup_T ButtonSetup = { .CmdProcessorHandle = NULL,
		.InternalButton1isEnabled = true, .InternalButton2isEnabled = false,
		.InternalButton1Callback = HandleButton1Event,
		.InternalButton2Callback = NULL, };

/**
 * @brief Callback function registered to UsbResetUtility for incomming USB
 * data.
 * @param[in] data
 * Buffer of received data.
 *
 * @param[in] length
 * Length of data.
 */
static void HandleUsbDataReceived(uint8_t* data, uint32_t length) {
	BCDS_UNUSED(data);
	BCDS_UNUSED(length);
}

/**
 * @brief Callback to handle events for button 1.
 *
 * @param[in] buttonEvent
 * Type of event.
 */
static void HandleButton1Event(ButtonEvent_T buttonEvent) {
	BCDS_UNUSED(buttonEvent);
	switch (buttonEvent) {
	case BUTTON_EVENT_PRESSED:
		App_NotifyAction(APP_ACTION_JUMP);
		break;
	case BUTTON_EVENT_RELEASED:
		App_NotifyAction(APP_ACTION_STOPJUMP);
		break;
	default:
		Retcode_RaiseError(
				RETCODE(RETCODE_SEVERITY_FATAL, RETCODE_UNEXPECTED_BEHAVIOR));
		break;
	}
}

void AppController_Init(void* cmdProcessorHandle, uint32_t param2) {
	BCDS_UNUSED(param2);

	Retcode_T retcode = RETCODE_OK;

	if (cmdProcessorHandle == NULL) {
		printf("%s: CmdProcessor handle is NULL\n", __FUNCTION__);
		retcode = RETCODE(RETCODE_SEVERITY_ERROR, RETCODE_NULL_POINTER);
	} else {
		AppCmdProcessor = (CmdProcessor_T*) cmdProcessorHandle;
		ButtonSetup.CmdProcessorHandle = AppCmdProcessor;
	}

	if (RETCODE_OK == retcode) {
		if (DBG_Connected()) {
			/* In case a debugger is connected, wait some time for the USB
			 * enumeration to happen before moving on. */
			vTaskDelay(pdMS_TO_TICKS(5000));
		}
	}

	if (RETCODE_OK == retcode) {
		retcode = UsbResetUtility_RegAppISR(HandleUsbDataReceived);
	}

	if (RETCODE_OK == retcode) {
		retcode = Button_Setup(&ButtonSetup);
	}

	if (RETCODE_OK == retcode) {
		retcode = LED_Setup();
	}

	if (RETCODE_OK == retcode) {
		retcode = Button_Enable();
	}

	if (RETCODE_OK == retcode) {
		retcode = LED_Enable();
	}

	if (RETCODE_OK == retcode) {
		retcode = App_Start();
	}

	if (RETCODE_OK == retcode) {
		retcode = LED_On(LED_INBUILT_RED);
	}

	if (RETCODE_OK != retcode) {
		Retcode_RaiseError(retcode);
		assert(0); /* To provide LED indication for the user */
	}
}
