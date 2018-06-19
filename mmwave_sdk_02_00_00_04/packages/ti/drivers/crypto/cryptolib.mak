###################################################################################
# CRYPTO Driver Makefile
###################################################################################
.PHONY: cryptoDrv cryptoDrvClean

###################################################################################
# Setup the VPATH:
###################################################################################
vpath %.c src
vpath %.c platform

###################################################################################
# Driver Source Files:
###################################################################################
CRYPTO_DRV_SOURCES = aes.c aes_crypto.c hmac.c hmac_crypto.c Crypto.c

###################################################################################
# Driver Source Files:
# - XWR14xx, XWR16xx:
#   CRYPTO driver is available for R4
###################################################################################
ifeq ($(MMWAVE_SDK_DEVICE_TYPE),xwr16xx)
CRYPTO_DRV_SOURCES += crypto_xwr16xx.c
CRYPTO_R4F_DRV_LIB_OBJECTS  = $(addprefix $(PLATFORM_OBJDIR)/,  $(CRYPTO_DRV_SOURCES:.c=.$(R4F_OBJ_EXT)))
endif

###################################################################################
# Driver Dependency:
###################################################################################
CRYPTO_R4F_DRV_DEPENDS  = $(addprefix $(PLATFORM_OBJDIR)/, $(CRYPTO_DRV_SOURCES:.c=.$(R4F_DEP_EXT)))

###################################################################################
# Driver Library Names:
###################################################################################
CRYPTO_R4F_DRV_LIB  = lib/libcrypto_$(MMWAVE_SDK_DEVICE_TYPE).$(R4F_LIB_EXT)

###################################################################################
# CRYPTO Driver Build:
# - XWR16xx: Build the R4 Library
###################################################################################
cryptoDrv: buildDirectories $(CRYPTO_R4F_DRV_LIB_OBJECTS)
	if [ ! -d "lib" ]; then mkdir lib; fi
	echo "Archiving $@"
	$(R4F_AR) $(R4F_AR_OPTS) $(CRYPTO_R4F_DRV_LIB)  $(CRYPTO_R4F_DRV_LIB_OBJECTS)

###################################################################################
# Clean the CRYPTO Driver Libraries
###################################################################################
cryptoDrvClean:
	@echo 'Cleaning the CRYPTO Driver Library Objects'
	@$(DEL) $(CRYPTO_R4F_DRV_LIB_OBJECTS) $(CRYPTO_R4F_DRV_LIB)
	@$(DEL) $(PLATFORM_OBJDIR)

###################################################################################
# Dependency handling
###################################################################################
-include $(CRYPTO_R4F_DRV_DEPENDS)

