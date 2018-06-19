###################################################################################
# CRYPTO Unit Test on MSS Makefile
###################################################################################
.PHONY: mssTest mssTestClean

###################################################################################
# Setup the VPATH:
###################################################################################
vpath %.c src
vpath %.c test/$(MMWAVE_SDK_DEVICE_TYPE)
vpath %.c test

###################################################################################
# The CRYPTO Unit Test uses the common libraries + Test Logger Library
###################################################################################
CRYPTO_UNIT_TEST_STD_LIBS = $(R4F_COMMON_STD_LIB)									\
						  -llibpinmux_$(MMWAVE_SDK_DEVICE_TYPE).$(R4F_LIB_EXT)		\
					      -llibtestlogger_$(MMWAVE_SDK_DEVICE_TYPE).$(R4F_LIB_EXT)
CRYPTO_UNIT_TEST_LOC_LIBS = $(R4F_COMMON_LOC_LIB)									\
						  -i$(MMWAVE_SDK_INSTALL_PATH)/ti/drivers/pinmux/lib	\
						  -i$(MMWAVE_SDK_INSTALL_PATH)/ti/utils/testlogger/lib

###################################################################################
# Unit Test Files
###################################################################################
CRYPTO_UNIT_TEST_CFG       = test/$(MMWAVE_SDK_DEVICE_TYPE)/mss.cfg
CRYPTO_UNIT_TEST_CMD       = $(MMWAVE_SDK_INSTALL_PATH)/ti/platform/$(MMWAVE_SDK_DEVICE_TYPE)
CRYPTO_UNIT_TEST_CONFIGPKG = test/$(MMWAVE_SDK_DEVICE_TYPE)/mss_configPkg_$(MMWAVE_SDK_DEVICE_TYPE)
CRYPTO_UNIT_TEST_MAP       = test/$(MMWAVE_SDK_DEVICE_TYPE)/$(MMWAVE_SDK_DEVICE_TYPE)_crypto_mss.map
CRYPTO_UNIT_TEST_OUT       = test/$(MMWAVE_SDK_DEVICE_TYPE)/$(MMWAVE_SDK_DEVICE_TYPE)_crypto_mss.$(R4F_EXE_EXT)
CRYPTO_UNIT_TEST_BIN       = test/$(MMWAVE_SDK_DEVICE_TYPE)/$(MMWAVE_SDK_DEVICE_TYPE)_crypto_mss.bin
CRYPTO_UNIT_TEST_APP_CMD   = test/$(MMWAVE_SDK_DEVICE_TYPE)/mss_crypto_linker.cmd
CRYPTO_UNIT_TEST_SOURCES   = $(CRYPTO_DRV_SOURCES) main.c
CRYPTO_UNIT_TEST_DEPENDS   = $(addprefix $(PLATFORM_OBJDIR)/, $(CRYPTO_UNIT_TEST_SOURCES:.c=.$(R4F_DEP_EXT)))
CRYPTO_UNIT_TEST_OBJECTS   = $(addprefix $(PLATFORM_OBJDIR)/, $(CRYPTO_UNIT_TEST_SOURCES:.c=.$(R4F_OBJ_EXT)))

###################################################################################
# RTSC Configuration:
###################################################################################
cryptoRTSC: $(R4_CFG)
	@echo 'Configuring RTSC packages...'
	$(XS) --xdcpath="$(XDCPATH)" xdc.tools.configuro $(R4F_XSFLAGS) -o $(CRYPTO_UNIT_TEST_CONFIGPKG) $(CRYPTO_UNIT_TEST_CFG)
	@echo 'Finished configuring packages'
	@echo ' '

###################################################################################
# Build Unit Test:
###################################################################################
mssTest: BUILD_CONFIGPKG=$(CRYPTO_UNIT_TEST_CONFIGPKG)
mssTest: R4F_CFLAGS += --cmd_file=$(BUILD_CONFIGPKG)/compiler.opt
mssTest: buildDirectories cryptoRTSC $(CRYPTO_UNIT_TEST_OBJECTS)
	$(R4F_LD) $(R4F_LDFLAGS) $(CRYPTO_UNIT_TEST_LOC_LIBS) $(CRYPTO_UNIT_TEST_STD_LIBS)	\
	-l$(CRYPTO_UNIT_TEST_CONFIGPKG)/linker.cmd --map_file=$(CRYPTO_UNIT_TEST_MAP) 		\
	$(CRYPTO_UNIT_TEST_OBJECTS) $(PLATFORM_R4F_LINK_CMD) $(CRYPTO_UNIT_TEST_APP_CMD) 		\
	$(R4F_LD_RTS_FLAGS) -o $(CRYPTO_UNIT_TEST_OUT)
	@echo '******************************************************************************'
	@echo 'Built the CRYPTO R4 Unit Test OUT file'
	@echo '******************************************************************************'

###################################################################################
# Cleanup Unit Test:
###################################################################################
mssTestClean:
	@echo 'Cleaning the CRYPTO R4 Unit Test objects'
	@$(DEL) $(CRYPTO_UNIT_TEST_OBJECTS) $(CRYPTO_UNIT_TEST_OUT) $(CRYPTO_UNIT_TEST_BIN)
	@$(DEL) $(CRYPTO_UNIT_TEST_MAP) $(CRYPTO_UNIT_TEST_DEPENDS)
	@echo 'Cleaning the CRYPTO R4 Unit RTSC package'
	@$(DEL) $(CRYPTO_UNIT_TEST_CONFIGPKG)
	@$(DEL) $(PLATFORM_OBJDIR)

###################################################################################
# Dependency handling
###################################################################################
-include $(CRYPTO_UNIT_TEST_DEPENDS)

