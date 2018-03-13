shinyUI(fluidPage(
  titlePanel(h1(strong('Pombe long flanking region design'), style='color:steelblue')),
  br(),
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(
        tabPanel('Primers',
                 p(h4('Primer design:', style='color:steelblue')),
                 helpText("Choose insertion point"),
                 fluidRow(
                       column(5,
                         radioButtons("radio", label = strong("Insertion"),
                          choices = list(
                          "N-terminal" = 1,
                          "C-terminal" = 2,
                          "Custom insertion" = 3,
                          "Custom deletion" = 4
                           ),
                           selected = 1)
                       ),
                       column(7,
                         conditionalPanel(
                           condition = 'input.radio == 3',
                           textInput("coord", label = em("chromosome:coordinate:strand"), value = "", width='100%')
                         ),
                         conditionalPanel(
                           condition = 'input.radio == 4',
                                textInput("coordR5", label=em("5' chromosome:coord:strand"), value=""),
                                textInput("coordR3", label=em("3' chromosome:coord:strand"), value="")
                         )
                       )
                 ),
                helpText("Select interval size of the flanking regions"),
                textInput('FRlength', strong('Flanking region size'), value='600-900', width = '50%'),
                conditionalPanel(
                       condition = 'input.radio < 3',
                       helpText("Enter systematic ID's, e.g. SPCC962.06c, SPBP8B7.15c"),
                       textInput('systematicID', strong('Enter systematic ID'))
                ),
                    br(),
                    p(h4('Gibson Assembly design', style='color:steelblue')),
                    helpText("Choose the vector parts or add your custom ones"),
                    checkboxInput('GibsonCustom', 'Customised design', value=FALSE),
                    conditionalPanel(
                      condition = 'input.GibsonCustom == 1',
                      helpText("Enter the DNA sequences of insert and backbone "),
                      textInput('Gmodule1', strong('Insert')),
                      textInput('Gmodule2', strong('Backbone'))
                    ),
                    conditionalPanel(
                      condition = 'input.GibsonCustom == 0',
                      helpText("Select the vector for N- or C-terminal insertions"),
                      fluidRow(
                        column(12,
                               selectInput('plasmidBackbones', label = strong("Vector"),
                                           choices = c('noInput', vData),  #if vData needs updating, use the script /data/Rscript_updateVectorSequences.R
                                           selected = "noInput"
                               )
                        )
                      )
                      
                    ),
                    helpText("Select the number of nucleotides overlaping between the parts"),
                    numericInput('overlapLength', strong('Overlap length'), value=32, width = '50%'),
                    helpText('Select molarity (in pmol) for the flanking regions and the vector modules (insert and backbone)'),
                    fluidRow(
                      column(6, textInput('pmol.HR', 'pmol flanking regions', value = '0.1')),
                      column(6, textInput('pmol.vector', 'pmol vector modules', value = '0.07'))
                    )
                    
        ),

        tabPanel('Help',
                 
                 h4('Primer design'),
                 p('Choose an', strong("insertion point"), ':'),
                 p(HTML("<p style='margin-left: 5px'><span style='color:steelblue'>N-terminal</span>: makes HR_LF-R primers just before the ATG codon,
                         so tags are fused in-frame.")
                   ),
                 p(HTML("<p style='margin-left: 5px'><span style='color:steelblue'>C-terminal</span>: makes HR_LF-R primers just before the STOP codon,
                         so the STOP is eliminated for expression of the tag.")
                   ),
                 p(HTML("<p style='margin-left: 5px'><span style='color:steelblue'>Custom insertion</span>: takes the values of
                   chromosome(1-3):coordinate(any value within the chromosome range):strand(positive, 1; or negative, -1)
                   separated by colons, e.g.'<span style='color:steelblue'>1:14243:-1</span>. It makes HR_LF-R primers just before the custom coordinate.
                   You can enter several coordinates separating them with commas or spaces.")
                   ),
                 p(HTML("<p style='margin-left: 5px'><span style='color:steelblue'>Custom deletion</span>: creates flanking regions around
                   the region determined by 5' and 3' coordinates, excluding the coordinates themselves. You can enter several coordinates separating them with commas or spaces.")
                   ),
                 p("Choose the size of the", strong("flanking region"),  "to clone, which consists of two numeric values separated by a '-'.
                   If primers cannot be designed, just be less stringent with this size."
                   ),
                 p('Enter a', strong("pombe systematic ID"),  '(check',
                   tags$a(href="http://www.pombase.org", target='blank', 'Pombase'),
                   HTML("for reference). You can enter several ID's separating them with commas or spaces, e.g. 
                   <span style='color:steelblue'>SPCC962.06c, SPBP8B7.15c</span>.")
                 ),
                 
                 h4('Gibson Assembly design'),
                 p("The app is designed so as to provide unique primers for the vectors, and primers with vector-overlapping
                   5'-tails for the flanking regions. It will create a plasmid sequence with two vector modules (backbone and insert) 
                   and the two flanking regions cloned with the HR_ primers, providing primers for cloning
                   these modules and primers for checking clonings and in-yeast recombinations.",
                   'The assembly order is:',
                   br(),
                   span('left flanking region', style='color:steelblue'),
                   span('::', style='color:red'),
                   span('Insert', style='color:steelblue'),
                   span('::', style='color:red'),
                   span('right flanking region', style='color:steelblue'),
                   span('::', style='color:red'),
                   span('Backbone', style='color:steelblue')
                 ),
                 p("You can choose a vector from the dropdown list, which is available to download
                   in the 'Plasmids' tab: these vectors are for N-terminal (NTER-) or C-terminal (CTER-) insertions.
                   If you prefer to use another plasmid, just select", strong("customised design"),
                   "and add the backbone and the insert of your choice."
                   ),
                 p(HTML("The suggested tail <b>overlap length</b> for the Gibson Assembly is <i>32-38 nt</i>; in
                   our hands this leads to a cloning efficiency > 90%. The minimum acceptable length is <i>25 nt</i>, as
                   recommended in the NEB HiFi Gibson Assembly manual.")
                 )
              )
         )
    ),
    mainPanel(
          tabsetPanel(
            tabPanel('Designed Primers',
                #tags$head(tags$style(HTML("#allPrimersDownload table tr td {white-space: nowrap}"))),
                #summaryTable table tr td {word-wrap: break-word}
                fluidRow(
                  column(1, br(), br(), br(), downloadButton('geneIDDownload', ''), br(), br(),
                         tags$a(href="http://www.ncbi.nlm.nih.gov/gene", target='blank', 'NCBI-Gene')
                        ),
                  column(11, h3('Gene coordinates and flanking regions'),
                         tableOutput('geneID'))
                ),
                fluidRow(
                  column(1, br(), br(), br(), downloadButton('allPrimersDownload', '')),
                  column(11, tags$style(HTML("#allPrimers table tr td {white-space: nowrap}")),
                        h3('Primers'),
                        tableOutput('allPrimers'))
                ),
                fluidRow(
                  column(1, ''), #br(), br(), br(), downloadButton('overlapdataDownload', '')),
                  column(11, h3('Overlaps'),
                        p(strong('Plasmid: '), textOutput('plasmid', inline=T)),
                        tableOutput('overlapdata')
                        )
                ),
                fluidRow(
                  column(1, br(), br(), br(), downloadButton('GibsoncalcsDownload', '')),
                  column(11, h3('Molarity calculations for Gibson assembly'),
                         tableOutput('Gibsoncalcsdata')
                         )     
                  
                )
          ),
          
          tabPanel('Protocol',
                fluidRow(
                  h4('Cloning workflow'),
                  tags$img(src = "pombeprimer_protocol_b.png"),
                  p('Download a pdf version of the protocol ',
                  HTML("<a href=pombeprimer_protocol_b.pdf target='blank'>here</a><span>.</span>")
                  )
                ),
                br(),
                fluidRow(
                  h4('Cloning protocol'),
                  p("This protocol describes how to clone the target flanking regions in a vector to then do a genomic insertion in yeast. It uses Phusion Hot Start II DNA polymerase and NEBuilder® HiFi DNA Assembly Master Mix (NEB #E2621)."),
                  p("1. Genomic amplification: HR_primers are used to amplify genomic regions flanking the target. Use ~20 ng of genomic template and 0.2 µM primers in 100 ul reactions, and perform touch-down PCR:"),
                  p("98°C 45s, 12x (98°C 10s, 68>54°C 20s, 72°C 20s), 28x (98°C 10s, 72°C 35s), 72°C 5min (see note a)."),
                  p("2. PCR product purification and elution in water. If amplicon molarity (roughly band intensity) is similar, you may pool flanking regions for the same gene together (see note b)."),
                  p("3. Vector amplification: backbone_ and insert_primers are used to amplify the vector into two modules for the Gibson reaction. Use ~10 ng of plasmid template and 0.2 µM primers in in 100 ul reactions, and perform touch-down PCR:"),
                  p("98 45s, 35x (98 15s, 72 Xs + 5s/cycle from cycle 25) 72 7 min (see note c)."),
                  p("X = 15s / Kb of amplicon."),
                  p("4. PCR product purification and elution in water."),
                  p("5. Concentrate PCR eluates to 30-50 ng/ul for flanking regions and to 100-250 ng/ul for vector modules (see note d)."),
                  p("6. Gibson reaction. Use ~0.017 pmol of each of the two vector modules, and ~0.10 pmol of each flanking region, to have approximately a 3:1 ratio flanking region:vector and a total ~0.22-0.27 pmol reaction (see note e)."),
                  br(),
                  p("notes:"),
                  p("(a) HR_primers are designed minimising appearance of hairpins, so a wider range of Tm's can be expected. The touch-down 68>54°C (as per Phusion recommendations, the minimum Ta = Tm + 3°C, Tm being the lowest Tm of the primer set) will give specificity, so if you are cloning several genes you can do all reactions together with a high rate of success. If the primer Tm is much lower, just go lower than 54°C. If there is a hairpin raise the temperature; also, heating the primers at 95°C for 3 min, cooling them immediately on ice and keeping the PCR reaction on ice until the PCR machine is at 98°C can help fixing problems with hairpins."),
                  p("The two-step part of the PCR assumes that primers with tails (therefore with very high Tm) are used, so if you were using non-tailed primers you should do a regular three-step PCR."),
                  p("The extension times of 20 and 35s work well for 600-900 bp amplicons, otherwise adjust them accordingly."),
                  p("(b) Use your method of choice, as long as it gets rid of primers and you obtain single bands to set up clean Gibson reactions. E.g. silica column purification, paramagnetic beads or gel extraction, the latter being less recommended due to lower recovery."),
                  p("(c) It is key to get rid of all template circular vector before performing the Gibson assembly, so it does not get cloned into E. coli. If you amplify insert and backbone by PCR, do a DpnI digestion; if you get the modules by restriction digestion, you can gel extract the bands."),
                  p("Adding 5s/cycle in the extension increases final yield. For these big amplicons (3-8Kb) it is key to make sure that primers are in good condition. If extra bands appear after PCR, try and reduce the reaction volume to 25 ul to favour thermal exchange and keep primer annealing specificity and efficiency."),
                  p("(d) This will allow you to keep the Gibson reaction volume low. You need to have roughly equivalent molar amounts of modules in the Gibson reaction: the bigger the amplicon the higher the concentration needed. You can use a speedvac at 30-50°C, freeze-dry or in the previous steps just use low-elution volume kits or paramagnetic beads. "),
                  p("(e) 5 ul Gibson reactions in PCR tubes work well: aim for 0.21 pmol total modules (flanking regions + insert + backbone) and for a 3:1 ratio inserts:vector (0.09 pmol for each of two inserts at 3:1 insert:vector, plus 0.03 pmol of vector). If you prefer 20 ul Gibson reactions, aim for 0.84 pmol total modules."),
                  p("moles dsDNA (mol) = mass of dsDNA (g)/((length of dsDNA (bp) x 617.96 g/mol) + 36.04 g/mol)"),
                  p("moles of dsDNA ends = moles dsDNA (mol) x 2"),
                  p("DNA copy number = moles of dsDNA x 6.022e23 molecules/mol")
                )
                   
          ),
          
          tabPanel('Vector sequences',
                   helpText("You can download the plasmid maps here, as GenBank (.gb) or GenomeCompiler annotated files (.gcproj)."),
                   
                   #if new plasmid sequences are added, update this panel using /data/Rscript_updateVectorSequences.R
                   HTML("<a href=/vectorMaps/CTER.pFA6a-13Myc-KanMX6.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/CTER.pFA6a-13Myc-KanMX6.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/13Myc.html target='blank'>source</a>&emsp;"),
                   HTML("CTER.pFA6a-13Myc-KanMX6"),
                   br(),
                   HTML("<a href=/vectorMaps/CTER.pFA6a-3HA-KanMX6.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/CTER.pFA6a-3HA-KanMX6.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/3HA.html target='blank'>source</a>&emsp;"),
                   HTML("CTER.pFA6a-3HA-KanMX6"),
                   br(),
                   HTML("<a href=/vectorMaps/CTER.pFA6a-GFP(S65T)-KanMX6.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/CTER.pFA6a-GFP(S65T)-KanMX6.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/GFPS65T.html target='blank'>source</a>&emsp;"),
                   HTML("CTER.pFA6a-GFP(S65T)-KanMX6"),
                   br(),
                   HTML("<a href=/vectorMaps/CTER.pFA6a-GST-KanMX6.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/CTER.pFA6a-GST-KanMX6.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/GST.html target='blank'>source</a>&emsp;"),
                   HTML("CTER.pFA6a-GST-KanMX6"),
                   br(),
                   HTML("<a href=/vectorMaps/CTER.pREP-2PA-CTAP-KanMX6.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/CTER.pREP-2PA-CTAP-KanMX6.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=https://medschool.vanderbilt.edu/gould-lab/tap-tag-information target='blank'>source</a>&emsp;"),
                   HTML("CTER.pREP-2PA-CTAP-KanMX6"),
                   br(),
                   HTML("<a href=/vectorMaps/CTER.pREP-4PA-CTAP-KanMX6.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/CTER.pREP-4PA-CTAP-KanMX6.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=https://medschool.vanderbilt.edu/gould-lab/tap-tag-information target='blank'>source</a>&emsp;"),
                   HTML("CTER.pREP-4PA-CTAP-KanMX6"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-hphNT1-nmt41-3PK-3mAID.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-hphNT1-nmt41-3PK-3mAID.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("nolink   &emsp;"),
                   HTML("NTER.pFA6a-hphNT1-nmt41-3PK-3mAID"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/kanMX6.html target='blank'>source</a>&emsp;"),
                   HTML("NTER.pFA6a-KanMX6"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1-3HA.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1-3HA.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/nmt3HA.html target='blank'>source</a>&emsp;"),
                   HTML("NTER.pFA6a-KanMX6-nmt1-3HA"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/nmt.html target='blank'>source</a>&emsp;"),
                   HTML("NTER.pFA6a-KanMX6-nmt1"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1-GFP.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1-GFP.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/nmtGFP.html target='blank'>source</a>&emsp;"),
                   HTML("NTER.pFA6a-KanMX6-nmt1-GFP"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1-GST.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt1-GST.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=http://www-bcf.usc.edu/~forsburg/nmtGST.html target='blank'>source</a>&emsp;"),
                   HTML("NTER.pFA6a-KanMX6-nmt1-GST"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt41-3PK-3mAID.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-nmt41-3PK-3mAID.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("nolink   &emsp;"),
                   HTML("NTER.pFA6a-KanMX6-nmt41-3PK-3mAID"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-urg1.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pFA6a-KanMX6-urg1.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("nolink   &emsp;"),
                   HTML("NTER.pFA6a-KanMX6-urg1"),
                   br(),
                   HTML("<a href=/vectorMaps/NTER.pREP-LEU2-nmt1-NTAP.gb target='blank'>gb</a>&emsp;"),
                   HTML("<a href=/vectorMaps/NTER.pREP-LEU2-nmt1-NTAP.gcproj target='blank'>gcproj</a>&emsp;"),
                   HTML("<a href=https://medschool.vanderbilt.edu/gould-lab/tap-tag-information target='blank'>source</a>&emsp;"),
                   HTML("NTER.pREP-LEU2-nmt1-NTAP"),
                   br()
                   
                   
          ),
          
          tabPanel('Help',
            h4('Gene coordinates and flanking regions'),
            p("This table shows general data about the gene(s) you want to design primers for.
               If you have supplied a coordinate to design custom primers, it will display
               the gene which 5' or 3' end is closest to that coordinate in the chosen strand*.
               For convenience only gene information is displayed. The downloaded table will
               include flanking regions (LF, left flanking; RF, rigth flaking) and
               if Gibson modules have been supplied, Gibson assemblies."),
            p(tags$i('*Note that this is dependent on the strand, e.g. if you choose 1:1234:1 you will get
                     SPAC212.08c, which is a gene with start at 12158, but if you choose 1:1234:-1 you will
                     get SPAC212.11, with start at 1. In other words, this tells you just the closest
                     gene in that strand, so you can confirm whether you have entered the coordinate
                     you wanted, but might not be too informative if you are targeting an intergenic region.')
              ),
            br(),
            h4('Primers'),
            p("This table shows the primer resultsin the columns described below:"
              ),
            
            p(strong('Gene.'),"Gene or vector name. If the vector is custom it will be called", em('avector.')
              ),
            
            strong('Primer.'),
            p(span('ch_primers', style='color:steelblue'),
              "These are used for ", HTML("<i>ch</i>ecking"), " your plasmid cloning (using a chV_primer in the plasmid
              and its ch_ partner primer) and yeast transformation (using the pair just described to detect the insertion,
              and a pair of forward and reverse ch_primers to detect the wt genome (note that sometimes
              both pairs give a band, which means that a duplication has occurred).
              They generate short (<600 bp) amplicons that are ideal for direct colony PCR."
              ),
            
            p(span('HR_primers', style='color:steelblue'),
              "These primer pairs are used for cloning long regions (usually 600-900 bp, but you can
              customise length with the",
              em('Flanking region size'),
              "parameter) flanking your target (e.g. the ATG codon), to do ", HTML("<i>H</i>omologous <i>R</i>ecombination."),
              "If you add modules in the Gibson Assembly panel,
                    overlapping junctions will be selected and added to these primers as 5' tails.",
              em('LF'), " stands for 'Left Flanking region' and ",
              em('RF'), " for 'Right Flanking region'.",
              em("Note: "), "when you work in batch mode (designing primers for more than one gene at a time), if the app cannot
              design HR_primers for one of the genes it will not say anything, and obviously you will not find those primers
              in the table. This will happen in rare occasions when you push parameters and try to get exact flanking region sizes,
              by inputting e.g. '900-900'."
            ),
            
            p(span('chV_primers', style='color:steelblue'),
              "These are designed to ", HTML("<i>ch</i>eck your <i>V</i>ector"), " after Gibson assembly
                    (using both forward and reverse chV_primers),
                    and to check for correct homologus-recombination insertion in the target
                    (using pairs ch_/chV_)."
            ),
            
            p(span('insert_primers', style='color:steelblue'),
              "and ",
              span('backbone_primers', style='color:steelblue'),
              "These are designed at the ends of the insert or backbone, and then used to clone them.
                   If you are selecting a vector from the drowdown list, the backbone primers will be tagged as ",
              HTML("<i>backbone name</i>.back-.")
            ),
            
            p(strong('Sequence.'), "Primer sequences, which will be 5'-tagged with sequences overlapping the vector if it is supplied."
            ),
            
            p(strong('Amplicon(bp).'), "Size of the amplicon defined by the primer pair. For the HR_primers, it includes the size of the overlap sequences.
               When the Custom deletion approach is selected, for ch_primers the size includes the deleted region."
            ),
            
            p(strong('Tm.'), "Melting temperature of the primers, calculated using Santalucia 98' thermodynamic parameters."
            ),
            
            p(strong('Problems.'), "Problems of the primers, like low melting temperatures. High hairpin stabilities are penalised
            during primer design, but with cloning primers sometimes they will be unavoidable."
            ),
            
            p(strong('StartPos(BandSize).'),"Start position (in nt) of the primer with
            respect to the target coordinate, useful to calculate band sizes 
            if you wished to use your own primers to test constructs. For ch_ and chV_primer-F it will be negative,
            representing that the primer annealing site is", em('before'),
            "the target, and for ch_ and chV_primer-R positive, representing that the
            annealing site is", em('after'), "the target. ",
            em('BandSize'), "is the amplicon size of the ch_-F/chV-R or ch_-R/chV-F primer pair,
            if Gibson assembly vectors or custom modules have been selected."
            ),
            
            br(),
            h4('Overlaps'),
            p("This table shows the overlapping junctions (in 5'-3') extracted from the Gibson modules
              using the", em('overlap length'), "parameter."
            ),
            br(),
            br(),
            br()
          ),
          
          tabPanel('About',
            h4('What is this app for?'),
            p("Stable gene manipulation in fission yeast is usually achieved by transfecting plasmids or PCR products
              in the cell. The transfected DNA contains a region of interest flanked by sequences homologous to the target,
              which then replaces the target by means of the native homologus recombination machinery."),
            p("In most cases, flanking regions of 80 bp are enough for successful recombination. However, when selective
              pressure against the insertion gets higher, the transformation efficiency drops. The longer the flanking regions,
              however, the most efficient the transformation."),
            p("This app complements existing tools providing a means to clone long flanking regions: it designs primers for
               both cloning and validating constructs, providing a list of recipient backbones and options for custom vectors,
               and provides the final cloned vectors using Gibson assembly."),
            h4('Credits'),
            HTML("<p>This app was designed by <a href=https://www.linkedin.com/in/rubenalvarezfernandezcreative/ target='blank'>Dr. Ruben Alvarez</a>, in the laboratory of 
            <a href=http://www.bioc.cam.ac.uk/people/uto/mata target='blank'>Dr. Juan Mata</a>, at the Department of Biochemistry
            in the University of Cambridge (UK).
            <p>This app was designed using the package <a href=https://CRAN.R-project.org/package=shiny target='blank'>Shiny</a>
                 1.0.5 in R 3.4.3, and <a href=http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3424584/ target='blank'>primer3</a> version 
                 <a href=https://sourceforge.net/projects/primer3/files/primer3/2.3.7/ target='blank'>2.3.7</a>.</p>")
           
            #, and published in this <a href='under construction' target='blank'>paper</a>.</p> 
          )
        )
    )
  )
))