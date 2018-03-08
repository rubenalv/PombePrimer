# PombePrimer
Shiny app to create fission yeast mutants (primer design, Gibson assembly and N- and C-terminal vector collection).


# What is this app for?

Stable gene manipulation in fission yeast is usually achieved by transfecting plasmids or PCR products in the cell. The transfected DNA contains a region of interest flanked by sequences homologous to the target, which then replaces the target by means of the native homologus recombination machinery.

In most cases, flanking regions of 80 bp are enough for successful recombination. However, when selective pressure against the insertion gets higher, the transformation efficiency drops. The longer the flanking regions, however, the most efficient the transformation.

This app complements existing tools providing a means to clone long flanking regions: it designs primers for both cloning and validating constructs, providing a list of recipient backbones and options for custom vectors, and provides the final cloned vectors using Gibson assembly.
Credits

This app was designed by Dr. Ruben Alvarez, in the laboratory of Dr. Juan Mata, at the Department of Biochemistry in the University of Cambridge (UK).

This app was designed using the package Shiny in R, and primer3 version 2.3.7.
