all:
	stow --verbose --no-folding --target=$$HOME --restow --ignore=windows */
delete:
	stow --verbose --no-folding --target=$$HOME --delete */

