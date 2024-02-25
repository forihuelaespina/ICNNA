# ICNNA
Imperial College Near Infrared Spectroscopy Neuroimaging Analysis

Previously known as Imperial College Neuroimage Analysis (ICNA), Imperial College Near Infrared Spectroscopy Neuroimaging Analysis (ICNNA) is a MATLAB based analysis tool for fNIRS neuroimaging data. Contrary to other software tools such as HomER, MNE-NIRS, NIRS Toolbox AnalyzIR or fOSA, ICNNA places the emphasis on the analysis over the processing with the experiment instead of the individual neuroimage being the central piece of information. It has statistical, topological and graph-theory based capabilities and its distinctive feature is the Manifold Embedding Neuroimaging Analysis (MENA).

ICNNA is not yet .snirf nor BIDS-NIRS compliant but we are working towards it.

## History
ICNNA was developed while the main developer Felipe Orihuela-Espina (FOE) was at Imperial College London. While Imperial College London retains the intellectual property, but a lot of features were added afterwards while (FOE) was later working at the Instituto Nacional de Astrofísica, Óptica y Electrónica (INAOE) in Mexico, and later at the University of Birmingham (UK).


## Installation
Download the latest stable release and unzip.


## Citation
If you use MOCARTS for your research, please cite the follwing publications

* Felipe Orihuela-Espina, Daniel R. Leff, David R. C. James, Ara W. Darzi, Guang-Zhong Yang "Imperial College Near Infrared Spectroscopy Neuroimaging Analysis (ICNNA) Framework" Neurophotonics, 2018, 5(1): 011011
* Felipe Orihuela-Espina, Daniel R. Leff, David R.C. James, Ara W. Darzi, Guang-Zhong Yang "ICNA: A software tool for manifold embedded based analysis of functional near infrared spectroscopy data", In 15th Annual Meeting of the Organization for Human Brain Mapping (OHBM), vol. 47, iss. S1, pgs. S59, 2009.

## Disclaimer
Software is provided as is. Use it at your own risk.

However, although ICNNA is provided as is, please feel free to e-mail [FOE](mailto:f.orihuela-espina@bham.ac.uk) in case you find a bug, you would like to see any special feature in the next version, or just to comment.

## ICNNA v1.2.0 supports .snirf

ICNNA v1.2.0 now supports .snirf (long due!). Testing thus far is limited.

Current limitations

* Although reading and writing of snirf files to class @icnna.snirf.snirf is complete (as far as I can tell), its conversion to ICNNA's @nirs_neuroimage or @structuredData for further processing/analysis, is however limited. Currently, only Raw Continuous Wave or reconstructed HbO/HbR is supported.
* snirf files can hold several neuroimages at once i.e. different .nirs datasets. ICNNA current version only converts one at a time. One needs to loop over the current function to convert the different datasets.

Additionally, there are some inherent differences that may require attention;

* Meta-data
ICNNA stores subject and session information in objects different from the @nirs_neuroimage. Therefore, while writing exporting to .snirf file, the snirf meta-data related to this cannot be extracted from the nirs_neuroimage. Only "generic" default meta-data is created. Users can of course later change this by manipulating the object's attributes before saving to a file.

* Wavelengths in the snirf probe
ICNNA stores wavelength information in the @rawData objects different from the @nirs_neuroimage (the rawData is accessible via the @dataSource object containing the @nirs_neuroimage when the @dataSource is locked). Therefore, the snirf data related to this cannot be extracted from the @nirs_neuroimage. Users can of course later change this by manipulating this object's attribute before saving to a file.

* Stims additional data and dataLabels
Both snirf and ICNNA can store additional information for each event in the timeline. However, in snirf, this additional information are simply additional columns in the stim(i).data matrix, whereas ICNNA associates a cell array to the condition and hence can store more rich data than just scalar values associated to the events. In this sense, not all data in ICNNA can be exported to snirf. To avoid potential conflicts, by the time being, ICNNA's eventsInfo is not being exported to the final snirf object (not even the scalar information if any). If a user wants to preserve this, this ought to be done manually after the conversion.

* Aux data
ICNNA stores auxiliary information collected during the sessions in different @dataSource objects. Therefore, the snirf data related to these cannot be extracted from the @nirs_neuroimage. You can of course later change this by manipulating this object's attribute before saving to a file.