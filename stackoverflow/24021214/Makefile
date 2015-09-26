SH_TESTS = $(wildcard *_test.sh)

INSTANCE_SIZES = $(shell seq 10 15)

# For a list of available shorthand image names, see the docs:
# https://cloud.google.com/sdk/gcloud/reference/compute/instances/create
IMAGE = debian-7-backports

VERB = @

default:
	$(VERB) echo "Valid targets: create, delete, test"

create:
	$(VERB) env IMAGE=$(IMAGE) ./gcloud.sh create $(INSTANCE_SIZES)

delete:
	$(VERB) ./gcloud.sh delete $(INSTANCE_SIZES)

df:
	$(VERB) ./gcloud.sh df $(INSTANCE_SIZES)

ssh:
	$(VERB) ./gcloud.sh ssh $(INSTANCE_SIZES)

test: fdisk.sh fdisk_test.sh
	$(VERB) for test in $(SH_TESTS); do \
	  echo "Testing $$test ..."; \
	  bash $$test; \
	done
	$(VERB) echo "Done."
