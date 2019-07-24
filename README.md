# COPD multi-omic meta-analysis

This depository contains key scripts used to analyze the data in the manuscript "Multi-omic meta-analysis identifies robust functional signatures of airway microbiome in COPD" by Wang et al.

The usage and instruction of individual scripts are below and also within the scripts. You need to download MetaCyc and STITCH databases first to be able to use some of these scripts.

1. "1_generate_transcriptome_table.pl" is used to process microarray data directly downloaded from NCBI GEO database. With a downloaded matchlist for each dataset and its platform, and each downloaded data including a metadata file, a probset gene match file for the platform and a raw expression matrix file, the script converts probe-set level expression data to gene-set level data and outputs as "$id_processed.txt".

2. "2_transcriptome_normalization.pl" is used to perform log2 transformation and z-score normalization of the processed expression data in the previous step, to generate "$id_normalized.txt" for statistical meta-analysis.

3. "3_combat_metaDE.r" is used to perform imputation for missing gene expresison values, combat batch adjustment and random effect meta-analysis using metaDE, the output is combined effect size and FDR P-value for each gene.

4. "4_extract_metacyc_reaction_info.pl" is used to parse the downloaded MetaCyc database, to obtain the metabolic reaction information and generate a cleaner file for enzyme, metabolic reaction, left and right compounds and reaction reversibility.

5. "5_convert_metacyc_to_stitch.pl" is used to convert MetaCyc compounds to STITCH compound IDs based on PubChem and ChEBI IDs, the input is a tab delimited compound list generated from the script "4_extract_metacyc_reaction_info.pl".

6. "6_parse_stitch_database.pl" is used to parse the downloaded STITCH database. Based on the compound STITCH IDs, the script pulls the list of targets for the compound, the interaction type and interaction confidence score.

7. "7_get_enzyme_compound_gene_links.pl" is used to integrate output from step 4, 5 and 6, to further generate host-compound interaction results at the enzyme level. The script uses "cmpd_selected.txt" from step 5, "compound_target_match.txt" from step 6, and "microbial_metabolic_reactions.txt" from step 4, as well as "meta-analysis.txt" from host transcriptome meta-analysis, to generate results for each enzyme (based on EC number) separately in the compound_annotation folder to be further triaged to link microbiome-host signatures.

8. "8_generate_EMM_for_PRMT.pl" is used to generate normalized Environmental Metabolomic Matrix (EMM) for PRMT calculation. Based on the enzyme-compound association table as input, the output is an enzyme-compound matrix in which the relative contribution score of the enzyme to the compound was indicated.

9. "9_calculate_PRMT.pl" is used to generate the PRMT score of the metabolites based on the combined fold change of microbial genes in the meta-analysis and the EMM matrix generated in the previous step.


