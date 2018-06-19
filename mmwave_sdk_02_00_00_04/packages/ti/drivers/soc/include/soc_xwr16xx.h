/**
 *   @file  soc_xwr16xx.h
 *
 *   @brief
 *      This is the header file for the XWR16XX specific definitions needed by
 *    SOC driver.
 *
 *  \par
 *  NOTE:
 *      (C) Copyright 2016 Texas Instruments, Inc.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *    Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the
 *    distribution.
 *
 *    Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef SOC_XWR16XX_DRIVER_H
#define SOC_XWR16XX_DRIVER_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief
 *  Enumeration for system peripheral module id
 *
 * @details
 *  The enumeration defines the system peripheral module id to be used to
 *  configure clock, memory initialization etc.
 */
typedef enum SOC_ModuleId_e
{
    /**
     * @brief
     *  DCAN module
     */
    SOC_MODULE_DCAN           = 1U,

    /**
     * @brief
     *  DMA module
     */
    SOC_MODULE_DMA,

    /**
     * @brief
     *  DMA2 module
     */
    SOC_MODULE_DMA2,

    /**
     * @brief
     *  MCAN module
     */
    SOC_MODULE_MCAN,

    /**
     * @brief
     *  QSPI module
     */
    SOC_MODULE_QSPI,

    /**
     * @brief
     *  SPIA module
     */
    SOC_MODULE_SPIA,

    /**
     * @brief
     *  SPIB module
     */
    SOC_MODULE_SPIB
}SOC_ModuleId;

/**
 * @brief
 *  SOC Secure device firewall capable modules
 *
 * @details
 *  The bitmap enum defines the modules that can have firewall enabled/disabled on a secure device
 */
typedef enum SOC_SecureFirewallModule_e
{
    /*! JTAG */
    SOC_SECURE_FIREWALL_JTAG = 0x1U,

    /*! Secure RAM */
    SOC_SECURE_FIREWALL_SECURERAM = 0x2U,

    /*! Logger */
    SOC_SECURE_FIREWALL_LOGGER = 0x4U,

    /*! Trace */
    SOC_SECURE_FIREWALL_TRACE = 0x8U,

    /*! CRYPTO */
    SOC_SECURE_FIREWALL_CRYPTO = 0x10U,

    /*! CEK1, CEK2 firewall */
    SOC_SECURE_FIREWALL_CUSTCEK = 0x20U,

    /*! DMM */
    SOC_SECURE_FIREWALL_DMM = 0x40U

}SOC_SecureFirewallModule;


#define SOC_SECURE_FIREWALL_DISABLE 1 /* firewall disable (enable access to module) */
#define SOC_SECURE_FIREWALL_ENABLE  0 /* firewall enable (disable access to module) */

/* Part number definitions for secure devices */
#define SOC_AWR16XX_SECURE_PART_NUMBER 0x61
#define SOC_IWR16XX_SECURE_PART_NUMBER 0xC1

#ifdef __cplusplus
}
#endif

#endif /* SOC_XWR16XX_DRIVER_H */

