#  Perch Politics

A fock of birds desktop pet for macOS that flocks to the top left corner of the active window or to the dock.

Created as a gift for a friend to digitally imortalise their real life pet birds into desktop pets.

Forked from [mmar/Cat](https://github.com/mmar/Cat).

## Building

Clone this repository using your favorite graphical tool or the command line.

```sh
git clone https://github.com/wilgru/perch-politics.git
```

Create a `Developer.xcconfig` file with a unique bundle identifier and, optionally, your
Development Team ID. You can copy and edit the included template, just make sure not to
include it in the Xcode project, as it will not be commited to Git. Or use the shell:

```sh
cd Perch\ Politcs
echo "PRODUCT_BUNDLE_IDENTIFIER = <Reverse-DNS Identifier>" > Developer.xcconfig
echo "DEVELOPMENT_TEAM = <Your Team ID>" >> Developer.xcconfig
```

Use Xcode to normally build and run on your Mac.
