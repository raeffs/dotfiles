all:
	stow --verbose --target=$$HOME --restow --ignore=windows */
delete:
	stow --verbose --target=$$HOME --delete */

