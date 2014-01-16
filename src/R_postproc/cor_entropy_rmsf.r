# This function calculates the correlation between the two variables entropy and RSA for each protein structure in the study and outputs the result into a CSV file.
# Amir Shahmoradi, Wednesday 3:06 PM, Jan 15, 2015, Wilke Lab, ICMB, UT Austin

data = rbind(data_1RD8, data_2Z83, data_3GOL, data_3GSZ, data_3I5K, data_4AQF_B, data_4GHA_A, data_4IRY,
             data_2JLY, data_2JLY_temp_50, data_2JLY_temp_100, data_2JLY_temp_200, data_2JLY_temp_450)
data$protein = factor(data$protein)

result = data.frame()

for(protein in levels(data$protein))
{
    d = data[data$protein==protein,]
    
	x = cor.test( d$rmsf_avg_md, d$entropy, method="spearman", na.action="na.omit" )
    r.rmsf_avg_md = x$estimate
    p.rmsf_avg_md = x$p.value
    
	x = cor.test( d$rmsf_std_md, d$entropy, method="spearman", na.action="na.omit" )
    r.rmsf_std_md = x$estimate
    p.rmsf_std_md = x$p.value

    row = data.frame( protein=protein, r.rmsf_avg_md, p.rmsf_avg_md, r.rmsf_std_md, p.rmsf_std_md )
    result = rbind( result, row )
    print( protein )
}
row.names(result) = c()
write.csv( result, "cor_entropy_rmsf.csv", row.names=F )
