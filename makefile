# Directories that are not stow packages
NOT_PACKAGES := vm/
PACKAGES     := $(filter-out $(NOT_PACKAGES),$(wildcard */))

all:
	stow --verbose --no-folding --target=$$HOME --restow --ignore=windows $(PACKAGES)
delete:
	stow --verbose --no-folding --target=$$HOME --delete $(PACKAGES)
