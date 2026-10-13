OBJDIR := $(BUILD_DIR)/obj/$(MODULE)
OBJFILES := $(addprefix $(OBJDIR)/,$(OBJS))
DEPFILES := $(OBJFILES:.o=.d)
SUBDIR_OBJS := $(foreach dir,$(SUBDIRS),$(shell $(MAKE) --no-print-directory -s -C $(dir) print-objs TOPDIR=$(TOPDIR) BUILD_DIR=$(BUILD_DIR)))
ALL_OBJS := $(OBJFILES) $(SUBDIR_OBJS)

CC ?= cc
CFLAGS ?= -O2 -g
CPPFLAGS ?=

.PHONY: all clean print-objs subdirs $(SUBDIRS)

all: $(OBJFILES) subdirs

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ all TOPDIR="$(TOPDIR)" BUILD_DIR="$(BUILD_DIR)" \
		CC="$(CC)" CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)"

$(OBJDIR)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean TOPDIR="$(TOPDIR)" BUILD_DIR="$(BUILD_DIR)"; \
	done
	rm -rf "$(OBJDIR)"

print-objs:
	@printf '%s\n' $(ALL_OBJS)

-include $(DEPFILES)
