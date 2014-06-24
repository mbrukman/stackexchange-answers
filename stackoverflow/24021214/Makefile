SH_TESTS = $(wildcard *_test.sh)

INSTANCE_SIZES = $(shell seq 10 15)
IMAGE_OS = debian

VERB = @

default:
	$(VERB) echo "Valid targets: create, delete, test"

create:
	$(VERB) env IMAGE_OS=$(IMAGE_OS) ./gcutil.sh create $(INSTANCE_SIZES)

delete:
	$(VERB) ./gcutil.sh delete $(INSTANCE_SIZES)

df:
	$(VERB) ./gcutil.sh df $(INSTANCE_SIZES)

ssh:
	$(VERB) ./gcutil.sh ssh $(INSTANCE_SIZES)

test: fdisk.sh fdisk_test.sh
	$(VERB) for test in $(SH_TESTS); do \
	  echo "Testing $$test ..."; \
	  bash $$test; \
	done
	$(VERB) echo "Done."
