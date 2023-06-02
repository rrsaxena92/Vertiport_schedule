import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

inputFolder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/Fairness 15 Flights mean"
outputFolder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc"
figFolder = "E:/Digital_Twin_and_UAM/Figures"

noFairFile = "flight_sol_15_2023_05_05_16_34_17"
gateP5  = "flight_sol_15_2023_05_05_16_37_00"
gateP15 = "flight_sol_15_2023_05_05_16_39_43"
gateP25 = "flight_sol_15_2023_05_05_16_43_17"
totP5   = "flight_sol_15_2023_05_05_16_46_07"
totP15  = "flight_sol_15_2023_05_05_16_47_43"
totP25  = "flight_sol_15_2023_05_06_14_50_12"

""" FAIRNESS parsing """
# List of files
files = [noFairFile, gateP5, gateP15, gateP25, totP5, totP15, totP25]
fairType = ['No Fairness', 'Gate Delay', 'Gate Delay', 'Gate Delay', 'Total Delay', 'Total Delay', 'Total Delay']
P = [0,5,15,25,5,15,25]

# Columns to extract from each file
columns_to_extract = ['delay', 'GateTime', 'Taxidelay', 'OFVdelay', 'fixDelay']

# Initialize an empty DataFrame for the combined data
combined_data = pd.DataFrame()

# Iterate over each file
for file,f in zip(files,range(len(files))):
    # Read the file and extract the specified columns
    data = pd.read_csv(inputFolder + "/" +  file + '.csv', usecols=columns_to_extract)

    # Add the additional columns
    data['Fairness type'] = fairType[f]
    data['P'] = P[f]

    # Append the file data to the combined data
    combined_data = combined_data.append(data, ignore_index=True)

# Write the combined data to a new CSV file
combined_data.to_csv(outputFolder + "/" + 'combined_data.csv', index=False)

""" FAIRNESS plots """
vertdfFair = combined_data
# fig, ax = plt.subplots(figsize=(10,8))
ht = 6; asp = 6
g = sns.catplot(data=vertdfFair, x="P", y="delay", hue="Fairness type", kind="box", showmeans=True,
                 meanprops={"markeredgecolor": "red", "markerfacecolor" : "red"}, legend_out=True,
                height=ht, aspect=asp/ht)
sns.move_legend(g, "upper right")
g.set_ylabels("Delay (s)")
g.set(yticks=range(0,50,5))
# ax.add_legend(title="Fairness Type", label_order=["No Fairness", "Gate Delay", "Total Delay"])
# check axes and find which is have legend
# leg = g.axes.flat[0].get_legend()

new_title = 'Fairness Type'
g._legend.set_title(new_title)
new_labels = ["No Fairness", "Gate Delay", "Total Delay"]
for t, l in zip(g._legend.texts, new_labels):
    t.set_text(l)
plt.grid(axis='y')
plt.tight_layout()
plt.savefig(figFolder + "/" + "Fairness_box.pdf", dpi=600)

fig, axes = plt.subplots(ncols=3, nrows=2, figsize=(14,9))

vertdfFair = vertdfFair[(vertdfFair["Fairness type"]!="No Fairness")]
ylim = max(vertdfFair["delay"])
for node,i in zip(vertdfFair["Fairness type"].unique(), range(len(vertdfFair["Fairness type"].unique()))):
    axes[i,0].set_ylabel("Delay (s)")
    for p, j in zip(vertdfFair.P.unique(), range(len(vertdfFair.P.unique()))):
        df = vertdfFair[(vertdfFair["P"] == p) & (vertdfFair["Fairness type"] == node)]
        df.reset_index(inplace=True)
        del df["delay"], df["P"], df["Fairness type"], df["index"]
        df.plot(kind='bar', stacked=True, ax=axes[i,j], ylim=[0,ylim])
        axes[i,j].set_title(node + " | P = " + str(p))
        axes[1,j].set_xlabel("Flight index")
        axes[i, j].grid(axis='y')


plt.subplots_adjust(hspace=0.150, wspace=0.145, left=0.052, right=0.974, bottom=0.08, top=0.945)
plt.savefig(figFolder + "/" + "Fair15mean" + ".pdf", dpi=600)

plt.show()